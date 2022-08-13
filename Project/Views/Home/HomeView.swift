//
//  ContentView.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 27.05.2022.
//

import SwiftUI
import MetalPetal
import AVKit
import VideoIO
import Combine
import SlideOverCard

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    @State var isPresentedAssetPicker = false
    @State var isPresentedExportView = false
    @State var showGreeting = false

    @AppStorage("onboardingNotPassed") var onboardingNotPassed = true
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    var overlayingFrames: some View {
        if let selectedImage = viewModel.selectedImage, let selectedImage2 = viewModel.selectedImage2 {
            ZStack {
                selectedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                
                selectedImage2
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .colorMultiply(.blue)
                    .opacity(0.5)
            }
            .frame(maxHeight: 300)
            .padding()
        }
    }
    
    var frameSliders: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("First Frame")
                    .padding(.top, 4)
                    .padding(.bottom, 10)
                Text("Second Frame")
            }
            
            VStack {
                Slider(value: $viewModel.normalizedFirstFrameTime,
                       in: viewModel.normalizedFirstFrameTimeRange,
                       step: 0.01
                )
                Slider(value: $viewModel.normalizedSecondFrameTime,
                       in: viewModel.normalizedSecondFrameTimeRange,
                       step: 0.01
                )
            }
        }
    }
    
    @ViewBuilder
    var demoVideoView: some View {
        if viewModel.asset == nil {
            Text("Works best with short videos 5-10 seconds length, video should contain similar frames.")
                .foregroundColor(.gray)
                .font(.system(size: 14))
               
            Button {
                viewModel.useDemoVideo()
            } label: {
                Text("Use demo video")
                    .font(.caption)
                    .padding(.top, 1)
            }
            .buttonStyle(.borderless)
        }
    }
    
    @ViewBuilder
    var processVideoButton: some View {
        if viewModel.asset != nil {
            Button {
                isPresentedExportView.toggle()
            } label: {
                Image(systemName: "infinity")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding([.top, .bottom])
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(8)
                
            }
            .buttonStyle(.borderless)
        }
    }
    
    var selectVideoButton: some View {
        Button {
            isPresentedAssetPicker.toggle()
        } label: {
            Text("Select Video")
                .bold()
                .foregroundColor(.white)
                .padding([.top, .bottom])
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(8)
        }
        .buttonStyle(.borderless)
    }
    
    var loopTabView: some View {
        NavigationView {
            VStack {
                ZStack {
                    List() {
                        if viewModel.asset != nil {
                            VStack() {
                                overlayingFrames
                                frameSliders
                            }
                        }
                        
                        ZStack {
                            VStack(alignment: .leading) {
                                selectVideoButton
                                
                                demoVideoView
                                
                                processVideoButton
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding([.top, .bottom])
                    }
                    .listStyle(.insetGrouped)
                }
                .navigationTitle("🦄 Perfect Loop")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem{
            Label("Home", systemImage: "infinity")
        }
    }
    
    var settingsTabView: some View {
        SettignsView()
            .environmentObject(viewModel)
            .tabItem {
                Label("Settings", systemImage: "dial.min")
            }
    }
    
    var body: some View {
        TabView {
            loopTabView
            
            settingsTabView
        }
        .sheet(isPresented: $isPresentedAssetPicker, content: {
            NavigationView {
                AssetPickerView(callback: { asset in
                    asset.requestAVAsset {
                        self.viewModel.asset = asset.avAsset
                    }
                    isPresentedAssetPicker.toggle()
                })
                .environmentObject(photoLibrary)
                .navigationTitle("Select video")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    isPresentedAssetPicker.toggle()
                }) {
                    Text("Close")
                })
            }
        })
        .slideOverCard(isPresented: $isPresentedExportView, content: {
            ExportView(exporter: viewModel.exporter)
                    .environmentObject(viewModel)
        })
        .sheet(isPresented: $onboardingNotPassed, content: {
            OnboardingView(viewModel: onboardingViewModel)
        })
        .onAppear {
            onboardingViewModel.closeAction = {
                onboardingNotPassed = false
            }
        }
    }

}
