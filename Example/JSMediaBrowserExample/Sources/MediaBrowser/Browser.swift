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
                .animatedImageClass: SDAnimatedImage.self
            ]
        )
    }
    
    func createView() -> ZoomView<SDAnimatedImageView> {
        let assetView = SDAnimatedImageView()
        assetView.autoPlayAnimatedImage = false
        if #available(iOS 17.0, *) {
            assetView.preferredImageDynamicRange = .high
        }
        let thumbnailView = SDAnimatedImageView()
        thumbnailView.autoPlayAnimatedImage = false
        return .init(
            assetView: assetView,
            thumbnailView: thumbnailView,
            configuration: .init()
        )
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
    
    func createView() -> ZoomView<PHLivePhotoView> {
        let thumbnailView = SDAnimatedImageView()
        thumbnailView.autoPlayAnimatedImage = false
        return .init(
            assetView: PHLivePhotoView(),
            thumbnailView: thumbnailView,
            configuration: .init()
        )
    }
    
}

struct LivePhotoItem: PhotoItem {
    
    var source: PHLivePhotoMediator.Source
    
    var thumbnail: UIImage?
    
    var builder: LivePhotoBuilder {
        return .init()
    }
    
}
