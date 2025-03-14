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
    
    func setProgress(received: Int, expected: Int)
    func setError(_ error: NSError?)
    
}
