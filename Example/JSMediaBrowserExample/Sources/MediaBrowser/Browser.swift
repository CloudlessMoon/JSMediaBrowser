//
//  Browser.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2025/1/2.
//

import UIKit
import SDWebImage
import JSMediaBrowser
import PhotosUI

struct ImageBuilder: PhotoBuilder {
    
    func createMediator() -> SDWebImagePhotosMediator {
        return .init(
            options: [.retryFailed],
            context: [
                .storeCacheType: SDImageCacheType.disk.rawValue,
                .queryCacheType: SDImageCacheType.disk.rawValue,
                .animatedImageClass: SDAnimatedImage.self,
                .imageDecodeToHDR: true
            ]
        )
    }
    
    func createView() -> PhotoImageView {
        let assetView = SDAnimatedImageView()
        assetView.autoPlayAnimatedImage = false
        if #available(iOS 17.0, *) {
            assetView.preferredImageDynamicRange = .high
        }
        return .init(zoomView: .init(assetView: assetView))
    }
    
}

struct ImageItem: PhotoItem {
    
    var source: SDWebImagePhotosMediator.Source
    
    var thumbnail: UIImage?
    
    var builder: ImageBuilder {
        return .init()
    }
    
}

struct LivePhotoBuilder: PhotoBuilder {
    
    func createMediator() -> PHLivePhotoMediator {
        return .init()
    }
    
    func createView() -> PhotoLivePhotoView {
        return .init(zoomView: .init(assetView: PHLivePhotoView()))
    }
    
}

struct LivePhotoItem: PhotoItem {
    
    var source: PHLivePhotoMediator.Source
    
    var thumbnail: UIImage?
    
    var builder: LivePhotoBuilder {
        return .init()
    }
    
}
