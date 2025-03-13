//
//  ZoomView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import JSCoreKit

open class ZoomView<AssetView: ZoomAssetView>: BasisMediaView {
    
    public let configuration: ZoomViewConfiguration
    
    public var eventHandler: ZoomViewEventHandler?
    
    public let assetView: AssetView
    
    public var asset: AssetView.Asset? {
        didSet {
            guard self.assetView.asset != self.asset else {
                return
            }
            self.assetView.asset = self.asset
            
            self.updateThumbnailView()
            
            self.setNeedsRevertZoom()
        }
    }
    
    public let thumbnailView: UIImageView
    
    public var thumbnail: UIImage? {
        didSet {
            guard self.thumbnailView.image != self.thumbnail else {
                return
            }
            self.thumbnailView.image = self.thumbnail
            
            self.updateThumbnailView()
            
            self.setNeedsRevertZoom()
        }
    }
    
    public var assetMode: ZoomViewAssetMode {
        didSet {
            guard oldValue != self.assetMode else {
                return
            }
            self.setNeedsRevertZoom()
        }
    }
    
    public var isEnabledZoom: Bool {
        didSet {
            guard oldValue != self.isEnabledZoom else {
                return
            }
            self.setNeedsRevertZoom()
        }
    }
    
    public var minimumZoomScale: CGFloat {
        didSet {
            self.scrollView.minimumZoomScale = self.minimumZoomScale
        }
    }
    
    public var maximumZoomScale: CGFloat {
        didSet {
            self.scrollView.maximumZoomScale = self.maximumZoomScale
        }
    }
    
    private lazy var scrollView: ZoomScrollView = {
        let scrollView = ZoomScrollView()
        scrollView.minimumZoomScale = self.minimumZoomScale
        scrollView.maximumZoomScale = self.maximumZoomScale
        scrollView.delegate = self.delegator
        return scrollView
    }()
    
    private lazy var delegator: ScrollViewDelegator<AssetView> = {
        return ScrollViewDelegator(owner: self)
    }()
    
    private var isNeededRevertZoom: Bool = false
    
    public init(
        assetView: AssetView,
        thumbnailView: UIImageView,
        configuration: ZoomViewConfiguration = .init(),
        eventHandler: ZoomViewEventHandler? = nil
    ) {
        self.assetView = assetView
        self.thumbnailView = thumbnailView
        self.configuration = configuration
        self.assetMode = configuration.assetMode
        self.isEnabledZoom = configuration.isEnabledZoom
        self.minimumZoomScale = configuration.minimumZoomScale
        self.maximumZoomScale = configuration.maximumZoomScale
        
        self.eventHandler = eventHandler
        
        super.init()
    }
    
    open override func didInitialize() {
        super.didInitialize()
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.assetView)
        self.scrollView.addSubview(self.thumbnailView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        /// scrollView.frame
        if self.scrollView.bounds.size != self.bounds.size {
            self.scrollView.frame = self.bounds
        }
        
        /// assetView
        let assetSize = {
            guard let asset = self.asset else {
                return CGSize.zero
            }
            return asset.size
        }()
        self.assetView.frame = self.contentViewFrameThatFits(assetSize)
        
        /// thumbnailView
        let thumbnailSize = {
            guard let thumbnail = self.thumbnail else {
                return CGSize.zero
            }
            return thumbnail.size
        }()
        self.thumbnailView.frame = self.contentViewFrameThatFits(thumbnailSize)
        
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
    
    open override var contentView: UIView? {
        if self.asset != nil {
            return self.assetView
        } else if self.thumbnail != nil {
            return self.thumbnailView
        } else {
            return nil
        }
    }
    
    open override var contentViewFrame: CGRect {
        guard let contentView = self.contentView else {
            return .zero
        }
        return self.convert(contentView.frame, from: contentView.superview)
    }
    
}

extension ZoomView {
    
    public var isPlaying: Bool {
        if self.asset != nil {
            return self.assetView.isPlaying
        } else if self.thumbnail != nil {
            return self.thumbnailView.isAnimating
        } else {
            return false
        }
    }
    
    public func startPlaying() {
        if self.asset != nil, !self.assetView.isPlaying {
            self.assetView.startPlaying()
        } else if self.thumbnail != nil, !self.thumbnailView.isAnimating {
            self.thumbnailView.startAnimating()
        }
    }
    
