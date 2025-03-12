//
//  MediaBrowserViewController+Required.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2023/1/5.
//

import UIKit

public struct MediaBrowserViewControllerConfiguration {
    
    public var enteringStyle: TransitioningStyle
    public var exitingStyle: TransitioningStyle
    public var hideWhenSingleTap: Bool
    public var hideWhenSliding: Bool
    public var hideWhenSlidingDistance: CGFloat
    public var zoomWhenDoubleTap: Bool
    public var pageSpacing: CGFloat
    
    public init(
        enteringStyle: TransitioningStyle = .zoom,
        exitingStyle: TransitioningStyle = .zoom,
        hideWhenSingleTap: Bool = true,
        hideWhenSliding: Bool = true,
        hideWhenSlidingDistance: CGFloat = 70,
        zoomWhenDoubleTap: Bool = true,
        pageSpacing: CGFloat = 10
    ) {
        self.enteringStyle = enteringStyle
        self.exitingStyle = exitingStyle
        self.hideWhenSingleTap = hideWhenSingleTap
        self.hideWhenSliding = hideWhenSliding
        self.hideWhenSlidingDistance = hideWhenSlidingDistance
        self.zoomWhenDoubleTap = zoomWhenDoubleTap
        self.pageSpacing = pageSpacing
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
    
    func didChangedData(current: [any PhotoItem], previous: [any PhotoItem])
    
    func willDisplayPhotoCell(_ cell: PhotoCell, at index: Int)
    func didEndDisplayingPhotoCell(_ cell: PhotoCell, at index: Int)
    
    func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int)
    
    func shouldStartPlaying(at index: Int) -> Bool
    
    func willScrollHalf(from sourceIndex: Int, to targetIndex: Int)
    func didScroll(to index: Int)
    
    func didSingleTap(at index: Int, point: CGPoint)
    func didDoubleTap(at index: Int, point: CGPoint)
    func didLongPress(at index: Int, point: CGPoint)
    
}

public extension MediaBrowserViewControllerEventHandler {
    
    func didChangedData(current: [any PhotoItem], previous: [any PhotoItem]) {}
    
    func willDisplayPhotoCell(_ cell: PhotoCell, at index: Int) {}
    
    func didEndDisplayingPhotoCell(_ cell: PhotoCell, at index: Int) {}
    
    func willDisplayEmptyView(_ emptyView: EmptyView, with error: NSError, at index: Int) {}
    
    func shouldStartPlaying(at index: Int) -> Bool { true }
    
    func willScrollHalf(from sourceIndex: Int, to targetIndex: Int) {}
    func didScroll(to index: Int) {}
    
    func didSingleTap(at index: Int, point: CGPoint) {}
    func didDoubleTap(at index: Int, point: CGPoint) {}
    func didLongPress(at index: Int, point: CGPoint) {}
    
}

public struct DefaultMediaBrowserViewControllerEventHandler: MediaBrowserViewControllerEventHandler {
    
    public typealias ChangedDataSource = ([any PhotoItem], [any PhotoItem]) -> Void
    public typealias ShouldPlaying = (Int) -> Bool
    public typealias DisplayCell = (PhotoCell, Int) -> Void
    public typealias DisplayEmptyView = (EmptyView, NSError, Int) -> Void
    public typealias WillScroll = (Int, Int) -> Void
    public typealias DidScroll = (Int) -> Void
    public typealias DidTouch = (Int, CGPoint) -> Void
    
    private let _didChangedData: ChangedDataSource?
    private let _willDisplayPhotoCell: DisplayCell?
    private let _didEndDisplayingPhotoCell: DisplayCell?
    private let _willDisplayEmptyView: DisplayEmptyView?
    private let _shouldStartPlaying: ShouldPlaying?
    private let _willScrollHalf: WillScroll?
    private let _didScroll: DidScroll?
    private let _didSingleTap: DidTouch?
    private let _didDoubleTap: DidTouch?
    private let _didLongPress: DidTouch?
    
    public init(
        didChangedData: ChangedDataSource? = nil,
        willDisplayPhotoCell: DisplayCell? = nil,
        didEndDisplayingPhotoCell: DisplayCell? = nil,
        willDisplayEmptyView: DisplayEmptyView? = nil,
        shouldStartPlaying: ShouldPlaying? = nil,
        willScrollHalf: WillScroll? = nil,
        didScroll: DidScroll? = nil,
        didSingleTap: DidTouch? = nil,
        didDoubleTap: DidTouch? = nil,
        didLongPress: DidTouch? = nil
    ) {
        self._didChangedData = didChangedData
        self._willDisplayPhotoCell = willDisplayPhotoCell
        self._didEndDisplayingPhotoCell = didEndDisplayingPhotoCell
        self._willDisplayEmptyView = willDisplayEmptyView
        self._shouldStartPlaying = shouldStartPlaying
        self._willScrollHalf = willScrollHalf
        self._didScroll = didScroll
        self._didSingleTap = didSingleTap
        self._didDoubleTap = didDoubleTap
        self._didLongPress = didLongPress
    }
    
    public func didChangedData(current: [any PhotoItem], previous: [any PhotoItem]) {
        self._didChangedData?(current, previous)
    }
    
    public func willScrollHalf(from sourceIndex: Int, to targetIndex: Int) {
        self._willScrollHalf?(sourceIndex, targetIndex)
    }
    
    public func didScroll(to index: Int) {
        self._didScroll?(index)
    }
    
    public func willDisplayPhotoCell(_ cell: PhotoCell, at index: Int) {
        self._willDisplayPhotoCell?(cell, index)
    }
    
    public func didEndDisplayingPhotoCell(_ cell: PhotoCell, at index: Int) {
        self._didEndDisplayingPhotoCell?(cell, index)
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
