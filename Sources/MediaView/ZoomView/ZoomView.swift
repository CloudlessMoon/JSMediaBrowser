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
        get {
            return self.assetView.asset
        }
        set {
            guard self.assetView.asset != newValue else {
                return
            }
            self.assetView.asset = newValue
            
            self.setNeedsRevertZoom()
        }
    }
    
    public var thumbnail: UIImage? {
        get {
            return self.assetView.thumbnail
        }
        set {
            guard self.assetView.thumbnail != newValue else {
                return
            }
            self.assetView.thumbnail = newValue
            
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
            self.updateMinimumZoomScale()
            self.updateMaximumZoomScale()
            self.setNeedsRevertZoom()
        }
    }
    
    public var minimumZoomScale: CGFloat {
        didSet {
            guard oldValue != self.minimumZoomScale else {
                return
            }
            self.updateMinimumZoomScale()
        }
    }
    
    public var maximumZoomScale: CGFloat {
        didSet {
            guard oldValue != self.maximumZoomScale else {
                return
            }
            self.updateMaximumZoomScale()
        }
    }
    
    private lazy var scrollView: ZoomScrollView = {
        let scrollView = ZoomScrollView()
        scrollView.delegate = self.delegator
        return scrollView
    }()
    
    private lazy var delegator: ScrollViewDelegator<AssetView> = {
        return ScrollViewDelegator(owner: self)
    }()
    
    fileprivate var isZoomInAnimation: Bool = false
    private var isNeededRevertZoom: Bool = false
    
    public init(
        assetView: AssetView,
        configuration: ZoomViewConfiguration = .init(),
        eventHandler: ZoomViewEventHandler? = nil
    ) {
        self.assetView = assetView
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
        
        self.updateMinimumZoomScale()
        self.updateMaximumZoomScale()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        /// scrollView.frame
        if self.scrollView.bounds.size != self.bounds.size {
            self.scrollView.frame = self.bounds
        }
        
        /// assetView
        let assetSize = self.assetView.sizeThatFits(self.bounds.size)
        self.assetView.frame = self.contentViewFrameThatFits(assetSize)
        
        /// scrollView.content
        let contentSize = self.assetView.frame.size
        let contentInset = self.contentInsetThatFits(contentSize)
        if self.scrollView.contentInset != contentInset {
            self.scrollView.contentInset = contentInset
        }
        if self.scrollView.contentSize != contentSize {
            self.scrollView.contentSize = contentSize
        }
        
        self.revertZoomIfNeeded()
    }
    
}

extension ZoomView {
    
    public var isPlaying: Bool {
        return self.assetView.isPlaying
    }
    
    public func startPlaying() {
        guard self.asset != nil && !self.assetView.isPlaying else {
            return
        }
        self.assetView.startPlaying()
    }
    
    public func stopPlaying() {
        guard self.assetView.isPlaying else {
            return
        }
        self.assetView.stopPlaying()
    }
    
    public var zoomScale: CGFloat {
        return self.scrollView.zoomScale
    }
    
    public var isZooming: Bool {
        return self.scrollView.isZooming
    }
    
    public var isZoomAnimating: Bool {
        return self.isZoomInAnimation
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
            self.isZoomInAnimation = true
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [JSCoreHelper.animationOptionsCurveIn]) {
                self.scrollView.zoom(to: rect, animated: false)
            } completion: { _ in
                self.isZoomInAnimation = false
                self.callDidEndZooming()
            }
        } else {
            self.callWillBeginZooming()
            self.scrollView.zoom(to: rect, animated: false)
            self.callDidEndZooming()
        }
    }
    
    public func setNeedsRevertZoom() {
        self.isNeededRevertZoom = true
        self.setNeedsLayout()
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
    
}

extension ZoomView {
    
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
    
    private func revertZoomIfNeeded() {
        guard self.isNeededRevertZoom && !self.bounds.isEmpty else {
            return
        }
        self.isNeededRevertZoom = false
        
        /// 重置zoomScale
        if self.zoomScale != self.minimumZoomScale {
            self.setZoom(scale: self.minimumZoomScale, animated: false)
        }
        /// 重置contentOffset
        if self.scrollView.contentOffset != self.minimumContentOffset {
            self.scrollView.contentOffset = self.minimumContentOffset
        }
    }
    
    private func updateMinimumZoomScale() {
        self.scrollView.minimumZoomScale = self.isEnabledZoom ? self.minimumZoomScale : 1.0
    }
    
    private func updateMaximumZoomScale() {
        self.scrollView.maximumZoomScale = self.isEnabledZoom ? self.maximumZoomScale : 1.0
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
        return owner.assetView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        guard let owner = self.owner else {
            return
        }
        owner.callWillBeginZooming()
        owner.isZoomInAnimation = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard let owner = self.owner else {
            return
        }
        owner.isZoomInAnimation = false
        owner.callDidEndZooming(at: scale)
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
