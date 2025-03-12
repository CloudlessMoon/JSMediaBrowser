//
//  PhotoContentView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

public protocol PhotoContentView: UIView {
    
    associatedtype AssetView: ZoomAssetView
    
    var zoomView: ZoomView<AssetView> { get }
    
}
