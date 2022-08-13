//
//  ViewModel.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 23.06.2022.
//

import Foundation
import AVFoundation
import VideoIO
import Photos
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var asset: AVAsset!
    @Published var selectedImage: Image?
    @Published var selectedImage2: Image?
    
    @AppStorage("quality") var quality = 1
    @AppStorage("scaleVal") var scaleValue: Double = 1
    @AppStorage("blurVal") var blurValue: Double = 6
    
    var firstTime: CMTime { CMTimeMultiplyByFloat64(asset.duration, multiplier: normalizedFirstFrameTime) }
    var secondTime: CMTime { CMTimeMultiplyByFloat64(asset.duration, multiplier: normalizedSecondFrameTime) }
    
    /// Default value is 0.25 - a middle of first half of a video
    @Published var normalizedFirstFrameTime: Double = 0.25
    /// Default value is 0.75 - a middle of second half of a video
    @Published var normalizedSecondFrameTime: Double = 0.75
    
    let normalizedFirstFrameTimeRange: ClosedRange<Double> = 0...0.5
    let normalizedSecondFrameTimeRange: ClosedRange<Double> = 0.5...1.0
    
    var exporter: VideoExporter
    
    init(exporter: VideoExporter) {
        self.exporter = exporter
        
        $normalizedFirstFrameTime.sink { _ in
            guard let _ = self.asset else { return }
            self.setThumbnail(intoImage: \.selectedImage, for: self.firstTime)
        }
        .store(in: &cancelable)
        
        $normalizedSecondFrameTime.sink { _ in
            guard let _ = self.asset else { return }
            self.setThumbnail(intoImage: \.selectedImage2, for: self.secondTime)
        }
        .store(in: &cancelable)
        
        $asset.sink { _ in
            guard let _ = self.asset else { return }
            self.setThumbnail(intoImage: \.selectedImage, for: self.firstTime)
            self.setThumbnail(intoImage: \.selectedImage2, for: self.secondTime)
        }
        .store(in: &cancelable)
    }
    
    var composition: AVComposition {
        let composition = processor.createCompositionFrom(asset: asset, firstTime: firstTime, secondTime: secondTime)
        return composition
    }
    
    var videoComposition: AVVideoComposition {
        let videoComposition = processor.createVideoComposition(asset: composition, blurVal: blurValue, scaleVal: scaleValue, quality: quality)
        return videoComposition
    }
    
    func useDemoVideo() {
        asset = AVAsset(url: Bundle.main.url(forResource: "marilyn_original", withExtension: "mp4")!)
        // these values work the best for the demo video
        normalizedFirstFrameTime = 0.27
        normalizedSecondFrameTime = 0.71
    }
    
    func saveExportedVideo() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.exporter.outputURL)
        }) { saved, error in
            if saved {
                print("Saved")
            }
        }
    }
    
    func startExport() {
        do {
            try exporter.set(composition: composition, videoComposition: videoComposition)
            exporter.start()
        } catch {
            print("Error \(error)")
        }
    }
    
    func cancelExport() {
        exporter.cancel()
    }
    
    // MARK: - Private
    
    private let processor = VideoProcessor()
    private var cancelable = Set<AnyCancellable>()

    private func setThumbnail(intoImage: ReferenceWritableKeyPath<HomeViewModel, Image?>, for time: CMTime) {
        let image = processor.thumbnailFromVideo(asset: asset, time: time)
        self[keyPath: intoImage] = Image(uiImage: image)
    }
    
}
