//
//  TransitionAdapter.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/19.
//

import UIKit
import JSCoreKit

internal final class TransitionAdapter: NSObject {
    
    private(set) lazy var animator: TransitionAnimator = {
        return TransitionAnimator(delegate: self)
    }()
    
    private(set) lazy var interactiver: TransitionInteractiver = {
        return TransitionInteractiver()
    }()
    
    private weak var owner: MediaBrowserViewController?
    
    init(owner: MediaBrowserViewController) {
        self.owner = owner
        
        super.init()
    }
    
}

extension TransitionAdapter {
    
    private func animator(type: TransitionerType) -> TransitionAnimator? {
        let animator = self.animator
        animator.type = type
        return animator
    }
    
    private func interactiver(type: TransitionerType) -> TransitionInteractiver? {
        let interactiver = self.interactiver
        interactiver.type = type
        
        guard interactiver.wantsInteractiveStart else {
            return nil
        }
        return interactiver
    }
    
}

extension TransitionAdapter: UIViewControllerTransitioningDelegate, TransitionAnimatorDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.animator(type: .presenting)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.animator(type: .dismiss)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactiver(type: .presenting)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactiver(type: .dismiss)
    }
    
    var transitionThumbnailView: UIImageView? {
        guard let owner = self.owner else {
            return nil
        }
        let item = owner.dataSource[owner.currentPage]
        return item.builder.createTransitionView()
    }
    
    var transitionThumbnail: UIImage? {
        guard let owner = self.owner else {
            return nil
        }
        if let cell = owner.currentPageCell as? PhotoCell {
            let renderedImage = cell.photoView.renderedImage
            let thumbnail = cell.photoView.thumbnail ?? owner.dataSource[owner.currentPage].thumbnail
            switch self.animator.type {
            case .presenting:
                return thumbnail ?? renderedImage
            case .dismiss:
                return renderedImage ?? thumbnail
            }
        }
        return nil
    }
    
    var transitionSourceView: UIView? {
        guard let owner = self.owner else {
            return nil
        }
        return owner.sourceProvider?.sourceView?(owner.currentPage)
    }
    
    var transitionSourceRect: CGRect {
        guard let owner = self.owner else {
            return .zero
        }
        return owner.sourceProvider?.sourceRect?(owner.currentPage) ?? .zero
    }
    
    var transitionTargetView: UIView? {
        guard let owner = self.owner else {
            return nil
        }
        if let cell = owner.currentPageCell as? PhotoCell {
            let assetView = cell.photoView.assetView
            return assetView
        }
        return nil
    }
    
    var transitionContainerView: UIView? {
        return self.owner?.contentView
    }
    
    var transitionMaskedView: UIView? {
        if let cell = self.owner?.currentPageCell as? PhotoCell {
            return cell
        }
        return nil
    }
    
    var transitionAnimatorViews: [UIView] {
        guard let owner = self.owner else {
            return []
        }
        var views: [UIView] = []
        if let dimmingView = owner.dimmingView {
            views.append(dimmingView)
        }
        owner.viewIfLoaded?.subviews.forEach {
            guard $0 != self.transitionContainerView else {
                return
            }
            views.append($0)
        }
        return views
    }
    
}
