//
//  ZoomView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import JSCoreKit

open class ZoomView: BasisMediaView {
    
    public var asset: (any ZoomAsset)? {
        didSet {
            if let asset = self.asset {
                self.createAssetView(for: asset)
            }
            
            guard let assetView = self.assetView else {
                return
            }
            guard !assetView.isEqual(self.asset) else {
                return
            }
            assetView.setAsset(self.asset)
            
            self.updateThumbnailView()
            
            self.setNeedsRevertZoom()
        }
    }
    
    public var thumbnail: UIImage? {
        didSet {
            if self.thumbnail != nil {
                self.createThumbnailView()
            }
            
            guard let thumbnailView = self.thumbnailView else {
                return
            }
            guard thumbnailView.image != self.thumbnail else {
                return
            }
            thumbnailView.image = self.thumbnail
            
            self.updateThumbnailView()
            
            self.setNeedsRevertZoom()
        }
    }
    
    public override var contentMode: UIView.ContentMode {
        didSet {
            if oldValue != self.contentMode {
                self.setNeedsRevertZoom()
            }
        }
    }
    
    public var enabledZoom: Bool = true
    
    public var maximumZoomScale: CGFloat = 2.0 {
        didSet {
            self.scrollView.maximumZoomScale = self.maximumZoomScale
        }
    }
    
    public private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = self.maximumZoomScale
        scrollView.scrollsToTop = false
        scrollView.delaysContentTouches = false
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    public let modifier: ZoomViewModifier
    
    private var assetView: (any ZoomAssetView)?
    
    private var thumbnailView: UIImageView?
    
    private var isNeededRevertZoom: Bool = false
    
    public init(modifier: ZoomViewModifier) {
        self.modifier = modifier
        
        super.init()
    }
    
    open override func didInitialize() {
        super.didInitialize()
        self.contentMode = .center
        
        self.addSubview(self.scrollView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        /// scrollView
        let previousSize = self.scrollView.bounds.size
        if previousSize != self.bounds.size {
            self.scrollView.js_frameApplyTransform = self.bounds
            self.setNeedsRevertZoom()
        }
        
        let calculateLayout = { (view: UIView, size: CGSize) in
            let contentRect = JSCGRectApplyAffineTransformWithAnchorPoint(
                CGRect(origin: CGPoint.zero, size: size),
                view.transform,
                view.layer.anchorPoint
            )
            view.frame = CGRect(origin: .zero, size: contentRect.size)
        }
        /// assetView
        if let assetView = self.assetView {
            let assetSize = {
                guard let asset = self.asset else {
                    return CGSize.zero
                }
                return asset.size
            }()
            calculateLayout(assetView, assetSize)
        }
        /// thumbnailView
        if let thumbnailView = self.thumbnailView {
            let thumbnailSize = {
                guard let thumbnail = self.thumbnail else {
                    return CGSize.zero
                }
                return thumbnail.size
            }()
            calculateLayout(thumbnailView, thumbnailSize)
        }
        
        self.revertZoomIfNeeded()
    }
    
    public override var containerView: UIView {
        return self.scrollView
    }
    
    public override var contentView: UIView? {
        if self.asset != nil {
            return self.assetView
        } else if self.thumbnail != nil {
            return self.thumbnailView
        } else {
            return nil
        }
    }
    
    public override var contentViewFrame: CGRect {
        guard let contentView = self.contentView else {
            return CGRect.zero
        }
        return self.convert(contentView.frame, from: contentView.superview)
    }
    
}

extension ZoomView {
    
    public var minContentOffset: CGPoint {
        let scrollView: UIScrollView = self.scrollView
        let contentInset: UIEdgeInsets = scrollView.adjustedContentInset
        return CGPoint(x: -contentInset.left,
                       y: -contentInset.top)
    }
    
