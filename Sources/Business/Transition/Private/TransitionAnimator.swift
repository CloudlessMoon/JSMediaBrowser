//
//  TransitionAnimator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit
import JSCoreKit

protocol TransitionAnimatorDelegate: AnyObject {
    
    var transitionThumbnail: UIImage? { get }
    var transitionThumbnailView: UIImageView? { get }
    var transitionSourceView: UIView? { get }
    var transitionSourceRect: CGRect { get }
    var transitionTargetView: UIView? { get }
    var transitionContainerView: UIView? { get }
    var transitionMaskedView: UIView? { get }
    
}

final class TransitionAnimator: NSObject {
    
    let duration: TimeInterval = 0.25
    
    private(set) weak var context: UIViewControllerContextTransitioning?
    
    private lazy var maskLayer: CALayer = {
        return CALayer()
    }()
    
    private var retainMaskLayer: CALayer?
    
    private var isInteractive: Bool = false
    
    private var prepares: [TransitionContextCaller] = []
    private var animatings: [TransitionContextCaller] = []
    private var completions: [TransitionContextCaller] = []
    
    private weak var delegate: TransitionAnimatorDelegate?
    
    init(delegate: TransitionAnimatorDelegate) {
        self.delegate = delegate
        
        super.init()
    }
    
}

extension TransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.context = transitionContext
        
        let isAppear = self.isAppear
        let type: TransitionType = isAppear ? .appear(style: .zoom) : .disappear(style: .zoom)
        self.beginTransition(type: type)
        self.performAnimation(type: type)
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
}

extension TransitionAnimator: UIViewControllerInteractiveTransitioning {
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.context = transitionContext
        
        if self.isInteractive {
            let isAppear = self.isAppear
            let type: TransitionType = isAppear ? .appear(style: .zoom) : .disappear(style: .zoom)
            self.beginTransition(type: type)
        } else {
            DispatchQueue.main.async {
                self.cancelInteractive()
                self.endTransition()
            }
        }
    }
    
    var wantsInteractiveStart: Bool {
        return self.isInteractive
    }
    
}

extension TransitionAnimator {
    
    func performAnimation(type: TransitionType) {
        switch type.style {
        case .zoom:
            self.zoomAnimate()
        case .fade:
            self.fadeAnimate()
        }
    }
    
    func animate(type: TransitionType, animations: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let context = self.context else {
            assertionFailure()
            return
        }
        let isCancelled = context.transitionWasCancelled
        let isInteractive = context.isInteractive
        
        self.notifyPrepares(.init(
            type: type,
            isInteractive: isInteractive,
            percentComplete: 0,
            isCancelled: isCancelled
        ))
        
        UIView.animate(
            withDuration: self.duration,
            delay: 0,
            options: type.isAppear ? .curveEaseInOut : .curveEaseOut,
            animations: {
                animations()
                
                self.notifyAnimatings(.init(
                    type: type,
                    isInteractive: isInteractive,
                    percentComplete: 0,
                    isCancelled: isCancelled
                ))
            },
            completion: { _ in
                completion()
                
                self.notifyCompletions(.init(
                    type: type,
                    isInteractive: isInteractive,
                    percentComplete: 1,
                    isCancelled: isCancelled
                ))
                
                self.endTransition()
            }
        )
    }
    
    func add(
        prepare: @escaping TransitionContextCaller,
        animating: @escaping TransitionContextCaller,
        completion: @escaping TransitionContextCaller
    ) {
        self.prepares.append(prepare)
        self.animatings.append(animating)
        self.completions.append(completion)
    }
    
    func notifyPrepares(_ context: TransitionContext) {
        for prepares in self.prepares {
            prepares(context)
        }
    }
    
    func notifyAnimatings(_ context: TransitionContext) {
        for animating in self.animatings {
            animating(context)
        }
    }
    
    func notifyCompletions(_ context: TransitionContext) {
        for completion in self.completions {
            completion(context)
        }
    }
    
    func resetAnimations() {
        self.prepares.removeAll()
        self.animatings.removeAll()
        self.completions.removeAll()
    }
    
}

extension TransitionAnimator {
    
    func beginInteractive(type: TransitionType) {
        self.checkInteractiveEnd()
        
        self.isInteractive = true
        
        self.notifyPrepares(.init(
            type: type,
            isInteractive: true,
            percentComplete: 0,
            isCancelled: false
        ))
    }
    
