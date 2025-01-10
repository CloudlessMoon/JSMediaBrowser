//
//  ZoomView+Required.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/27.
//

import UIKit

public protocol ZoomViewModifier {
    
    func assetView(for asset: any ZoomAsset) -> (any ZoomAssetView)?
    
    func thumbnailView() -> UIImageView?
    
}

public protocol ZoomViewEventHandler {
    
    func didZoom(_ assetView: any ZoomAssetView)
    
    func willBeginZooming(_ assetView: any ZoomAssetView)
    
    func didEndZooming(_ assetView: any ZoomAssetView, at scale: CGFloat)
    
}

public extension ZoomViewEventHandler {
    
    func didZoom(_ assetView: any ZoomAssetView) {}
    
    func willBeginZooming(_ assetView: any ZoomAssetView) {}
    
    func didEndZooming(_ assetView: any ZoomAssetView, at scale: CGFloat) {}
    
}

public struct DefaultZoomViewEventHandler: ZoomViewEventHandler {
    
    public typealias DidZoom = (any ZoomAssetView) -> Void
    public typealias BeginZooming = (any ZoomAssetView) -> Void
    public typealias EndZooming = (any ZoomAssetView, CGFloat) -> Void
    
    private let _didZoom: DidZoom?
    private let _willBeginZooming: BeginZooming?
    private let _didEndZooming: EndZooming?
    
    public init(
        didZoom: DidZoom? = nil,
        willBeginZooming: BeginZooming? = nil,
        didEndZooming: EndZooming? = nil
    ) {
        self._didZoom = didZoom
        self._willBeginZooming = willBeginZooming
        self._didEndZooming = didEndZooming
    }
    
    public func didZoom(_ assetView: any ZoomAssetView) {
        self._didZoom?(assetView)
    }
    
    public func willBeginZooming(_ assetView: any ZoomAssetView) {
        self._willBeginZooming?(assetView)
    }
    
    public func didEndZooming(_ assetView: any ZoomAssetView, at scale: CGFloat) {
        self._didEndZooming?(assetView, scale)
    }
    
}