    public var maxContentOffset: CGPoint {
        let scrollView: UIScrollView = self.scrollView
        let contentInset: UIEdgeInsets = scrollView.adjustedContentInset
        return CGPoint(x: scrollView.contentSize.width + contentInset.right - scrollView.bounds.width,
                       y: scrollView.contentSize.height + contentInset.bottom - scrollView.bounds.height)
    }
    
}

extension ZoomView {
    
    public var isPlaying: Bool {
        guard let assetView = self.assetView else {
            return false
        }
        return assetView.isPlaying
    }
    
    public func startPlaying() {
        if self.asset != nil, let assetView = self.assetView, !assetView.isPlaying {
            assetView.startPlaying()
        } else if self.thumbnail != nil, let thumbnailView = self.thumbnailView, !thumbnailView.isAnimating {
            thumbnailView.startAnimating()
        }
    }
    
    public func stopPlaying() {
        if let assetView = self.assetView, assetView.isPlaying {
            assetView.stopPlaying()
        }
        if let thumbnailView = self.thumbnailView, thumbnailView.isAnimating {
            thumbnailView.stopAnimating()
        }
    }
    
    public var minimumZoomScale: CGFloat {
        let mediaSize = {
            if let asset = self.asset {
                return asset.size
            } else if let thumbnail = self.thumbnail {
                return thumbnail.size
            }
            return CGSize.zero
        }()
        var minScale: CGFloat = 1.0
        if self.contentView == nil || mediaSize.width <= 0 || mediaSize.height <= 0 {
            minScale = 1.0
        } else {
            let viewport: CGRect = self.calculateViewportRect
            var contentMode = self.contentMode
            let scaleX: CGFloat = viewport.width / mediaSize.width
            let scaleY: CGFloat = viewport.height / mediaSize.height
            let finalHeight: CGFloat = mediaSize.width > viewport.width ? viewport.width * (mediaSize.height / mediaSize.width) : mediaSize.height
            if finalHeight > viewport.height {
                contentMode = .scaleAspectFill
            }
            if contentMode == .scaleAspectFit {
                minScale = min(scaleX, scaleY)
            } else if contentMode == .scaleAspectFill {
                minScale = max(scaleX, scaleY)
            } else if contentMode == .center {
                if scaleX >= 1 && scaleY >= 1 {
                    minScale = 1.0
                } else {
                    minScale = min(scaleX, scaleY)
                }
            }
        }
        return minScale
    }
    
    public var zoomScale: CGFloat {
        return self.scrollView.zoomScale
    }
    
    public func setZoom(scale: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: JSCoreHelper.animationOptionsCurveOut, animations: {
                self.scrollView.zoomScale = scale
            }, completion: nil)
        } else {
            self.scrollView.zoomScale = scale
        }
    }
    
    public func zoom(to point: CGPoint, scale: CGFloat = 3.0, animated: Bool) {
        guard scale > 0 else {
            return
        }
        let minimumZoomScale: CGFloat = self.minimumZoomScale
        var zoomRect: CGRect = CGRect.zero
        zoomRect.size.width = self.scrollView.frame.width / scale / minimumZoomScale
        zoomRect.size.height = self.scrollView.frame.height / scale / minimumZoomScale
        zoomRect.origin.x = point.x - zoomRect.width / 2
        zoomRect.origin.y = point.y - zoomRect.height / 2
        self.zoom(to: zoomRect, animated: animated)
    }
    
    public func zoom(to rect: CGRect, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: JSCoreHelper.animationOptionsCurveOut, animations: {
                self.scrollView.zoom(to: rect, animated: false)
            }, completion: nil)
        } else {
            self.scrollView.zoom(to: rect, animated: false)
        }
    }
    
    public func revertZooming() {
        if self.bounds.isEmpty {
            return
        }
        let enabledZoom = self.enabledZoom
        let minimumZoomScale = self.minimumZoomScale
        let maximumZoomScale = max(enabledZoom ? self.maximumZoomScale : minimumZoomScale, minimumZoomScale)
        let shouldFireDidZoomingManual = self.zoomScale == minimumZoomScale
        self.scrollView.panGestureRecognizer.isEnabled = enabledZoom
        self.scrollView.pinchGestureRecognizer?.isEnabled = enabledZoom
        self.scrollView.minimumZoomScale = minimumZoomScale
        self.scrollView.maximumZoomScale = maximumZoomScale
        /// 重置ZoomScale
        self.setZoom(scale: minimumZoomScale, animated: false)
        /// 手动触发一次缩放
        if shouldFireDidZoomingManual {
            self.handleDidEndZooming()
        }
        /// 重置ContentOffset
        self.revertContentOffset(animated: false)
    }
    
}

