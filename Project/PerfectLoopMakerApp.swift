//
//  Perfect Loop MakerApp.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 27.05.2022.
//

import SwiftUI

let photoLibrary = PhotoLibrary()
let videoExporter = VideoExporter(outputURL: URL(fileURLWithPath: NSTemporaryDirectory() + "video.mp4"))
let viewModel = HomeViewModel(exporter: videoExporter)
let onboardingViewModel = OnboardingViewModel()


@main
struct PerfectLoopMakerApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: viewModel)
        }
    }
}
