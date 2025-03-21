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

extension PhotoGeneralView {
    
    convenience init(zoomView: ZoomViewType) {
        self.init(
            configuration: .init(emptyImage: UIImage(named: "img_fail")),
            zoomView: zoomView
        )
    }
    
}
