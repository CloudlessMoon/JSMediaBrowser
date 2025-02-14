//
//  Browser.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2025/1/2.
//

import UIKit
import SDWebImage
import JSMediaBrowser

struct ImageItem: ImageAssetItem {
    
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

struct LivePhotoItem: LivePhotoAssetItem {
    
    var source: PHLivePhotoMediator.Source
    
    var thumbnail: UIImage?
    
    var mediator: PHLivePhotoMediator {
        return .init()
    }
    
}
