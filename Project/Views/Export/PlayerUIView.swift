//
//  PlayerUIView.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 02.07.2022.
//

import UIKit
import AVFoundation
import SwiftUI

struct PlayerView: UIViewRepresentable {
    let url: URL
    let videoGravity: AVLayerVideoGravity?
    
    init(url: URL, videoGravity: AVLayerVideoGravity? = nil) {
        self.url = url
        self.videoGravity = videoGravity
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero, url: url, videoGravity: videoGravity ?? .resizeAspectFill)
    }
}

class PlayerUIView: UIView {
    let url: URL
 
    private let playerLayer = AVPlayerLayer()
    init(frame: CGRect, url: URL, videoGravity: AVLayerVideoGravity) {
        self.url = url
        super.init(frame: frame)
        
        playerLayer.videoGravity = videoGravity
        let player = AVPlayer(url: url)
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
        
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
