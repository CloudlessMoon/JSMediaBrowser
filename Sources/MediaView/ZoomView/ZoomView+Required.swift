//
//  ZoomView+Required.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/27.
//

import UIKit

public struct ZoomViewConfiguration {
    
    public var assetMode: ZoomViewAssetMode
    public var isEnabledZoom: Bool
    public var minimumZoomScale: CGFloat
    public var maximumZoomScale: CGFloat
    
    public init(
        assetMode: ZoomViewAssetMode = .automatic,
        isEnabledZoom: Bool = true,
        minimumZoomScale: CGFloat = 1.0,
        maximumZoomScale: CGFloat = 2.0
    ) {
        self.assetMode = assetMode
        self.isEnabledZoom = isEnabledZoom
        self.minimumZoomScale = minimumZoomScale
        self.maximumZoomScale = maximumZoomScale
    }
    
}

public protocol ZoomViewEventHandler {
    
    func didZoom()
    
    func willBeginZooming()
    
    func didEndZooming(at scale: CGFloat)
    
}

public extension ZoomViewEventHandler {
    
    func didZoom() {}
    
    func willBeginZooming() {}
    
    func didEndZooming(at scale: CGFloat) {}
    
}

public enum ZoomViewAssetMode: Equatable {
    case automatic
    case aspectFill
    case aspectFit
}

public struct DefaultZoomViewEventHandler: ZoomViewEventHandler {
    
    public typealias Zoom = () -> Void
    public typealias EndZooming = (CGFloat) -> Void
    
    private let _didZoom: Zoom?
    private let _willBeginZooming: Zoom?
    private let _didEndZooming: EndZooming?
    
    public init(
        didZoom: Zoom? = nil,
        willBeginZooming: Zoom? = nil,
        didEndZooming: EndZooming? = nil
    ) {
        self._didZoom = didZoom
        self._willBeginZooming = willBeginZooming
        self._didEndZooming = didEndZooming
    }
    
    public func didZoom() {
        self._didZoom?()
    }
    
    public func willBeginZooming() {
        self._willBeginZooming?()
    }
    
    public func didEndZooming(at scale: CGFloat) {
        self._didEndZooming?(scale)
    }
    
}
