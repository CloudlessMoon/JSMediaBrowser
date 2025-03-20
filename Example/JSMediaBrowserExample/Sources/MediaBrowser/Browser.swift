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

struct ImageItem: PhotoItem {
    
    var source: SDWebImagePhotosMediator.Source
    
    var thumbnail: UIImage?
    
    var builder: ImageBuilder {
        return .init()
    }
    
}

struct ImageBuilder: PhotoBuilder {
    
    func createMediator() -> SDWebImagePhotosMediator {
        return .init(
            options: [.retryFailed, .fromLoaderOnly],
            context: [
                .queryCacheType: SDImageCacheType.disk.rawValue,
                .animatedImageClass: SDAnimatedImage.self,
                .imageDecodeToHDR: true
            ]
        )
    }
    
    func createPhotoView() -> PhotoImageView {
        let assetView = SDAnimatedImageView()
        assetView.autoPlayAnimatedImage = false
        if #available(iOS 17.0, *) {
            assetView.preferredImageDynamicRange = .high
        }
        return .init(zoomView: .init(assetView: assetView))
    }
    
    func createTransitionView() -> UIImageView {
        let imageView = SDAnimatedImageView()
        imageView.autoPlayAnimatedImage = false
        return imageView
    }
    
}
