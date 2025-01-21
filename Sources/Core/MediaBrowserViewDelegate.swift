//
//  MediaBrowserViewDelegate.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public protocol MediaBrowserViewDelegate: AnyObject {
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forPageAt index: Int)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forPageAt index: Int)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willScrollHalfFrom sourceIndex: Int, to targetIndex: Int)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didScrollTo index: Int)
    
}

public protocol MediaBrowserViewGestureDelegate: AnyObject {
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, shouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool?
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool?
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool?
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPressTouch gestureRecognizer: UILongPressGestureRecognizer)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissingChanged gestureRecognizer: UIPanGestureRecognizer)
    
}
