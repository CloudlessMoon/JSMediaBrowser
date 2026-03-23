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
    
    private weak var owner: MediaBrowserViewController?
    
    init(owner: MediaBrowserViewController) {
        self.owner = owner
        
        super.init()
    }
    
}

extension TransitionAdapter: UIViewControllerTransitioningDelegate, TransitionAnimatorDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.animator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.animator.wantsInteractiveStart ? self.animator : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.animator.wantsInteractiveStart ? self.animator : nil
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
        guard let cell = owner.currentPhotoCell else {
            return nil
        }
        let renderedImage = cell.photoView.renderedImage
        let thumbnail = cell.photoView.thumbnail ?? owner.dataSource[owner.currentPage].thumbnail
        
        let viewController = owner.navigationController ?? owner
        if viewController.isBeingPresented {
            return thumbnail ?? renderedImage
        } else {
            return renderedImage ?? thumbnail
        }
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
        guard let cell = owner.currentPhotoCell else {
            return nil
        }
        let assetView = cell.photoView.assetView
        return assetView
    }
    
    var transitionContainerView: UIView? {
        return self.owner?.contentView
    }
    
    var transitionMaskedView: UIView? {
        guard let owner = self.owner else {
            return nil
        }
        guard let cell = owner.currentPhotoCell else {
            return nil
        }
        return cell
    }
    
}
