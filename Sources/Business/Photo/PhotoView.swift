//
//  PhotoView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

public protocol PhotoView: UIView {
    
    associatedtype ZoomViewType: ZoomView<ZoomAssetViewType>
    associatedtype ZoomAssetViewType: ZoomAssetView
    
    var zoomView: ZoomViewType { get }
    
    func setAsset(_ asset: ZoomAssetViewType.Asset?, thumbnail: UIImage?)
    func setProgress(received: Int, expected: Int)
    func setError(_ error: NSError?, cancelled: Bool)
    
}
