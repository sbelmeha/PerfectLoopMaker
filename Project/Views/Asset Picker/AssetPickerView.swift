//
//  AssetPickerView.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 26.06.2022.
//

import SwiftUI

struct PhotoRow: View {
    @ObservedObject var photo: Asset
    @State private var isDisappeard = false
    var body: some View {
        ZStack {
            HStack {
                if photo.image != nil {
                    GeometryReader { gr in
                        Image(uiImage: photo.image!)
                            .resizable()
                            .scaledToFill()
                            .frame(height: gr.size.width)
                    }
                    .clipped()
                    .aspectRatio(1, contentMode: .fit)
                } else {
                    Color.white
                }
            }.onAppear {
                self.isDisappeard = false
                self.photo.request()
            }.onDisappear {
                self.isDisappeard = true
            }

            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    Text(String(format: "%02d:%02d",Int((photo.asset.duration / 60)),Int(photo.asset.duration) % 60))
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                    Spacer()
                }
            }
        }
    }
}

struct AssetPickerView: View {
    
    @EnvironmentObject var photoLibrary: PhotoLibrary
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var callback: ((Asset) -> Void)
    
    var body: some View {
        ScrollView {
            if photoLibrary.noAccess {
                Text("The app needs to access your Photo Library to get videos")
                    .padding()
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(photoLibrary.videoAssets, id: \.self) { asset in
                        Button {
                            callback(asset)
                        } label: {
                            PhotoRow(photo: asset)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            self.photoLibrary.requestAuthorization()
        }
    }
}
