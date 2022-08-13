//
//  VideoExporter.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 26.06.2022.
//

import AVFoundation
import VideoIO
import Photos
import SwiftUI

public enum ImageOrientation {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight

    init(transform: CGAffineTransform) {
        if (transform.tx == 1.0 && transform.ty == 1.0) {
            self = .landscapeRight;
        } else if (transform.tx == 0 && transform.ty == 0) {
            self = .landscapeLeft
        } else if (transform.tx == 0 && transform.ty == 1.0) {
            self = .portraitUpsideDown
        } else {
            self = .portrait
        }
    }
    
}

class VideoExporter: ObservableObject {
    
    @Published var progress: Double = 0
    @Published private(set) var completed = false
    
    private var session: AssetExportSession!
    let outputURL: URL
    
    init(outputURL: URL) {
        self.outputURL = outputURL
    }
    
    func set(composition: AVComposition, videoComposition: AVVideoComposition) throws {
        progress = 0
        completed = false
        
        var height = videoComposition.renderSize.height
        var width = videoComposition.renderSize.width
        
        let preferredTransform = composition.tracks(withMediaType: .video).first!.preferredTransform
        
        let orientation = ImageOrientation(transform: preferredTransform)
        if orientation == .portrait || orientation == .portraitUpsideDown {
            swap(&height, &width)
        }
        
        var configuration = AssetExportSession.Configuration(
            fileType: .mp4,
            videoSettings: .h264(videoSize: CGSize(width: width, height: height)),
            audioSettings: .aac(channels: 2, sampleRate: 44100, bitRate: 128 * 1000)
        )
        configuration.videoComposition = videoComposition
        session = try AssetExportSession(asset: composition, outputURL: outputURL, configuration: configuration)
    }
    
    func cancel() {
        if session.status == .exporting {
            progress = 0
            completed = false
            
            session.cancel()
        }
    }
    
    func start() {
        do { // delete old video
            try FileManager.default.removeItem(at: outputURL)
        } catch { print(error.localizedDescription) }

        
        session.export(progress: { progress in
            DispatchQueue.main.async {
                self.progress = progress.fractionCompleted
            }
        }, completion: { error in
            withAnimation {
                print("Export completed")
                self.completed = true
            }
        })
    }
}
