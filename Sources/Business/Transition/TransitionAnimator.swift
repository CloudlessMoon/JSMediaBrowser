//
//  TransitionAnimator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit
import JSCoreKit

public protocol TransitionAnimatorDelegate: AnyObject {
    
    var transitionThumbnail: UIImage? { get }
    var transitionThumbnailView: UIImageView? { get }
    var transitionSourceView: UIView? { get }
    var transitionSourceRect: CGRect { get }
    var transitionTargetView: UIView? { get }
    var transitionTargetFrame: CGRect { get }
    var transitionAnimatorViews: [UIView]? { get }
    
    func transitionViewWillMoveToSuperview(_ transitionView: UIView)
    
}

public enum TransitioningStyle: Equatable {
    case zoom
    case fade
}

public final class TransitionAnimator: Transitioner {
    
    public weak var delegate: TransitionAnimatorDelegate?
    
    public var duration: TimeInterval = 0.25
    
    public var enteringStyle: TransitioningStyle = .zoom
    
    public var exitingStyle: TransitioningStyle = .zoom
    
    private static let animationGroupKey = "AnimationGroupKey"
    
    private var imageView: UIImageView?
    
    public override init() {
        super.init()
    }
    
}

extension TransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let isEntering = self.type == .presenting
        
        self.beginTransition(transitionContext, isEntering: isEntering)
        self.performAnimation(using: transitionContext, isEntering: isEntering) { finished in
            self.endTransition(transitionContext)
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
}

extension TransitionAnimator {
    
    public func performAnimation(using transitionContext: UIViewControllerContextTransitioning, isEntering: Bool, completion: @escaping ((Bool) -> Void)) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        guard let fromView = transitionContext.view(forKey: .from) ?? fromViewController.view else {
            return
        }
        guard let toView = transitionContext.view(forKey: .to) ?? toViewController.view else {
            return
        }
        let currentView = isEntering ? toView : fromView
        
        var style = isEntering ? self.enteringStyle : self.exitingStyle
        var sourceCornerRadius: CGFloat
        var sourceRect: CGRect
        if style == .zoom {
            let transitionSourceView = self.delegate?.transitionSourceView
            let transitionSourceRect = self.delegate?.transitionSourceRect ?? .zero
            
            if let transitionSourceView = transitionSourceView, transitionSourceRect.isEmpty {
                sourceRect = currentView.convert(transitionSourceView.frame, from: transitionSourceView.superview)
            } else if !transitionSourceRect.isEmpty {
                sourceRect = currentView.convert(transitionSourceRect, from: transitionSourceView)
            } else {
                sourceRect = .zero
            }
            if !sourceRect.isEmpty && !sourceRect.intersects(currentView.bounds) {
                sourceRect = .zero
            }
            sourceCornerRadius = transitionSourceView?.layer.cornerRadius ?? 0
        } else {
            sourceRect = .zero
            sourceCornerRadius = 0
        }
        
        let targetView = self.delegate?.transitionTargetView
        let targetFrame = {
            let rect = currentView.convert(self.delegate?.transitionTargetFrame ?? .zero, from: targetView)
            return CGRect(origin: JSCGPointRoundPixelValue(rect.origin), size: JSCGSizeCeilPixelValue(rect.size))
        }()
        
        /// 判断是否可以zoom
        if style == .zoom && (sourceRect.isEmpty || targetFrame.isEmpty) {
            style = .fade
        }
        
        if style == .zoom, let imageView = self.delegate?.transitionThumbnailView {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.removeFromSuperview()
            self.delegate?.transitionViewWillMoveToSuperview(imageView)
            if imageView.superview == nil {
                transitionContext.containerView.addSubview(imageView)
            }
            self.imageView = imageView
        }
        if self.imageView == nil {
            style = .fade
        }
        
        if style == .fade {
            currentView.alpha = isEntering ? 0 : 1
        } else if style == .zoom, let imageView = self.imageView {
            /// 隐藏目标视图
            targetView?.isHidden = true
            /// 设置下Frame
            imageView.image = self.delegate?.transitionThumbnail
            imageView.frame = isEntering ? sourceRect : targetFrame
            imageView.startAnimating()
        }
        if isEntering {
            self.delegate?.transitionAnimatorViews?.forEach { subview in
                subview.alpha = 0.0
            }
        }
        UIView.animate(withDuration: self.duration, delay: 0, options: isEntering ? .curveEaseInOut : .curveEaseOut) {
            if style == .fade {
                currentView.alpha = isEntering ? 1 : 0
            } else if style == .zoom, let imageView = self.imageView {
                imageView.frame = isEntering ? targetFrame : sourceRect
                imageView.layer.cornerRadius = isEntering ? 0 : sourceCornerRadius
            }
            self.delegate?.transitionAnimatorViews?.forEach { subview in
                subview.alpha = isEntering ? 1 : 0
            }
        } completion: { (finished) in
            if style == .fade {
                currentView.alpha = 1
            } else if style == .zoom {
                targetView?.isHidden = false
            }
            if let imageView = self.imageView {
                imageView.removeFromSuperview()
                self.imageView = nil
            }
            
            completion(finished)
        }
    }
    
}

extension TransitionAnimator {
    
}
