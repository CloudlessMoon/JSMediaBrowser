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

struct ImageItem: PhotoAssetItem {
    
    struct Builder: PhotoAssetBuilder {
        
        func createMediator() -> SDWebImagePhotosAssetMediator {
            return .init(
                options: [.retryFailed],
                context: [
                    .storeCacheType: SDImageCacheType.disk.rawValue,
                    .queryCacheType: SDImageCacheType.disk.rawValue,
                    .animatedImageClass: SDAnimatedImage.self
                ]
            )
        }
        
        func createAssetView() -> ZoomView<SDAnimatedImageView> {
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
    
    var source: SDWebImagePhotosAssetMediator.Source
    
    var thumbnail: UIImage?
    
    var builder: Builder {
        return .init()
    }
    
}

struct LivePhotoItem: PhotoAssetItem {
    
    struct Builder: PhotoAssetBuilder {
        
        func createMediator() -> PHLivePhotoMediator {
            return .init()
        }
        
        func createAssetView() -> ZoomView<PHLivePhotoView> {
            let thumbnailView = SDAnimatedImageView()
            thumbnailView.autoPlayAnimatedImage = false
            return .init(
                assetView: PHLivePhotoView(),
                thumbnailView: thumbnailView,
                configuration: .init()
            )
        }
        
    }
    
    var source: PHLivePhotoMediator.Source
    
    var thumbnail: UIImage?
    
    var builder: Builder {
        return .init()
    }
    
}
