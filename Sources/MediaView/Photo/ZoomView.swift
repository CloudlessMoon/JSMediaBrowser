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
    
    public var isEnabledZoom: Bool = true
    
    public var minimumZoomScale: CGFloat = 1.0 {
        didSet {
            self.scrollView.minimumZoomScale = self.minimumZoomScale
        }
    }
    
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
        scrollView.minimumZoomScale = self.minimumZoomScale
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
        
        let calculateLayout = { (view: UIView, mediaSize: CGSize) in
            guard JSCGSizeIsValidated(mediaSize) else {
                view.frame = .zero
                return
            }
            let viewport = self.calculateViewportRect
            let scale = {
                if mediaSize.width / mediaSize.height < viewport.size.width / viewport.size.height {
                    return viewport.size.height / mediaSize.height
                } else {
                    return viewport.size.width / mediaSize.width
                }
            }()
            view.frame = CGRect(
                x: self.bounds.minX,
                y: self.bounds.minY,
                width: mediaSize.width * scale * self.zoomScale,
                height: mediaSize.height * scale * self.zoomScale
            )
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
            return .zero
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
    
    public var zoomScale: CGFloat {
        return self.scrollView.zoomScale
    }
    
    public func setZoom(scale: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: JSCoreHelper.animationOptionsCurveOut) {
                self.scrollView.zoomScale = scale
            }
        } else {
            self.scrollView.zoomScale = scale
        }
    }
    
    public func zoom(to point: CGPoint, scale: CGFloat = 3.0, animated: Bool) {
        guard scale > 0 else {
            return
        }
        let minimumZoomScale = self.minimumZoomScale
        var zoomRect = CGRect.zero
        zoomRect.size.width = self.scrollView.frame.width / scale / minimumZoomScale
        zoomRect.size.height = self.scrollView.frame.height / scale / minimumZoomScale
        zoomRect.origin.x = point.x - zoomRect.width / 2
        zoomRect.origin.y = point.y - zoomRect.height / 2
        self.zoom(to: zoomRect, animated: animated)
    }
    
    public func zoom(to rect: CGRect, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: JSCoreHelper.animationOptionsCurveOut) {
                self.scrollView.zoom(to: rect, animated: false)
            }
        } else {
            self.scrollView.zoom(to: rect, animated: false)
        }
    }
    
    public func revertZooming() {
        if self.bounds.isEmpty {
            return
        }
        /// 重置ZoomScale
        self.setZoom(scale: self.minimumZoomScale, animated: false)
        /// 手动触发一次缩放
        if self.zoomScale == self.minimumZoomScale {
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
        let viewport = self.calculateViewportRect
        let contentViewFrame = self.contentView?.frame ?? .zero
        var contentInset = UIEdgeInsets.zero
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
        var x = self.scrollView.contentOffset.x
        var y = self.scrollView.contentOffset.y
        let viewport = self.calculateViewportRect
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
        guard self.isEnabledZoom else {
            return nil
        }
        return self.contentView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.handleDidEndZooming()
    }
    
}
