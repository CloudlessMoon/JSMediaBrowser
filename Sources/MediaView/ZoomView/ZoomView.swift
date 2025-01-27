//
//  ZoomView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import JSCoreKit

open class ZoomView: BasisMediaView {
    
    public var configuration: ZoomViewConfiguration
    
    public var eventHandler: ZoomViewEventHandler?
    
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
    
    public private(set) var assetView: (any ZoomAssetView)?
    
    public private(set) var thumbnailView: UIImageView?
    
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
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.scrollsToTop = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.minimumZoomScale = self.minimumZoomScale
        scrollView.maximumZoomScale = self.maximumZoomScale
        scrollView.delegate = self
        return scrollView
    }()
    
    private var isNeededRevertZoom: Bool = false
    
    public init(configuration: ZoomViewConfiguration, eventHandler: ZoomViewEventHandler? = nil) {
        self.configuration = configuration
        self.eventHandler = eventHandler
        
        super.init()
    }
    
    open override func didInitialize() {
        super.didInitialize()
        self.addSubview(self.scrollView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        /// scrollView.frame
        if self.scrollView.bounds.size != self.bounds.size {
            self.scrollView.frame = self.bounds
        }
        /// assetView
        if let assetView = self.assetView {
            let assetSize = {
                guard let asset = self.asset else {
                    return CGSize.zero
                }
                return asset.size
            }()
            assetView.frame = self.contentViewFrameThatFits(assetSize)
        }
        /// thumbnailView
        if let thumbnailView = self.thumbnailView {
            let thumbnailSize = {
                guard let thumbnail = self.thumbnail else {
                    return CGSize.zero
                }
                return thumbnail.size
            }()
            thumbnailView.frame = self.contentViewFrameThatFits(thumbnailSize)
        }
        /// scrollView.content
        if let contentView = self.contentView {
            let contentViewSize = contentView.frame.size
            let contentInset = self.contentInsetThatFits(contentViewSize)
            if self.scrollView.contentInset != contentInset {
                self.scrollView.contentInset = contentInset
            }
            if self.scrollView.contentSize != contentViewSize {
                self.scrollView.contentSize = contentViewSize
            }
        }
        
        self.revertZoomIfNeeded()
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
    
    public var isPlaying: Bool {
        if self.asset != nil, let assetView = self.assetView {
            return assetView.isPlaying
        } else if self.thumbnail != nil, let thumbnailView = self.thumbnailView {
            return thumbnailView.isAnimating
        } else {
            return false
        }
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
        let center = {
            let center = self.scrollView.center
            let contentOffset = self.scrollView.contentOffset
            return CGPoint(
                x: center.x + max((contentOffset.x - self.bounds.width) / 2, 0),
                y: center.y + max((contentOffset.y - self.bounds.height) / 2, 0)
            )
        }()
        self.zoom(to: center, scale: scale, animated: animated)
    }
    
    public func zoom(to point: CGPoint, scale: CGFloat, animated: Bool) {
        let minimumZoomScale = self.minimumZoomScale
        var zoomRect = CGRect.zero
        zoomRect.size.width = self.bounds.width / scale / minimumZoomScale
        zoomRect.size.height = self.bounds.height / scale / minimumZoomScale
        zoomRect.origin.x = point.x - zoomRect.width / 2
        zoomRect.origin.y = point.y - zoomRect.height / 2
        self.zoom(to: zoomRect, animated: animated)
    }
    
    public func zoom(to rect: CGRect, animated: Bool) {
        if animated {
            self.callWillBeginZooming()
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [JSCoreHelper.animationOptionsCurveIn]) {
                self.scrollView.zoom(to: rect, animated: false)
            } completion: { _ in
                self.callDidEndZooming()
            }
        } else {
            self.callWillBeginZooming()
            self.scrollView.zoom(to: rect, animated: false)
            self.callDidEndZooming()
        }
    }
    
    public func contentViewFrameThatFits(_ size: CGSize) -> CGRect {
        guard JSCGSizeIsValidated(size) else {
            return .zero
        }
        let contentSize = self.contentSizeThatFits(size)
        return CGRect(
            x: self.bounds.minX,
            y: self.bounds.minY,
            width: contentSize.width * self.zoomScale,
            height: contentSize.height * self.zoomScale
        )
    }
    
    public func contentSizeThatFits(_ size: CGSize) -> CGSize {
        guard JSCGSizeIsValidated(size) else {
            return .zero
        }
        let viewport = self.viewportRect
        let scale = {
            let height = size.width > viewport.width ? viewport.width * (size.height / size.width) : size.height
            if height > viewport.height {
                if size.width / size.height < viewport.width / viewport.height {
                    return viewport.width / size.width
                } else {
                    return viewport.height / size.height
                }
            } else {
                if size.width / size.height < viewport.width / viewport.height {
                    return viewport.height / size.height
                } else {
                    return viewport.width / size.width
                }
            }
        }()
        return CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
    }
    
    public func contentInsetThatFits(_ size: CGSize) -> UIEdgeInsets {
        guard JSCGSizeIsValidated(size) else {
            return .zero
        }
        let viewport = self.viewportRect
        var contentInset = UIEdgeInsets.zero
        contentInset.top = viewport.minY
        contentInset.left = viewport.minX
        contentInset.right = self.bounds.width - viewport.maxX
        contentInset.bottom = self.bounds.height - viewport.maxY
        if viewport.height >= size.height {
            contentInset.top = viewport.midY - size.height / 2.0
            contentInset.bottom = self.bounds.height - viewport.midY - size.height / 2.0
        }
        if viewport.width >= size.width {
            contentInset.left = viewport.midX - size.width / 2.0
            contentInset.right = self.bounds.width - viewport.midX - size.width / 2.0
        }
        return contentInset
    }
    
}

extension ZoomView {
    
    private func createAssetView(for asset: any ZoomAsset) {
        guard self.assetView == nil else {
            return
        }
        guard let assetView = self.configuration.assetView(asset) else {
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
        guard let thumbnailView = self.configuration.thumbnailView() else {
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
    
    private func setNeedsRevertZoom() {
        self.isNeededRevertZoom = true
        self.setNeedsLayout()
    }
    
    private func revertZoomIfNeeded() {
        guard self.isNeededRevertZoom && !self.bounds.isEmpty else {
            return
        }
        self.isNeededRevertZoom = false
        
        /// 重置zoomScale
        self.setZoom(scale: self.minimumZoomScale, animated: false)
        /// 重置contentOffset
        self.scrollView.contentOffset = self.scrollView.js_minimumContentOffset
    }
    
    private func callWillBeginZooming() {
        guard let assetView = self.assetView else {
            return
        }
        self.eventHandler?.willBeginZooming(assetView)
    }
    
    private func callDidEndZooming(at scale: CGFloat? = nil) {
        guard let assetView = self.assetView else {
            return
        }
        self.eventHandler?.didEndZooming(assetView, at: scale ?? self.zoomScale)
    }
    
    private func callDidZoom() {
        guard let assetView = self.assetView else {
            return
        }
        self.eventHandler?.didZoom(assetView)
    }
    
}

extension ZoomView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        guard self.isEnabledZoom else {
            return nil
        }
        return self.contentView
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.callWillBeginZooming()
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.callDidEndZooming(at: scale)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.callDidZoom()
    }
    
}
