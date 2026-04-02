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
    
    private weak var context: UIViewControllerContextTransitioning? {
        didSet {
            self.updateAppear()
        }
    }
    
    private lazy var maskLayer: CALayer = {
        return CALayer()
    }()
    
    private var retainMaskLayer: CALayer?
    
    private var isAppear: Bool = false
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
        
        self.beginTransition()
        self.performZoomAnimation()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        if !self.isAppear && transitionCompleted {
            self.resetAnimations()
        }
    }
    
}

extension TransitionAnimator: UIViewControllerInteractiveTransitioning {
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.context = transitionContext
        
        if self.isInteractive {
            self.beginTransition()
            
            let isAppear = self.isAppear
            let type: TransitionType = isAppear ? .appear(style: .zoom) : .disappear(style: .zoom)
            self.notifyPrepares(.init(
                type: type,
                isInteractive: true,
                percentComplete: 0,
                isCancelled: false
            ))
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
    
    func performZoomAnimation() {
        self.zoomAnimate()
    }
    
    func animate(animations: @escaping () -> Void, completion: @escaping () -> Void) {
        self.animate(style: .zoom, animations: animations, completion: completion)
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
    
}

extension TransitionAnimator {
    
    func beginInteractive() {
        self.checkInteractiveEnd()
        
        self.isInteractive = true
    }
    
    func updateInteractive(_ percentComplete: CGFloat) {
        self.checkInteractiveBegan()
        
        guard let context = self.context else {
            assertionFailure()
            return
        }
        context.updateInteractiveTransition(percentComplete)
        
        let isAppear = self.isAppear
        let type: TransitionType = isAppear ? .appear(style: .zoom) : .disappear(style: .zoom)
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
        
        self.updateAppear()
    }
    
}

extension TransitionAnimator {
    
    private func beginTransition() {
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
        
        let isAppear = self.isAppear
        /// 添加视图
        if isAppear {
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
        if !finalFrame.isEmpty && isAppear {
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
            return self.fadeAnimate()
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
            return self.fadeAnimate()
        }
        guard let imageView = self.delegate?.transitionThumbnailView else {
            return self.fadeAnimate()
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
            style: .zoom,
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
            style: .fade,
            animations: {
                transitionContainerView.alpha = isAppear ? 1 : 0
            },
            completion: {}
        )
    }
    
    private func animate(style: TransitionStyle, animations: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let context = self.context else {
            assertionFailure()
            animations()
            completion()
            return
        }
        let isInteractive = context.isInteractive
        let isCancelled = context.transitionWasCancelled
        let isAppear = self.isAppear
        let type: TransitionType = isAppear ? .appear(style: style) : .disappear(style: style)
        
        self.notifyPrepares(.init(
            type: type,
            isInteractive: isInteractive,
            percentComplete: 0,
            isCancelled: isCancelled
        ))
        
        UIView.animate(
            withDuration: self.duration,
            delay: 0,
            options: isAppear ? .curveEaseInOut : .curveEaseOut,
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
    
    private func notifyPrepares(_ context: TransitionContext) {
        for prepares in self.prepares {
            prepares(context)
        }
    }
    
    private func notifyAnimatings(_ context: TransitionContext) {
        for animating in self.animatings {
            animating(context)
        }
    }
    
    private func notifyCompletions(_ context: TransitionContext) {
        for completion in self.completions {
            completion(context)
        }
    }
    
    private func resetAnimations() {
        self.prepares.removeAll()
        self.animatings.removeAll()
        self.completions.removeAll()
    }
    
    private func checkInteractiveBegan() {
        assert(self.isInteractive, "可能未调用begin(), 请检查代码, 保证begin与finish、cancel成对出现")
    }
    
    private func checkInteractiveEnd() {
        assert(!self.isInteractive, "可能未调用finish()或者cancel(), 请检查代码, 保证begin与finish、cancel成对出现")
    }
    
    private func updateAppear() {
        guard let context = self.context else {
            assertionFailure()
            return
        }
        guard let fromViewController = context.viewController(forKey: .from) else {
            assertionFailure()
            return
        }
        guard let toViewController = context.viewController(forKey: .to) else {
            assertionFailure()
            return
        }
        if toViewController.isBeingPresented {
            self.isAppear = context.transitionWasCancelled ? false : true
        } else if fromViewController.isBeingDismissed {
            self.isAppear = context.transitionWasCancelled ? true : false
        } else {
            assertionFailure()
        }
    }
    
}
