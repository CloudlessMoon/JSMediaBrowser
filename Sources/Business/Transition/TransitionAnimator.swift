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
    var transitionContainerView: UIView? { get }
    var transitionMaskedView: UIView? { get }
    var transitionAnimatorViews: [UIView] { get }
    
}

public enum TransitioningStyle: Equatable {
    case zoom
    case fade
}

public final class TransitionAnimator: Transitioner {
    
    public var duration: TimeInterval = 0.25
    
    public var appearStyle: TransitioningStyle = .zoom
    
    public var disappearStyle: TransitioningStyle = .zoom
    
    private lazy var maskLayer: CALayer = {
        return CALayer()
    }()
    
    private var retainMaskLayer: CALayer?
    
    private weak var delegate: TransitionAnimatorDelegate?
    
    public init(delegate: TransitionAnimatorDelegate) {
        self.delegate = delegate
        
        super.init()
    }
    
}

extension TransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.beginTransition(transitionContext)
        self.performAnimation(using: transitionContext) { finished in
            self.endTransition(transitionContext)
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
}

extension TransitionAnimator {
    
    public func performAnimation(
        using transitionContext: UIViewControllerContextTransitioning,
        completed: @escaping ((Bool) -> Void)
    ) {
        let isAppear = self.type == .presenting
        let containerView = transitionContext.containerView
        let style = isAppear ? self.appearStyle : self.disappearStyle
        switch style {
        case .zoom:
            self.zoomAnimate(in: containerView, isAppear: isAppear, completed: completed)
        case .fade:
            self.fadeAnimate(in: containerView, isAppear: isAppear, completed: completed)
        }
    }
    
}

extension TransitionAnimator {
    
    private func zoomAnimate(
        in containerView: UIView,
        isAppear: Bool,
        completed: @escaping (Bool) -> Void
    ) {
        let fadeAnimate = {
            self.fadeAnimate(in: containerView, isAppear: isAppear, completed: completed)
        }
        guard let transitionContainerView = self.delegate?.transitionContainerView else {
            return fadeAnimate()
        }
        let source: (rect: CGRect, cornerRadius: CGFloat)? = {
            let transitionSourceView = self.delegate?.transitionSourceView
            let transitionSourceRect = self.delegate?.transitionSourceRect ?? .zero
            let cornerRadius = transitionSourceView?.layer.cornerRadius ?? 0
            var rect: CGRect
            if let transitionSourceView = transitionSourceView, transitionSourceRect.isEmpty {
                rect = transitionContainerView.convert(transitionSourceView.frame, from: transitionSourceView.superview)
            } else if !transitionSourceRect.isEmpty {
                rect = transitionContainerView.convert(transitionSourceRect, from: transitionSourceView)
            } else {
                rect = .zero
            }
            if !rect.isEmpty && !rect.intersects(transitionContainerView.bounds) {
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
            let rect = transitionContainerView.convert(transitionTargetView.frame, from: transitionTargetView.superview)
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
        transitionContainerView.addSubview(imageView)
        
        imageView.frame = isAppear ? source.rect : target.rect
        imageView.stopAnimating()
        
        let transitionAnimatorViews = self.delegate?.transitionAnimatorViews
        if isAppear {
            transitionAnimatorViews?.forEach {
                $0.alpha = 0
            }
        }
        
        self.retainMaskLayer = target.maskedView.layer.mask
        target.maskedView.layer.mask = self.maskLayer
        
        self.animate(
            isAppear: isAppear,
            animations: {
                imageView.frame = isAppear ? target.rect : source.rect
                imageView.layer.cornerRadius = isAppear ? 0 : source.cornerRadius
                
                transitionAnimatorViews?.forEach {
                    $0.alpha = isAppear ? 1 : 0
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
        isAppear: Bool,
        completed: @escaping (Bool) -> Void
    ) {
        containerView.alpha = isAppear ? 0 : 1
        self.animate(
            isAppear: isAppear,
            animations: {
                containerView.alpha = isAppear ? 1 : 0
            },
            completed: {
                containerView.alpha = 1
                
                completed($0)
            }
        )
    }
    
    private func animate(isAppear: Bool, animations: @escaping () -> Void, completed: @escaping (Bool) -> Void) {
        UIView.animate(
            withDuration: self.duration,
            delay: 0,
            options: isAppear ? .curveEaseInOut : .curveEaseOut,
            animations: animations,
            completion: completed
        )
    }
    
}
