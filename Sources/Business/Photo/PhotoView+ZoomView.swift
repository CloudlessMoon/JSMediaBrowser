//
//  PhotoView+ZoomView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

extension ZoomView: PhotoView {
    
    public var zoomView: ZoomView<AssetView> {
        return self
    }
    
}