extension ZoomView {
    
    private func createAssetView(for asset: any ZoomAsset) {
        guard self.assetView == nil else {
            return
        }
        guard let assetView = self.modifier.assetView(for: asset) else {
            return
        }
        assetView.isAccessibilityElement = true
        self.scrollView.addSubview(assetView)
        self.scrollView.sendSubviewToBack(assetView)
        self.assetView = assetView
    }
    
    private func createThumbnailView() {
        guard self.thumbnailView == nil else {
            return
        }
        guard let thumbnailView = self.modifier.thumbnailView() else {
            return
        }
        thumbnailView.isAccessibilityElement = true
        self.scrollView.addSubview(thumbnailView)
        self.scrollView.bringSubviewToFront(thumbnailView)
        self.thumbnailView = thumbnailView
    }
    
    private func updateThumbnailView() {
        guard let thumbnailView = self.thumbnailView else {
            return
        }
        thumbnailView.isHidden = self.thumbnail == nil || self.asset != nil
    }
    
}

extension ZoomView {
    
    private var calculateViewportRect: CGRect {
        return self.finalViewportRect
    }
    
    private func setNeedsRevertZoom() {
        self.isNeededRevertZoom = true
        self.setNeedsLayout()
    }
    
    private func revertZoomIfNeeded() {
        guard self.isNeededRevertZoom else {
            return
        }
        self.isNeededRevertZoom = false
        self.revertZooming()
    }
    
    private func handleDidEndZooming() {
        guard let contentView = self.contentView else {
            return
        }
        let viewport: CGRect = self.calculateViewportRect
        let contentViewFrame: CGRect = self.contentViewFrame
        var contentInset: UIEdgeInsets = UIEdgeInsets.zero
        contentInset.top = viewport.minY
        contentInset.left = viewport.minX
        contentInset.right = self.scrollView.bounds.width - viewport.maxX
        contentInset.bottom = self.scrollView.bounds.height - viewport.maxY
        if viewport.height >= contentViewFrame.height {
            contentInset.top = floor(viewport.midY - contentViewFrame.height / 2.0)
            contentInset.bottom = floor(self.scrollView.bounds.height - viewport.midY - contentViewFrame.height / 2.0)
        }
        if viewport.width >= contentViewFrame.width {
            contentInset.left = floor(viewport.midX - contentViewFrame.width / 2.0)
            contentInset.right = floor(self.scrollView.bounds.width - viewport.midX - contentViewFrame.width / 2.0)
        }
        self.scrollView.contentInset = contentInset
        self.scrollView.contentSize = contentView.frame.size
    }
    
    private func revertContentOffset(animated: Bool) {
        var x: CGFloat = self.scrollView.contentOffset.x
        var y: CGFloat = self.scrollView.contentOffset.y
        let viewport: CGRect = self.calculateViewportRect
        if let contentView = self.contentView, !viewport.isEmpty {
            if viewport.width < contentView.frame.width {
                x = (contentView.frame.width - viewport.width) / 2 - viewport.minX
            }
            if viewport.height < contentView.frame.height {
                y = -self.scrollView.contentInset.top
            }
        }
        self.scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
    }
    
}

extension ZoomView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.handleDidEndZooming()
    }
    
}
