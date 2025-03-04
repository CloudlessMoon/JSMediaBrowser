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
    public var enteringStyle: TransitioningStyle
    public var exitingStyle: TransitioningStyle
    public var hideWhenSingleTap: Bool
    public var hideWhenSliding: Bool
    public var hideWhenSlidingDistance: CGFloat
    public var zoomWhenDoubleTap: Bool

    public init(
        zoomView: @escaping BuildZoomView,
        enteringStyle: TransitioningStyle = .zoom,
        exitingStyle: TransitioningStyle = .zoom,
        hideWhenSingleTap: Bool = true,
        hideWhenSliding: Bool = true,
        hideWhenSlidingDistance: CGFloat = 70,
        zoomWhenDoubleTap: Bool = true
    ) {
        self.zoomView = zoomView
        self.enteringStyle = enteringStyle
        self.exitingStyle = exitingStyle
        self.hideWhenSingleTap = hideWhenSingleTap
        self.hideWhenSliding = hideWhenSliding
        self.hideWhenSlidingDistance = hideWhenSlidingDistance
        self.zoomWhenDoubleTap = zoomWhenDoubleTap
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
    
    func didSingleTap(at index: Int, point: CGPoint)
    func didDoubleTap(at index: Int, point: CGPoint)
    func didLongPress(at index: Int, point: CGPoint)
    
}

public extension MediaBrowserViewControllerEventHandler {
    
    func didChangedData(current: [any AssetItem], previous: [any AssetItem]) {}
    
    func willDisplayZoomView(_ zoomView: ZoomView, at index: Int) {}
    func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int) {}
    
    func shouldStartPlaying(at index: Int) -> Bool { true }
    
    func willScrollHalf(from sourceIndex: Int, to targetIndex: Int) {}
    func didScroll(to index: Int) {}
    
    func didSingleTap(at index: Int, point: CGPoint) {}
    func didDoubleTap(at index: Int, point: CGPoint) {}
    func didLongPress(at index: Int, point: CGPoint) {}
    
}

public struct DefaultMediaBrowserViewControllerEventHandler: MediaBrowserViewControllerEventHandler {
    
    public typealias ChangedDataSource = ([any AssetItem], [any AssetItem]) -> Void
    public typealias ShouldPlaying = (Int) -> Bool
    public typealias DisplayZoomView = (ZoomView, Int) -> Void
    public typealias DisplayEmptyView = (EmptyView, NSError, Int) -> Void
    public typealias WillScroll = (Int, Int) -> Void
    public typealias DidScroll = (Int) -> Void
    public typealias DidTouch = (Int, CGPoint) -> Void
    
    private let _didChangedData: ChangedDataSource?
    private let _willDisplayZoomView: DisplayZoomView?
    private let _willDisplayEmptyView: DisplayEmptyView?
    private let _shouldStartPlaying: ShouldPlaying?
    private let _willScrollHalf: WillScroll?
    private let _didScroll: DidScroll?
    private let _didSingleTap: DidTouch?
    private let _didDoubleTap: DidTouch?
    private let _didLongPress: DidTouch?
    
    public init(
        didChangedData: ChangedDataSource? = nil,
        willDisplayZoomView: DisplayZoomView? = nil,
        willDisplayEmptyView: DisplayEmptyView? = nil,
        shouldStartPlaying: ShouldPlaying? = nil,
        willScrollHalf: WillScroll? = nil,
        didScroll: DidScroll? = nil,
        didSingleTap: DidTouch? = nil,
        didDoubleTap: DidTouch? = nil,
        didLongPress: DidTouch? = nil
    ) {
        self._didChangedData = didChangedData
        self._willDisplayZoomView = willDisplayZoomView
        self._willDisplayEmptyView = willDisplayEmptyView
        self._shouldStartPlaying = shouldStartPlaying
        self._willScrollHalf = willScrollHalf
        self._didScroll = didScroll
        self._didSingleTap = didSingleTap
        self._didDoubleTap = didDoubleTap
        self._didLongPress = didLongPress
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
    
    public func willDisplayZoomView(_ zoomView: ZoomView, at index: Int) {
        self._willDisplayZoomView?(zoomView, index)
    }
    
    public func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int) {
        self._willDisplayEmptyView?(emptyView, error, index)
    }
    
    public func shouldStartPlaying(at index: Int) -> Bool {
        return self._shouldStartPlaying?(index) ?? true
    }
    
    public func didSingleTap(at index: Int, point: CGPoint) {
        self._didSingleTap?(index, point)
    }
    
    public func didDoubleTap(at index: Int, point: CGPoint) {
        self._didDoubleTap?(index, point)
    }
    
    public func didLongPress(at index: Int, point: CGPoint) {
        self._didLongPress?(index, point)
    }
    
}
