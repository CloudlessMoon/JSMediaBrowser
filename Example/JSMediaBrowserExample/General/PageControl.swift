//
//  PageControl.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/24.
//

import UIKit
import JSCoreKit
import JSMediaBrowser
import SnapKit
import QMUIKit

@objc class PageControl: UIPageControl, ToolViewProtocol {
    
    weak var browserViewController: MediaBrowserViewController?
    weak var bottomConstraint: ConstraintMakerEditable?
    
    func didAddToSuperview(in viewController: MediaBrowserViewController) {
        self.browserViewController = viewController
        self.sourceItemsDidChange(in: viewController)
        if let browserView = viewController.browserView {
            self.currentPage = browserView.currentPage
        }
        self.snp.makeConstraints { (make) in
            make.width.equalTo(viewController.view.snp.width).multipliedBy(0.5)
            make.centerX.equalTo(viewController.view.snp.centerX)
            self.bottomConstraint = make.bottom.equalTo(viewController.view.snp.bottom)
            make.height.equalTo(30)
        }
        self.addTarget(self, action: #selector(self.handlePageControlEvent), for: .valueChanged)
    }
    
    func didLayoutSubviews(in viewController: MediaBrowserViewController) {
        let bottom = JSCoreHelper.isNotchedScreen ? viewController.view.qmui_safeAreaInsets.bottom : 20
        self.bottomConstraint?.offset(-bottom)
    }
    
    func sourceItemsDidChange(in viewController: MediaBrowserViewController) {
        if let sourceItems = viewController.sourceItems {
            self.numberOfPages = sourceItems.count
        }
    }
    
    func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController) {
        if let browserView = viewController.browserView {
            self.currentPage = browserView.currentPage
        }
    }
    
    @objc func handlePageControlEvent() -> Void {
        self.browserViewController?.browserView?.setCurrentPage(self.currentPage, animated: false)
    }
    
}
