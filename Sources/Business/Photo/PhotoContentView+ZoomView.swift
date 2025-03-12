//
//  PhotoContentView+ZoomView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

extension ZoomView: PhotoContentView {
   
    public typealias AssetView = AssetView
    
    public var zoomView: ZoomView<AssetView> {
        return self
    }
    
}
