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
        zoomView: { index in
            return ZoomView(configuration: .default)
        }
    )
    
}

extension ZoomViewConfiguration {
    
    static let `default` = ZoomViewConfiguration(
        assetView: {
            if $0 is UIImage {
                let imageView = SDAnimatedImageView()
                imageView.autoPlayAnimatedImage = false
                if #available(iOS 17.0, *) {
                    imageView.preferredImageDynamicRange = .high
                }
                return imageView
            } else if $0 is PHLivePhoto {
                return PHLivePhotoView()
            } else {
                return nil
            }
        },
        thumbnailView: {
            let imageView = SDAnimatedImageView()
            imageView.autoPlayAnimatedImage = false
            return imageView
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