    public func stopPlaying() {
        if self.assetView.isPlaying {
            self.assetView.stopPlaying()
        }
        if self.thumbnailView.isAnimating {
            self.thumbnailView.stopAnimating()
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
        let contentSize = self.contentSizeThatFits(size)
        return CGRect(
            x: self.bounds.minX,
            y: self.bounds.minY,
            width: JSFloorPixelValue(contentSize.width * self.zoomScale),
            height: JSFloorPixelValue(contentSize.height * self.zoomScale)
        )
    }
    
    public func contentSizeThatFits(_ size: CGSize) -> CGSize {
        let size = self.assetSize(with: size)
        return CGSize(
            width: JSFloorPixelValue(size.width),
            height: JSFloorPixelValue(size.height)
        )
    }
    
    public func contentInsetThatFits(_ size: CGSize) -> UIEdgeInsets {
        let contentInset = self.assetInset(with: size)
        return UIEdgeInsets(
            top: JSFloorPixelValue(contentInset.top),
            left: JSFloorPixelValue(contentInset.left),
            bottom: JSFloorPixelValue(contentInset.bottom),
            right: JSFloorPixelValue(contentInset.right))
    }
    
    public var contentOffset: CGPoint {
        return self.scrollView.contentOffset
    }
    
    public var minimumContentOffset: CGPoint {
        return self.scrollView.js_minimumContentOffset
    }
    
    public var maximumContentOffset: CGPoint {
        return self.scrollView.js_maximumContentOffset
    }
    
    public var isTracking: Bool {
        return self.scrollView.isTracking
    }
    
    public var isDragging: Bool {
        return self.scrollView.isDragging
    }
    
    public var isDecelerating: Bool {
        return self.scrollView.isDecelerating
    }
    
}

extension ZoomView {
    
    private func updateThumbnailView() {
        self.thumbnailView.isHidden = self.thumbnail == nil || self.asset != nil
    }
    
    private func assetSize(with size: CGSize) -> CGSize {
        guard JSCGSizeIsValidated(size) else {
            return .zero
        }
        let viewport = self.viewportRect
        guard JSCGSizeIsValidated(viewport.size) else {
            return .zero
        }
        let sizeRatio = size.width / size.height
        let aspectFill = {
            return CGSize(
                width: viewport.width,
                height: viewport.width / sizeRatio
            )
        }
        let aspectFit = {
            guard size.width > viewport.width || size.height > viewport.height else {
                return size
            }
            let viewportRatio = viewport.width / viewport.height
            if sizeRatio < viewportRatio {
                return CGSize(
                    width: viewport.height * sizeRatio,
                    height: viewport.height
                )
            } else {
                return aspectFill()
            }
        }
        switch self.assetMode {
        case .automatic:
            let height = size.width > viewport.width ? aspectFill().height : size.height
            if height > viewport.height {
                return aspectFill()
            } else {
                return aspectFit()
            }
        case .aspectFill:
            return aspectFill()
        case .aspectFit:
            return aspectFit()
        }
    }
    
    private func assetInset(with size: CGSize) -> UIEdgeInsets {
        guard JSCGSizeIsValidated(size) else {
            return .zero
        }
        let viewport = self.viewportRect
        guard JSCGSizeIsValidated(viewport.size) else {
            return .zero
        }
        var contentInset = UIEdgeInsets.zero
        if viewport.width >= size.width {
            contentInset.left = viewport.midX - size.width / 2.0
            contentInset.right = self.bounds.width - viewport.midX - size.width / 2.0
        } else {
            contentInset.left = viewport.minX
            contentInset.right = self.bounds.width - viewport.maxX
        }
        if viewport.height >= size.height {
            contentInset.top = viewport.midY - size.height / 2.0
            contentInset.bottom = self.bounds.height - viewport.midY - size.height / 2.0
        } else {
            contentInset.top = viewport.minY
            contentInset.bottom = self.bounds.height - viewport.maxY
        }
        return contentInset
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
    
    fileprivate func callWillBeginZooming() {
        self.eventHandler?.willBeginZooming()
    }
    
    fileprivate func callDidEndZooming(at scale: CGFloat? = nil) {
        self.eventHandler?.didEndZooming(at: scale ?? self.zoomScale)
    }
    
    fileprivate func callDidZoom() {
        self.eventHandler?.didZoom()
    }
    
}

private final class ScrollViewDelegator<View: ZoomAssetView>: NSObject, UIScrollViewDelegate {
    
    private weak var owner: ZoomView<View>?
    
    init(owner: ZoomView<View>) {
        self.owner = owner
        
        super.init()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        guard let owner = self.owner else {
            return nil
        }
        guard owner.isEnabledZoom else {
            return nil
        }
        return owner.contentView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.owner?.callWillBeginZooming()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.owner?.callDidEndZooming(at: scale)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let owner = self.owner else {
            return
        }
        owner.setNeedsLayout()
        owner.layoutIfNeeded()
        
        owner.callDidZoom()
    }
    
}
