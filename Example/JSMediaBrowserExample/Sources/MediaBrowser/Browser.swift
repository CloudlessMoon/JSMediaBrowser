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

extension PhotoGeneralView {
    
    convenience init(zoomAssetView: T) {
        let thumbnailView = SDAnimatedImageView()
        thumbnailView.autoPlayAnimatedImage = false
        self.init(
            configuration: .init(emptyImage: UIImage(named: "img_fail")),
            zoomView: .init(assetView: zoomAssetView, thumbnailView: thumbnailView)
        )
    }
    
}

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
    
    func createView() -> PhotoGeneralView<SDAnimatedImageView> {
        let assetView = SDAnimatedImageView()
        assetView.autoPlayAnimatedImage = false
        if #available(iOS 17.0, *) {
            assetView.preferredImageDynamicRange = .high
        }
        return .init(zoomAssetView: assetView)
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
    
    func createView() -> PhotoGeneralView<PHLivePhotoView> {
        return .init(zoomAssetView: PHLivePhotoView())
    }
    
}

struct LivePhotoItem: PhotoItem {
    
    var source: PHLivePhotoMediator.Source
    
    var thumbnail: UIImage?
    
    var builder: LivePhotoBuilder {
        return .init()
    }
    
}
