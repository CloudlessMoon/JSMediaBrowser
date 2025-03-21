//
//  Browser+Convenient.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2025/3/14.
//

import UIKit
import SDWebImage
import JSMediaBrowser

typealias PhotoImageView = PhotoGeneralView<ZoomView<SDAnimatedImageView>, SDAnimatedImageView>

extension PhotoGeneralView {
    
    convenience init(zoomView: ZoomViewType) {
        let image = UIImage(named: "img_fail")?.sd_resizedImage(with: .init(width: 80, height: 80), scaleMode: .aspectFit)
        self.init(
            configuration: .init(emptyImage: image),
            zoomView: zoomView
        )
    }
    
}
