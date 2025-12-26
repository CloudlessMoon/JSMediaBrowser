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
            return self.getAssociatedValue(for: &AssociatedKeys.asset)
        }
        set {
            guard self.asset != newValue else {
                return
            }
            self.setAssociatedValue(newValue, for: &AssociatedKeys.asset)
            
            self.updateImage()
        }
    }
    
    var thumbnail: UIImage? {
        get {
            return self.getAssociatedValue(for: &AssociatedKeys.thumbnail)
        }
        set {
            guard self.thumbnail != newValue else {
                return
            }
            self.setAssociatedValue(newValue, for: &AssociatedKeys.thumbnail)
            
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
    
    func didDisplayed() {
        guard let asset = self.asset else {
            return
        }
        if #available(iOS 17, *), self.isHighDynamicRange(for: asset) {
            UIView.transition(
                with: self,
                duration: 0.25,
                options: [.transitionCrossDissolve, .curveEaseInOut, .allowUserInteraction]
            ) {
                self.image = asset
            }
        }
    }
    
    func didEndDisplayed() {
        
    }
    
    private func updateImage() {
        if let asset = self.asset {
            if #available(iOS 17, *), self.isHighDynamicRange(for: asset) {
                self.image = asset.imageRestrictedToStandardDynamicRange()
            } else {
                self.image = asset
            }
        } else {
            self.image = self.thumbnail
        }
    }
    
    @available(iOS 17, *)
    private func isHighDynamicRange(for asset: Asset) -> Bool {
        return asset.isHighDynamicRange && asset.size.width > 0 && asset.size.height > 0
    }
    
}

private extension UIView {
    
    func getAssociatedValue<T>(for key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(self, key) as? T
    }
    
    func setAssociatedValue<T>(_ value: T, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC, for key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value, policy)
    }
    
}

private struct AssociatedKeys {
    static var asset: UInt8 = 0
    static var thumbnail: UInt8 = 0
}
