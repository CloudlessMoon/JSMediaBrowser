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
    var transitionAnimatorViews: [UIView]? { get }
    
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
    
    private var imageView: UIImageView?
    
    private lazy var maskLayer: CALayer = {
        return CALayer()
    }()
    
    private var retainMaskLayer: CALayer?
    
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
    
    public func performAnimation(using transitionContext: UIViewControllerContextTransitioning, isEntering: Bool, completed: @escaping ((Bool) -> Void)) {
        guard let fromView = transitionContext.view(forKey: .from) ?? transitionContext.viewController(forKey: .from)?.view else {
            return
        }
        guard let toView = transitionContext.view(forKey: .to) ?? transitionContext.viewController(forKey: .to)?.view else {
            return
        }
        let currentView = isEntering ? toView : fromView
        let style = isEntering ? self.enteringStyle : self.exitingStyle
        switch style {
        case .zoom:
            self.zoomAnimate(in: currentView, isEntering: isEntering, completed: completed)
        case .fade:
            self.fadeAnimate(in: currentView, isEntering: isEntering, completed: completed)
        }
    }
    
}

extension TransitionAnimator {
    
    private func zoomAnimate(
        in view: UIView,
        isEntering: Bool,
        completed: @escaping (Bool) -> Void
    ) {
        let fadeAnimate = {
            self.fadeAnimate(in: view, isEntering: isEntering, completed: completed)
        }
        let source: (rect: CGRect, cornerRadius: CGFloat)? = {
            let transitionSourceView = self.delegate?.transitionSourceView
            let transitionSourceRect = self.delegate?.transitionSourceRect ?? .zero
            let cornerRadius = transitionSourceView?.layer.cornerRadius ?? 0
            var rect: CGRect
            if let transitionSourceView = transitionSourceView, transitionSourceRect.isEmpty {
                rect = view.convert(transitionSourceView.frame, from: transitionSourceView.superview)
            } else if !transitionSourceRect.isEmpty {
                rect = view.convert(transitionSourceRect, from: transitionSourceView)
            } else {
                rect = .zero
            }
            if !rect.isEmpty && !rect.intersects(view.bounds) {
                rect = .zero
            }
            guard !rect.isEmpty else {
                return nil
            }
            return (rect, cornerRadius)
        }()
        guard let source = source else {
            return fadeAnimate()
        }
        let target: (view: UIView, rect: CGRect)? = {
            guard let transitionTargetView = self.delegate?.transitionTargetView else {
                return nil
            }
            let rect = view.convert(transitionTargetView.frame, from: transitionTargetView.superview)
            guard !rect.isEmpty else {
                return nil
            }
            return (view, rect)
        }()
        guard let target = target else {
            return fadeAnimate()
        }
        guard let imageView = self.delegate?.transitionThumbnailView else {
            return fadeAnimate()
        }
        imageView.image = self.delegate?.transitionThumbnail
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.removeFromSuperview()
        view.addSubview(imageView)
        
        imageView.frame = isEntering ? source.rect : target.rect
        imageView.startAnimating()
        
        let animatorViews = self.delegate?.transitionAnimatorViews
        animatorViews?.forEach {
            $0.alpha = isEntering ? 0 : 1
        }
        
        self.retainMaskLayer = target.view.layer.mask
        target.view.layer.mask = self.maskLayer
        
        self.animate(
            isEntering: isEntering,
            animations: {
                imageView.frame = isEntering ? target.rect : source.rect
                imageView.layer.cornerRadius = isEntering ? 0 : source.cornerRadius
                
                animatorViews?.forEach {
                    $0.alpha = isEntering ? 1 : 0
                }
            },
            completed: {
                target.view.layer.mask = self.retainMaskLayer
                self.retainMaskLayer = nil
                
                imageView.removeFromSuperview()
                self.imageView = nil
                
                completed($0)
            }
        )
    }
    
    private func fadeAnimate(
        in view: UIView,
        isEntering: Bool,
        completed: @escaping (Bool) -> Void
    ) {
        view.alpha = isEntering ? 0 : 1
        self.animate(
            isEntering: isEntering,
            animations: {
                view.alpha = isEntering ? 1 : 0
            },
            completed: {
                view.alpha = 1
                
                completed($0)
            }
        )
    }
    
    private func animate(isEntering: Bool, animations: @escaping () -> Void, completed: @escaping (Bool) -> Void) {
        UIView.animate(
            withDuration: self.duration,
            delay: 0,
            options: isEntering ? .curveEaseInOut : .curveEaseOut,
            animations: animations,
            completion: completed
        )
    }
    
}
