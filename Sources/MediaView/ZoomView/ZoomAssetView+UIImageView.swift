//
//  ZoomAssetView+UIImageView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/2.
//

import UIKit

public extension ZoomAssetView where Self: UIImageView, Asset: UIImage {
    
    var asset: UIImage? {
        get {
            return self.getAssociated(for: &AssociatedKeys.asset)
        }
        set {
            guard self.asset != newValue else {
                return
            }
            self.setAssociated(newValue, for: &AssociatedKeys.asset)
            
            self.updateImage()
        }
    }
    
    var thumbnail: UIImage? {
        get {
            return self.getAssociated(for: &AssociatedKeys.thumbnail)
        }
        set {
            guard self.thumbnail != newValue else {
                return
            }
            self.setAssociated(newValue, for: &AssociatedKeys.thumbnail)
            
            self.updateImage()
        }
    }
    
    var renderedImage: UIImage? {
        return self.image
    }
    
    var isPlaying: Bool {
        return self.isAnimating
    }
    
    func startPlaying() {
        self.startAnimating()
    }
    
    func stopPlaying() {
        self.stopAnimating()
    }
    
    private func updateImage() {
        if let asset = self.asset {
            self.image = asset
        } else {
            self.image = self.thumbnail
        }
    }
    
}

private extension UIView {
    
    func getAssociated<T>(for key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(self, key) as? T
    }
    
    func setAssociated<T>(_ object: T, for key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
}

private struct AssociatedKeys {
    static var asset: UInt8 = 0
    static var thumbnail: UInt8 = 0
}
