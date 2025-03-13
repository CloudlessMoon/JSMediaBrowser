//
//  PhotoView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

public protocol PhotoView: UIView {
    
    associatedtype ZoomAssetViewType: ZoomAssetView
    associatedtype ZoomViewType: ZoomView<ZoomAssetViewType>
    
    var zoomView: ZoomViewType { get }
    
}

public extension PhotoView {
    
    func asZoomView<T: ZoomAssetView>() -> ZoomView<T>? {
        return self.zoomView as? ZoomView<T>
    }
    
}
