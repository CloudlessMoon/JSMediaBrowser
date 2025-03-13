//
//  PhotoView+ZoomView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

extension ZoomView: PhotoView {
    
    public typealias ZoomAssetViewType = AssetView
    public typealias ZoomViewType = ZoomView<ZoomAssetViewType>
    
    public var zoomView: ZoomViewType {
        return self
    }
    
}
