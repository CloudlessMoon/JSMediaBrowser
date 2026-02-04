//
//  ZoomAssetView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/2.
//

import UIKit

public protocol ZoomAsset: Equatable {
    
}

public protocol ZoomAssetView: UIView {
    
    associatedtype Asset: ZoomAsset
    
    var asset: Asset? { get set }
    
    var thumbnail: UIImage? { get set }
    
    var renderedImage: UIImage? { get }
    
    var isPlaying: Bool { get }
    
    func startPlaying()
    func stopPlaying()
    
    func didDisplayed()
    func didEndDisplayed()
    
}
