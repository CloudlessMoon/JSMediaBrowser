//
//  ToolViewProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/24.
//

import UIKit

@objc(JSMediaBrowserToolViewProtocol)
public protocol ToolViewProtocol: NSObjectProtocol  {
    
    @objc(didAddToSuperviewInViewController:)
    func didAddToSuperview(in viewController: MediaBrowserViewController)
    
    @objc(didLayoutSubviewsInViewController:)
    optional func didLayoutSubviews(in viewController: MediaBrowserViewController)
    
    @objc(sourceItemsDidChangeInViewController:)
    optional func sourceItemsDidChange(in viewController: MediaBrowserViewController)
    
    @objc(willScrollHalfFromIndex:toIndex:inViewController:)
    optional func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController)
    
    @objc(didScrollToIndex:inViewController:)
    optional func didScrollTo(index: Int, in viewController: MediaBrowserViewController)
    
}
