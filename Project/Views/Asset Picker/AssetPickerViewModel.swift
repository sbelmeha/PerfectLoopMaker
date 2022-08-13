//
//  AssetPickerViewModel.swift
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 26.06.2022.
//


import SwiftUI
import Combine
import Photos

class Asset: ObservableObject, Identifiable, Hashable {
    
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    @Published var image: UIImage? = nil
    
    @Published var avAsset: AVAsset?
    
    let asset: PHAsset
    
    private var manager = PHImageManager.default()
    func request() {
        DispatchQueue.global().async {
            self.manager.requestImage(for: self.asset, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFill, options: nil) { [weak self] (image, info) in
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
    
    func requestAVAsset(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            self.manager.requestAVAsset(forVideo: self.asset, options: nil) { (asset, _, _) in
                if let asset = asset {
                    DispatchQueue.main.async { [weak self] in
                        self?.avAsset = asset
                        completion()
                    }
                }
            }
        }
    }
    
    init(asset: PHAsset) {
        self.asset = asset
    }
}

class PhotoLibrary: ObservableObject {
    
    @Published var videoAssets = [Asset]()
    @Published var noAccess = false
    
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            guard let self = self else { return }
            
            switch status {
            case .authorized, .limited:
                self.getAllVideos()
                DispatchQueue.main.async {
                    self.noAccess = false
                }
            case .denied, .notDetermined, .restricted:
                DispatchQueue.main.async {
                    self.noAccess = true
                }
            @unknown default:
                DispatchQueue.main.async {
                    self.noAccess = true
                }
            }
        }
    }
    
    private func getAllVideos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "modificationDate", ascending: false) ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        
        let assets: PHFetchResult = PHAsset.fetchAssets(with: options)
        var videoAssets = [Asset]()
        assets.enumerateObjects { (asset, index, stop) in
            videoAssets.append(Asset(asset: asset))
        }
        DispatchQueue.main.async { [weak self] in
            self?.videoAssets = videoAssets
        }
        
    }
}

extension PHAsset: Identifiable {
}
