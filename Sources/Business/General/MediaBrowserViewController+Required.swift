//
//  MediaBrowserViewController+Required.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2023/1/5.
//

import UIKit

public struct MediaBrowserViewControllerConfiguration {
    
    public typealias BuildZoomView = (Int) -> ZoomView
    public typealias BuildImageAssetMediator = (Int) -> ImageAssetMediator?
    public typealias BuildLivePhotoAssetMediator = (Int) -> LivePhotoAssetMediator?
    
    public var zoomView: BuildZoomView
    public var imageAssetMediator: BuildImageAssetMediator
    public var livePhotoAssetMediator: BuildLivePhotoAssetMediator
    
    public init(
        zoomView: @escaping BuildZoomView,
        imageAssetMediator: @escaping BuildImageAssetMediator,
        livePhotoAssetMediator: @escaping BuildLivePhotoAssetMediator
    ) {
        self.zoomView = zoomView
        self.imageAssetMediator = imageAssetMediator
        self.livePhotoAssetMediator = livePhotoAssetMediator
    }
    
}

public struct MediaBrowserViewControllerSourceProvider {
    
    public typealias SourceView = (Int) -> UIView?
    public typealias SourceRect = (Int) -> CGRect?
    
    public var sourceView: SourceView?
    public var sourceRect: SourceRect?
    
    public init(
        sourceView: SourceView? = nil,
        sourceRect: SourceRect? = nil
    ) {
        self.sourceView = sourceView
        self.sourceRect = sourceRect
    }
}

public protocol MediaBrowserViewControllerEventHandler {
    
    func willReloadData(_ dataSource: [AssetItem])
    
    func willDisplayZoomView(_ zoomView: ZoomView, at index: Int)
    func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int)
    
    func shouldStartPlaying(at index: Int) -> Bool
    
    func willScrollHalf(from sourceIndex: Int, to targetIndex: Int)
    func didScroll(to index: Int)
    
    func didSingleTouch()
    func didLongPressTouch()
    
}

public extension MediaBrowserViewControllerEventHandler {
    
    func willReloadData(_ dataSource: [AssetItem]) {}
    
    func willDisplayZoomView(_ zoomView: ZoomView, at index: Int) {}
    func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int) {}
    
    func shouldStartPlaying(at index: Int) -> Bool { true }
    
    func willScrollHalf(from sourceIndex: Int, to targetIndex: Int) {}
    func didScroll(to index: Int) {}
    
    func didSingleTouch() {}
    func didLongPressTouch() {}
    
}

public struct DefaultMediaBrowserViewControllerEventHandler: MediaBrowserViewControllerEventHandler {
    
    public typealias WillReloadData = ([AssetItem]) -> Void
    public typealias ShouldPlaying = (Int) -> Bool
    public typealias DisplayZoomView = (ZoomView, Int) -> Void
    public typealias DisplayEmptyView = (EmptyView, NSError, Int) -> Void
    public typealias WillScroll = (Int, Int) -> Void
    public typealias DidScroll = (Int) -> Void
    public typealias Touch = () -> Void
    
    private let _willReloadData: WillReloadData?
    private let _willDisplayZoomView: DisplayZoomView?
    private let _willDisplayEmptyView: DisplayEmptyView?
    private let _shouldStartPlaying: ShouldPlaying?
    private let _willScrollHalf: WillScroll?
    private let _didScroll: DidScroll?
    private let _didSingleTouch: Touch?
    private let _didLongPressTouch: Touch?
    
    public init(
        willReloadData: WillReloadData? = nil,
        willDisplayZoomView: DisplayZoomView? = nil,
        willDisplayEmptyView: DisplayEmptyView? = nil,
        shouldStartPlaying: ShouldPlaying? = nil,
        willScrollHalf: WillScroll? = nil,
        didScroll: DidScroll? = nil,
        didSingleTouch: Touch? = nil,
        didLongPressTouch: Touch? = nil
    ) {
        self._willReloadData = willReloadData
        self._willDisplayZoomView = willDisplayZoomView
        self._willDisplayEmptyView = willDisplayEmptyView
        self._shouldStartPlaying = shouldStartPlaying
        self._willScrollHalf = willScrollHalf
        self._didScroll = didScroll
        self._didSingleTouch = didSingleTouch
        self._didLongPressTouch = didLongPressTouch
    }
    
    public func willReloadData(_ dataSource: [AssetItem]) {
        self._willReloadData?(dataSource)
    }
    
    public func willScrollHalf(from sourceIndex: Int, to targetIndex: Int) {
        self._willScrollHalf?(sourceIndex, targetIndex)
    }
    
    public func didScroll(to index: Int) {
        self._didScroll?(index)
    }
    
    public func didSingleTouch() {
        self._didSingleTouch?()
    }
    
    public func didLongPressTouch() {
        self._didLongPressTouch?()
    }
    
    public func willDisplayZoomView(_ zoomView: ZoomView, at index: Int) {
        self._willDisplayZoomView?(zoomView, index)
    }
    
    public func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int) {
        self._willDisplayEmptyView?(emptyView, error, index)
    }
    
    public func shouldStartPlaying(at index: Int) -> Bool {
        return self._shouldStartPlaying?(index) ?? true
    }
    
}
