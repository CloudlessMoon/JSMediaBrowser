//
//  PhotoView+Private.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

internal extension PhotoView {
    
    var asset: (any ZoomAsset)? {
        return self.zoomView.asset
    }
    
    var thumbnail: UIImage? {
        return self.zoomView.thumbnail
    }
    
    var thumbnailView: UIImageView {
        return self.zoomView.thumbnailView
    }
    
    var contentViewFrame: CGRect {
        return self.zoomView.contentViewFrame
    }
    
    func setAsset(_ asset: (any ZoomAsset)?, thumbnail: UIImage?) {
        if let asset = asset {
            assert(self.isAsset(asset), "类型不匹配")
            self.zoomView.asset = self.asAsset(asset)
        } else {
            self.zoomView.asset = nil
        }
        
        self.zoomView.thumbnail = thumbnail
    }
    
    func setViewportInsets(_ viewportInsets: UIEdgeInsets) {
        self.zoomView.viewportInsets = viewportInsets
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
    
    private func asAsset(_ asset: any ZoomAsset) -> AssetView.Asset? {
        return asset as? AssetView.Asset
    }
    
    private func isAsset(_ asset: any ZoomAsset) -> Bool {
        return asset is AssetView.Asset
    }
    
}
