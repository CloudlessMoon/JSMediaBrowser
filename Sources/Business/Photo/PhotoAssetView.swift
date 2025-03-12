//
//  PhotoAssetView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

public protocol PhotoAssetView: UIView {
    
    associatedtype View: ZoomAssetView
    
    var zoomView: ZoomView<View> { get }
    
}
