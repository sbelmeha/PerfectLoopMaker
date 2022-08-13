//
//  ExportView.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 10.07.2022.
//

import SwiftUI
import Photos

struct ProgressBar: View {
    @Binding var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width)
                    .opacity(0.15)
                    .foregroundColor(.black)
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width))
                    .opacity(0.3)
                    .foregroundColor(.black)
                    .animation(.linear)
            }
        }
    }
}

struct ExportView: View {

    @EnvironmentObject var viewModel: HomeViewModel
    @ObservedObject var exporter: VideoExporter
    
    @State var showingAlert = false
    
//    init() {
//        self.exporter = viewModel.exporter
//    }
    
    func save() {
        viewModel.saveExportedVideo()
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text("🪄 Looping").font(.system(size: 28, weight: .bold))
            Text("Processing will take some time, please wait.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .padding(.bottom)
            
            viewModel.selectedImage!
                .resizable()
                .aspectRatio(contentMode: .fit)
                .blur(radius: 8)
                .clipped()
                .overlay(
                    Group {
                        ProgressBar(value: $exporter.progress)
                        
                        if exporter.completed {
                            PlayerView(url: exporter.outputURL, videoGravity: .resizeAspect)
                                .opacity(exporter.completed ? 1 : 0)
                        }
                    }
                )
                .cornerRadius(8)
            
            VStack {
                Button(action: {
                    save()
                    showingAlert = true
                }) {
                    Text(exporter.completed ? "Save" : "Processing...")
                        .bold()
                        .foregroundColor(.white)
                        .padding([.top, .bottom])
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(exporter.completed ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!exporter.completed)
                
            }
            .frame(height: 55)
            .padding(.vertical, 18)
        }
        .alert(isPresented: $showingAlert, content: {
            Alert(
                title: Text("Info"),
                message: Text("Video is saved")
            )
        })
        .onAppear {
            viewModel.startExport()
        }
        .onDisappear {
            viewModel.cancelExport()
        }
    }
    
}
