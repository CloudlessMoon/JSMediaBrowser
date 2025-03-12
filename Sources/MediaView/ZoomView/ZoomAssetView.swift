//
//  ZoomAssetView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/2.
//

import UIKit

public protocol ZoomAsset: Equatable {
    
    var size: CGSize { get }
    
}

public protocol ZoomAssetView: UIView {
    
    associatedtype Asset: ZoomAsset
    
    var asset: Asset? { get set }
    
    var isPlaying: Bool { get }
    
    func startPlaying()
    func stopPlaying()
    
}
