//
//  MediaBrowserViewController+Required.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2023/1/5.
//

import UIKit

public struct MediaBrowserViewControllerConfiguration {
    
    public typealias BuildZoomView = (Int) -> ZoomView
    
    public var zoomView: BuildZoomView
    
    public init(zoomView: @escaping BuildZoomView) {
        self.zoomView = zoomView
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
    
    func didChangedData(current: [any AssetItem], previous: [any AssetItem])
    
    func willDisplayZoomView(_ zoomView: ZoomView, at index: Int)
    func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int)
    
    func shouldStartPlaying(at index: Int) -> Bool
    
    func willScrollHalf(from sourceIndex: Int, to targetIndex: Int)
    func didScroll(to index: Int)
    
    func didSingleTouch()
    func didLongPressTouch()
    
}

public extension MediaBrowserViewControllerEventHandler {
    
    func didChangedData(current: [any AssetItem], previous: [any AssetItem]) {}
    
    func willDisplayZoomView(_ zoomView: ZoomView, at index: Int) {}
    func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int) {}
    
    func shouldStartPlaying(at index: Int) -> Bool { true }
    
    func willScrollHalf(from sourceIndex: Int, to targetIndex: Int) {}
    func didScroll(to index: Int) {}
    
    func didSingleTouch() {}
    func didLongPressTouch() {}
    
}

public struct DefaultMediaBrowserViewControllerEventHandler: MediaBrowserViewControllerEventHandler {
    
    public typealias ChangedDataSource = ([any AssetItem], [any AssetItem]) -> Void
    public typealias ShouldPlaying = (Int) -> Bool
    public typealias DisplayZoomView = (ZoomView, Int) -> Void
    public typealias DisplayEmptyView = (EmptyView, NSError, Int) -> Void
    public typealias WillScroll = (Int, Int) -> Void
    public typealias DidScroll = (Int) -> Void
    public typealias Touch = () -> Void
    
    private let _didChangedData: ChangedDataSource?
    private let _willDisplayZoomView: DisplayZoomView?
    private let _willDisplayEmptyView: DisplayEmptyView?
    private let _shouldStartPlaying: ShouldPlaying?
    private let _willScrollHalf: WillScroll?
    private let _didScroll: DidScroll?
    private let _didSingleTouch: Touch?
    private let _didLongPressTouch: Touch?
    
    public init(
        didChangedData: ChangedDataSource? = nil,
        willDisplayZoomView: DisplayZoomView? = nil,
        willDisplayEmptyView: DisplayEmptyView? = nil,
        shouldStartPlaying: ShouldPlaying? = nil,
        willScrollHalf: WillScroll? = nil,
        didScroll: DidScroll? = nil,
        didSingleTouch: Touch? = nil,
        didLongPressTouch: Touch? = nil
    ) {
        self._didChangedData = didChangedData
        self._willDisplayZoomView = willDisplayZoomView
        self._willDisplayEmptyView = willDisplayEmptyView
        self._shouldStartPlaying = shouldStartPlaying
        self._willScrollHalf = willScrollHalf
        self._didScroll = didScroll
        self._didSingleTouch = didSingleTouch
        self._didLongPressTouch = didLongPressTouch
    }
    
    public func didChangedData(current: [any AssetItem], previous: [any AssetItem]) {
        self._didChangedData?(current, previous)
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
