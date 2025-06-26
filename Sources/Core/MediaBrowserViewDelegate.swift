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
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didSingleTapAt index: Int, point: CGPoint)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didDoubleTapAt index: Int, point: CGPoint)
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didLongPressAt index: Int, point: CGPoint)
    
    func mediaBrowserViewDidScroll(_ mediaBrowserView: MediaBrowserView)
    
    func mediaBrowserViewWillBeginDragging(_ mediaBrowserView: MediaBrowserView)
    
    func mediaBrowserViewDidEndDragging(_ mediaBrowserView: MediaBrowserView, willDecelerate decelerate: Bool)
    
    func mediaBrowserViewDidEndDecelerating(_ mediaBrowserView: MediaBrowserView)
    
}
