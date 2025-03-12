//
//  PhotoAssetView+ZoomView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

extension ZoomView: PhotoAssetView {
    
    public typealias View = AssetView
    
    public var zoomView: ZoomView<View> {
        return self
    }
    
}
