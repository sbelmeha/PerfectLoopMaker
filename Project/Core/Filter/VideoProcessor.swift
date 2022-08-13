//
//  VideoProcessor.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 27.05.2022.
//

import Foundation
import AVFoundation
import MetalPetal
import Vision
import VideoIO
import UIKit

class VideoProcessor {
    
    func createCompositionFrom(asset: AVAsset, firstTime: CMTime, secondTime: CMTime) -> AVComposition {
        let composition = AVMutableComposition()
        
        let videoTrack = asset.tracks(withMediaType: .video).first!
        
        firstId = composition.unusedTrackID()
        let firstVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: firstId)
        
        secondId = composition.unusedTrackID()
        let secondVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: secondId)

        let halfDuration = CMTimeMultiplyByFloat64(asset.duration, multiplier: 0.5)
        
        /// This is the duration of fade transition betwen 2 video tracks, based on my tests 0.2 of a second works fine, but maybe it can be moved somewhere to the app settings.
        let fadeTransitionDuration = CMTimeMakeWithSeconds(0.2, preferredTimescale: 10)
        
        let firstTime = firstTime + fadeTransitionDuration >= halfDuration - firstTime ? firstTime - fadeTransitionDuration : firstTime
        let secondTime = secondTime <= halfDuration ? halfDuration + fadeTransitionDuration : secondTime
        
        filter.startTime = (secondTime - halfDuration - fadeTransitionDuration).seconds
        filter.endTime = (secondTime - halfDuration + fadeTransitionDuration).seconds
  
        do {
            try secondVideoTrack?.insertTimeRange(
                CMTimeRange(
                    start: firstTime,
                    duration: halfDuration - firstTime
                ),
                of: videoTrack,
                at: secondTime - halfDuration - fadeTransitionDuration
            )
            
            try firstVideoTrack?.insertTimeRange(
                CMTimeRange(
                    start: halfDuration,
                    duration: secondTime - halfDuration
                ),
                of: videoTrack,
                at: .zero
            )
        } catch {
            print(error)
        }
        
        secondVideoTrack?.preferredTransform = videoTrack.preferredTransform
        firstVideoTrack?.preferredTransform = videoTrack.preferredTransform
        
        return composition
    }

    func createVideoComposition(asset: AVComposition, blurVal: Double, scaleVal: Double, quality: Int) -> AVVideoComposition {
        filter.quality = quality
        filter.renderContext = renderContext
        filter.blurVal = blurVal
        filter.scaleVal = scaleVal

        let videoComposition =  MTIVideoComposition(asset: asset, context: renderContext, queue: concurrentQueue, filter: { request in
            guard let anySourceImage = request.anySourceImage else {
                return .black
            }
            
            let firstSourceImage = request.sourceImages[self.firstId]
            let secondSourceImage = request.sourceImages[self.secondId]
            
            let time = request.compositionTime
            
            /// Skip processing frames that are not in the range of duration of fade transition
            if time.seconds < self.filter.startTime {
                return firstSourceImage ?? .black
            } else if time.seconds > self.filter.endTime {
                return secondSourceImage ?? .black
            }
        
            return FilterGraph.makeImage { output in
                let anyImg = secondSourceImage ?? anySourceImage

                self.filter.firstImage = anyImg
                self.filter.currentTime = time.seconds

                if let firstSourceImage = firstSourceImage, let secondSourceImage = secondSourceImage {
                    self.filter.firstImage = firstSourceImage
                    self.filter.secondImage = secondSourceImage
                }
                    
                self.filter => output
            }!
        }).makeAVVideoComposition()
        
        return videoComposition
    }
    
    func thumbnailFromVideo(asset: AVAsset, time: CMTime) -> UIImage {
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        imgGenerator.requestedTimeToleranceAfter = .zero
        imgGenerator.requestedTimeToleranceBefore = .zero
        do{
            let cgImage = try imgGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        }catch{
            print(error)
        }
        return UIImage()
    }
    
    // MARK: - Private
    
    private let concurrentQueue = DispatchQueue(label: "com.perfect-loop-maker.concurrent.queue", attributes: .concurrent)
    private let filter = SmoothTransitionFilter()
    private let renderContext = try! MTIContext(device: MTLCreateSystemDefaultDevice()!)
    
    private var firstId: CMPersistentTrackID!
    private var secondId: CMPersistentTrackID!
        
}
