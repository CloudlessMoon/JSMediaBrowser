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

extension MediaBrowserViewControllerConfiguration {
    
    static let `default` = MediaBrowserViewControllerConfiguration(
        zoomView: { item, _ in
            if item is ImageItem {
                let assetView = SDAnimatedImageView()
                assetView.autoPlayAnimatedImage = false
                if #available(iOS 17.0, *) {
                    assetView.preferredImageDynamicRange = .high
                }
                let thumbnailView = SDAnimatedImageView()
                thumbnailView.autoPlayAnimatedImage = false
                return ZoomView(assetView: assetView, thumbnailView: thumbnailView, configuration: .init())
            } else if item is LivePhotoItem {
                let thumbnailView = SDAnimatedImageView()
                thumbnailView.autoPlayAnimatedImage = false
                return ZoomView(assetView: PHLivePhotoView(), thumbnailView: thumbnailView, configuration: .init())
            } else {
                return nil
            }
        }
    )
    
}

struct ImageItem: AssetItem {
    
    var source: SDWebImagePhotosAssetMediator.Source
    
    var thumbnail: UIImage?
    
    var mediator: SDWebImagePhotosAssetMediator {
        return .init(
            options: [.retryFailed],
            context: [
                .storeCacheType: SDImageCacheType.disk.rawValue,
                .queryCacheType: SDImageCacheType.disk.rawValue,
                .animatedImageClass: SDAnimatedImage.self
            ]
        )
    }
    
}

struct LivePhotoItem: AssetItem {
    
    var source: PHLivePhotoMediator.Source
    
    var thumbnail: UIImage?
    
    var mediator: PHLivePhotoMediator {
        return .init()
    }
    
}
