//
//  MediaBrowserViewController+Required.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2023/1/5.
//

import UIKit

public struct MediaBrowserViewControllerConfiguration {
    
    public typealias BuildWebImageMediator = (Int) -> WebImageMediator
    public typealias BuildLivePhotoMediator = (Int) -> LivePhotoMediator
    public typealias BuildZoomViewModifier = (Int) -> ZoomViewModifier
    
    public var webImageMediator: BuildWebImageMediator
    public var livePhotoMediator: BuildLivePhotoMediator
    public var zoomViewModifier: BuildZoomViewModifier
    
    public init(
        webImageMediator: @escaping BuildWebImageMediator,
        livePhotoMediator: @escaping BuildLivePhotoMediator,
        zoomViewModifier: @escaping BuildZoomViewModifier
    ) {
        self.webImageMediator = webImageMediator
        self.livePhotoMediator = livePhotoMediator
        self.zoomViewModifier = zoomViewModifier
    }
    
}

public struct MediaBrowserViewControllerSourceReference {
    
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
    
    func willScrollHalf(from sourceIndex: Int, to targetIndex: Int)
    func didScroll(to index: Int)
    
    func didSingleTouch()
    func didLongPressTouch()
    
    func willDisplayZoomView(_ zoomView: ZoomView, at index: Int)
    func willDisplayVideoPlayerView(_ videoPlayerView: VideoPlayerView, at index: Int)
    func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int)
    
}

public extension MediaBrowserViewControllerEventHandler {
    
    func willReloadData(_ dataSource: [AssetItem]) {}
    
    func willScrollHalf(from sourceIndex: Int, to targetIndex: Int) {}
    func didScroll(to index: Int) {}
    
    func didSingleTouch() {}
    func didLongPressTouch() {}
    
    func willDisplayZoomView(_ zoomView: ZoomView, at index: Int) {}
    func willDisplayVideoPlayerView(_ videoPlayerView: VideoPlayerView, at index: Int) {}
    func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int) {}
    
}

public struct DefaultMediaBrowserViewControllerEventHandler: MediaBrowserViewControllerEventHandler {
    
    public typealias WillReloadData = ([AssetItem]) -> Void
    public typealias DisplayZoomView = (ZoomView, Int) -> Void
    public typealias DisplayVideoPlayerView = (VideoPlayerView, Int) -> Void
    public typealias DisplayEmptyView = (EmptyView, NSError, Int) -> Void
    public typealias WillScroll = (Int, Int) -> Void
    public typealias DidScroll = (Int) -> Void
    public typealias Touch = () -> Void
    
    private let _willReloadData: WillReloadData?
    private let _willDisplayZoomView: DisplayZoomView?
    private let _willDisplayVideoPlayerView: DisplayVideoPlayerView?
    private let _willDisplayEmptyView: DisplayEmptyView?
    private let _willScrollHalf: WillScroll?
    private let _didScroll: DidScroll?
    private let _didSingleTouch: Touch?
    private let _didLongPressTouch: Touch?
    
    public init(
        willReloadData: WillReloadData? = nil,
        willDisplayZoomView: DisplayZoomView? = nil,
        willDisplayVideoPlayerView: DisplayVideoPlayerView? = nil,
        willDisplayEmptyView: DisplayEmptyView? = nil,
        willScrollHalf: WillScroll? = nil,
        didScroll: DidScroll? = nil,
        didSingleTouch: Touch? = nil,
        didLongPressTouch: Touch? = nil
    ) {
        self._willReloadData = willReloadData
        self._willDisplayZoomView = willDisplayZoomView
        self._willDisplayVideoPlayerView = willDisplayVideoPlayerView
        self._willDisplayEmptyView = willDisplayEmptyView
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
    
    public func willDisplayVideoPlayerView(_ videoPlayerView: VideoPlayerView, at index: Int) {
        self._willDisplayVideoPlayerView?(videoPlayerView, index)
    }
    
    public func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int) {
        self._willDisplayEmptyView?(emptyView, error, index)
    }
    
}
