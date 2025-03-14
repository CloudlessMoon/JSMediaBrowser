//
//  Browser+Convenient.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2025/3/14.
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
