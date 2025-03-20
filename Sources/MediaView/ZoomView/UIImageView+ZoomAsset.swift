//
//  UIImageView+ZoomAsset.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/2.
//

import UIKit

extension UIImage: ZoomAsset {}

extension UIImageView: ZoomAssetView {
    
    public var asset: UIImage? {
        get {
            return self.image
        }
        set {
            self.image = newValue
        }
    }
    
    public var renderedImage: UIImage? {
        return self.image
    }
    
    public var isPlaying: Bool {
        return self.isAnimating
    }
    
    public func startPlaying() {
        self.startAnimating()
    }
    
    public func stopPlaying() {
        self.stopAnimating()
    }
    
}
