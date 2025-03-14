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

typealias PhotoImageView = PhotoGeneralView<ZoomView<SDAnimatedImageView>, SDAnimatedImageView>
typealias PhotoLivePhotoView = PhotoGeneralView<ZoomView<PHLivePhotoView>, PHLivePhotoView>

extension PhotoGeneralView {
    
    convenience init(zoomView: ZoomViewType) {
        self.init(
            configuration: .init(emptyImage: UIImage(named: "img_fail")),
            zoomView: zoomView
        )
    }
    
}

extension ZoomView {
    
    convenience init(assetView: AssetView) {
        let thumbnailView = SDAnimatedImageView().then {
            $0.autoPlayAnimatedImage = false
        }
        self.init(assetView: assetView, thumbnailView: thumbnailView)
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
