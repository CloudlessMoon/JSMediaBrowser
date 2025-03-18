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
    var transitionMaskedView: UIView? { get }
    var transitionAnimatorViews: [UIView] { get }
    
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
        let containerView = transitionContext.containerView
        let style = isEntering ? self.enteringStyle : self.exitingStyle
        switch style {
        case .zoom:
            self.zoomAnimate(in: containerView, isEntering: isEntering, completed: completed)
        case .fade:
            self.fadeAnimate(in: containerView, isEntering: isEntering, completed: completed)
        }
    }
    
}

extension TransitionAnimator {
    
    private func zoomAnimate(
        in containerView: UIView,
        isEntering: Bool,
        completed: @escaping (Bool) -> Void
    ) {
        let fadeAnimate = {
            self.fadeAnimate(in: containerView, isEntering: isEntering, completed: completed)
        }
        let source: (rect: CGRect, cornerRadius: CGFloat)? = {
            let transitionSourceView = self.delegate?.transitionSourceView
            let transitionSourceRect = self.delegate?.transitionSourceRect ?? .zero
            let cornerRadius = transitionSourceView?.layer.cornerRadius ?? 0
            var rect: CGRect
            if let transitionSourceView = transitionSourceView, transitionSourceRect.isEmpty {
                rect = containerView.convert(transitionSourceView.frame, from: transitionSourceView.superview)
            } else if !transitionSourceRect.isEmpty {
                rect = containerView.convert(transitionSourceRect, from: transitionSourceView)
            } else {
                rect = .zero
            }
            if !rect.isEmpty && !rect.intersects(containerView.bounds) {
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
        let target: (maskedView: UIView, rect: CGRect)? = {
            guard let transitionTargetView = self.delegate?.transitionTargetView else {
                return nil
            }
            let rect = containerView.convert(transitionTargetView.frame, from: transitionTargetView.superview)
            guard !rect.isEmpty else {
                return nil
            }
            guard let transitionMaskedView = self.delegate?.transitionMaskedView else {
                return nil
            }
            return (transitionMaskedView, rect)
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
        containerView.addSubview(imageView)
        
        imageView.frame = isEntering ? source.rect : target.rect
        imageView.startAnimating()
        
        let transitionAnimatorViews = self.delegate?.transitionAnimatorViews
        if isEntering {
            transitionAnimatorViews?.forEach {
                $0.alpha = 0
            }
        }
        
        self.retainMaskLayer = target.maskedView.layer.mask
        target.maskedView.layer.mask = self.maskLayer
        
        self.animate(
            isEntering: isEntering,
            animations: {
                imageView.frame = isEntering ? target.rect : source.rect
                imageView.layer.cornerRadius = isEntering ? 0 : source.cornerRadius
                
                transitionAnimatorViews?.forEach {
                    $0.alpha = isEntering ? 1 : 0
                }
            },
            completed: {
                target.maskedView.layer.mask = self.retainMaskLayer
                self.retainMaskLayer = nil
                
                imageView.removeFromSuperview()
                
                completed($0)
            }
        )
    }
    
    private func fadeAnimate(
        in containerView: UIView,
        isEntering: Bool,
        completed: @escaping (Bool) -> Void
    ) {
        containerView.alpha = isEntering ? 0 : 1
        self.animate(
            isEntering: isEntering,
            animations: {
                containerView.alpha = isEntering ? 1 : 0
            },
            completed: {
                containerView.alpha = 1
                
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
