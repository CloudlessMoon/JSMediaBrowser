//
//  PhotoView+Private.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

internal extension PhotoView {
    
    var asset: (any ZoomAsset)? {
        get {
            return self.zoomView.asset
        }
        set {
            if let asset = newValue {
                assert(self.isAsset(asset), "类型不匹配，理论上不会出现此情况，请按照堆栈检查代码")
                self.setAsset(self.asAsset(asset))
            } else {
                self.setAsset(nil)
            }
        }
    }
    
    var assetView: any ZoomAssetView {
        return self.zoomView.assetView
    }
    
    var thumbnail: UIImage? {
        get {
            return self.zoomView.thumbnail
        }
        set {
            self.zoomView.thumbnail = newValue
        }
    }
    
    var renderedImage: UIImage? {
        return self.zoomView.assetView.renderedImage
    }
    
    func setViewport(insets: UIEdgeInsets, maximumSize: CGSize) {
        self.zoomView.viewportInsets = insets
        self.zoomView.viewportMaximumSize = maximumSize
    }
    
    func startPlaying() {
        self.zoomView.startPlaying()
    }
    
    func stopPlaying() {
        self.zoomView.stopPlaying()
    }
    
    func doubleTap(at point: CGPoint, from view: UIView) {
        let minimumZoomScale = self.zoomView.minimumZoomScale
        if self.zoomView.zoomScale != minimumZoomScale {
            self.zoomView.setZoom(scale: minimumZoomScale, animated: true)
        } else {
            let point = self.zoomView.assetView.convert(point, from: view)
            self.zoomView.zoom(to: point, scale: self.zoomView.maximumZoomScale, animated: true)
        }
    }
    
    func isScrolling(with velocity: CGPoint) -> Bool {
        let minY = ceil(self.zoomView.minimumContentOffset.y)
        let maxY = floor(self.zoomView.maximumContentOffset.y)
        let contentOffset = self.zoomView.contentOffset
        /// 垂直触摸滑动
        if abs(velocity.x) <= abs(velocity.y) {
            if velocity.y > 0 {
                /// 手势向下
                return self.zoomView.isDragging || self.zoomView.isDecelerating || contentOffset.y > minY
            } else {
                /// 手势向上
                return self.zoomView.isDragging || self.zoomView.isDecelerating || contentOffset.y < maxY
            }
        } else {
            return true
        }
    }
    
    private func asAsset(_ asset: any ZoomAsset) -> ZoomAssetViewType.Asset? {
        return asset as? ZoomAssetViewType.Asset
    }
    
    private func isAsset(_ asset: any ZoomAsset) -> Bool {
        return asset is ZoomAssetViewType.Asset
    }
    
}