    func updateInteractive(type: TransitionType, _ percentComplete: CGFloat) {
        self.checkInteractiveBegan()
        
        guard let context = self.context else {
            assertionFailure()
            return
        }
        context.updateInteractiveTransition(percentComplete)
        
        self.notifyAnimatings(.init(
            type: type,
            isInteractive: true,
            percentComplete: percentComplete,
            isCancelled: false
        ))
    }
    
    func finishInteractive() {
        self.checkInteractiveBegan()
        
        self.isInteractive = false
        
        guard let context = self.context else {
            assertionFailure()
            return
        }
        context.finishInteractiveTransition()
    }
    
    func cancelInteractive() {
        self.checkInteractiveBegan()
        
        self.isInteractive = false
        
        guard let context = self.context else {
            assertionFailure()
            return
        }
        context.cancelInteractiveTransition()
    }
    
}

extension TransitionAnimator {
    
    private var isAppear: Bool {
        guard let context = self.context else {
            assertionFailure()
            return false
        }
        guard let fromViewController = context.viewController(forKey: .from) else {
            return false
        }
        guard let toViewController = context.viewController(forKey: .to) else {
            return false
        }
        if toViewController.isBeingPresented {
            return true
        } else if fromViewController.isBeingDismissed {
            return false
        } else {
            assertionFailure()
            return false
        }
    }
    
    private func beginTransition(type: TransitionType) {
        guard let context = self.context else {
            assertionFailure()
            return
        }
        guard let fromViewController = context.viewController(forKey: .from) else {
            return
        }
        guard let toViewController = context.viewController(forKey: .to) else {
            return
        }
        let fromView: UIView = context.view(forKey: .from) ?? fromViewController.view
        let toView: UIView = context.view(forKey: .to) ?? toViewController.view
        let containerView: UIView = context.containerView
        
        /// 添加视图
        if type.isAppear {
            if toView.superview == nil {
                containerView.addSubview(toView)
            }
        } else {
            if toView.superview == nil {
                containerView.insertSubview(toView, belowSubview: fromView)
            }
        }
        
        /// 触发fromView的布局, 获得当前fromView内视图的Frame, 用作后续动画使用
        fromView.setNeedsLayout()
        if fromView.window != nil {
            fromView.layoutIfNeeded()
        }
        let finalFrame: CGRect = context.finalFrame(for: toViewController)
        /// dismiss时finalFrame可能与原视图的frame不一致, 导致一些UI异常
        if !finalFrame.isEmpty && type.isAppear {
            toView.frame = finalFrame
        }
        /// 触发toView的布局, 提前获得toView内视图的Frame, 用作后续动画使用
        toView.setNeedsLayout()
        if toView.window != nil {
            toView.layoutIfNeeded()
        }
    }
    
    private func endTransition() {
        guard let context = self.context else {
            assertionFailure()
            return
        }
        context.completeTransition(!context.transitionWasCancelled)
    }
    
    private func zoomAnimate() {
        guard let transitionContainerView = self.delegate?.transitionContainerView else {
            assertionFailure()
            return
        }
        let isAppear = self.isAppear
        let fadeAnimate = {
            self.fadeAnimate()
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
        
        self.retainMaskLayer = target.maskedView.layer.mask
        target.maskedView.layer.mask = self.maskLayer
        
        self.animate(
            type: isAppear ? .appear(style: .zoom) : .disappear(style: .zoom),
            animations: {
                imageView.frame = isAppear ? target.rect : source.rect
                imageView.layer.cornerRadius = isAppear ? 0 : source.cornerRadius
            },
            completion: {
                target.maskedView.layer.mask = self.retainMaskLayer
                self.retainMaskLayer = nil
                
                imageView.removeFromSuperview()
            }
        )
    }
    
    private func fadeAnimate() {
        guard let transitionContainerView = self.delegate?.transitionContainerView else {
            assertionFailure()
            return
        }
        guard let context = self.context else {
            assertionFailure()
            return
        }
        let isAppear = self.isAppear
        if isAppear && !context.transitionWasCancelled {
            transitionContainerView.alpha = 0.0
        }
        self.animate(
            type: isAppear ? .appear(style: .fade) : .disappear(style: .fade),
            animations: {
                transitionContainerView.alpha = isAppear ? 1 : 0
            },
            completion: {}
        )
    }
    
    private func checkInteractiveBegan() {
        assert(self.isInteractive, "可能未调用begin(), 请检查代码, 保证begin与finish、cancel成对出现")
    }
    
    private func checkInteractiveEnd() {
        assert(!self.isInteractive, "可能未调用finish()或者cancel(), 请检查代码, 保证begin与finish、cancel成对出现")
    }
    
}
