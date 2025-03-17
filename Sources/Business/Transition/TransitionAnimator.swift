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

public enum TransitioningStyle: Int {
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
        let fromView: UIView = transitionContext.view(forKey: .from) ?? fromViewController.view
        let toView: UIView = transitionContext.view(forKey: .to) ?? toViewController.view
        let containerView: UIView = transitionContext.containerView
        
        if let imageView = self.delegate?.transitionThumbnailView {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.removeFromSuperview()
            self.delegate?.transitionViewWillMoveToSuperview(imageView)
            if imageView.superview == nil {
                containerView.addSubview(imageView)
            }
            self.imageView = imageView
        }
        
        var style: TransitioningStyle = isEntering ? self.enteringStyle : self.exitingStyle
        var sourceCornerRadius: CGFloat
        var sourceRect: CGRect
        if style == .zoom {
            let transitionSourceView = self.delegate?.transitionSourceView
            let transitionSourceRect = self.delegate?.transitionSourceRect ?? .zero
            let currentView = isEntering ? toView : fromView
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
        
        let contentViewFrame = self.delegate?.transitionTargetFrame ?? CGRect.zero
        
        /// 判断是否可以zoom
        if style == .zoom && (sourceRect.isEmpty || contentViewFrame.isEmpty || self.imageView == nil) {
            style = .fade
        }
        
        /// will
        self.handleAnimationEntering(
            style: style,
            isEntering: isEntering,
            fromView: fromView,
            toView: toView,
            sourceRect: sourceRect,
            sourceCornerRadius: sourceCornerRadius
        )
        UIView.animate(withDuration: self.duration, delay: 0, options: isEntering ? JSCoreHelper.animationOptionsCurveIn : .curveLinear) {
            /// processing
            self.handleAnimationProcessing(
                style: style,
                isEntering: isEntering,
                fromView: fromView,
                toView: toView
            )
        } completion: { (finished) in
            /// end
            self.handleAnimationCompletion(
                style: style,
                isEntering: isEntering,
                fromView: fromView,
                toView: toView
            )
            
            completion(finished)
        }
    }
    
}

extension TransitionAnimator {
    
    private func handleAnimationEntering(
        style: TransitioningStyle,
        isEntering: Bool,
        fromView: UIView,
        toView: UIView,
        sourceRect: CGRect,
        sourceCornerRadius: CGFloat
    ) {
        let currentView: UIView? = isEntering ? toView : fromView
        if style == .fade {
            currentView?.alpha = isEntering ? 0 : 1
        } else if style == .zoom, let imageView = self.imageView {
            let zoomView = self.delegate?.transitionTargetView
            let zoomContentViewFrameInView = {
                let rect = currentView?.convert(self.delegate?.transitionTargetFrame ?? .zero, from: zoomView) ?? .zero
                return CGRect(origin: JSCGPointRoundPixelValue(rect.origin), size: JSCGSizeCeilPixelValue(rect.size))
            }()
            let zoomContentViewBoundsInView = CGRect(origin: .zero, size: zoomContentViewFrameInView.size)
            /// 隐藏目标视图
            zoomView?.isHidden = true
            /// 设置下Frame
            imageView.image = self.renderTransitionThumbnail(with: zoomContentViewBoundsInView.size)
            imageView.frame = isEntering ? sourceRect : zoomContentViewFrameInView
            imageView.startAnimating()
            /// 计算position
            let sourceCenter = CGPoint(x: sourceRect.midX, y: sourceRect.midY)
            let zoomContentViewCenterInView = CGPoint(x: zoomContentViewFrameInView.midX, y: zoomContentViewFrameInView.midY)
            let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
            positionAnimation.fromValue = NSValue(cgPoint: isEntering ? sourceCenter : zoomContentViewCenterInView)
            positionAnimation.toValue = NSValue(cgPoint: isEntering ? zoomContentViewCenterInView : sourceCenter)
            /// 计算bounds
            let sourceBounds = CGRect(origin: .zero, size: sourceRect.size)
            let boundsAnimation: CABasicAnimation = CABasicAnimation(keyPath: "bounds")
            boundsAnimation.fromValue = NSValue(cgRect: isEntering ? sourceBounds : zoomContentViewBoundsInView)
            boundsAnimation.toValue = NSValue(cgRect: isEntering ? zoomContentViewBoundsInView : sourceBounds)
            /// 计算cornerRadius
            let cornerRadius = sourceCornerRadius
            let cornerRadiusAnimation: CABasicAnimation = CABasicAnimation(keyPath: "cornerRadius")
            cornerRadiusAnimation.fromValue = isEntering ? cornerRadius : 0
            cornerRadiusAnimation.toValue = isEntering ? 0 : cornerRadius
            /// 添加组动画
            let groupAnimation: CAAnimationGroup = CAAnimationGroup()
            groupAnimation.duration = self.duration
            groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            groupAnimation.fillMode = .forwards
            groupAnimation.isRemovedOnCompletion = false
            groupAnimation.animations = [positionAnimation, boundsAnimation, cornerRadiusAnimation]
            if #available(iOS 15.0, *) {
                let preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
                groupAnimation.preferredFrameRateRange = preferredFrameRateRange
                groupAnimation.animations?.forEach({ animation in
                    animation.preferredFrameRateRange = preferredFrameRateRange
                })
            }
            imageView.layer.add(groupAnimation, forKey: TransitionAnimator.animationGroupKey)
        }
        
        if isEntering {
            self.delegate?.transitionAnimatorViews?.forEach { subview in
                subview.alpha = 0.0
            }
        }
    }
    
    private func handleAnimationProcessing(style: TransitioningStyle, isEntering: Bool, fromView: UIView, toView: UIView) {
        let currentView: UIView? = isEntering ? toView : fromView
        if style == .fade {
            currentView?.alpha = isEntering ? 1 : 0
        }
        
        self.delegate?.transitionAnimatorViews?.forEach { subview in
            subview.alpha = isEntering ? 1 : 0
        }
    }
    
    private func handleAnimationCompletion(style: TransitioningStyle, isEntering: Bool, fromView: UIView, toView: UIView) {
        let currentView: UIView? = isEntering ? toView : fromView
        if style == .fade {
            currentView?.alpha = 1
        } else if style == .zoom {
            self.delegate?.transitionTargetView?.isHidden = false
        }
        if let imageView = self.imageView {
            imageView.removeFromSuperview()
            self.imageView = nil
        }
    }
    
    private func renderTransitionThumbnail(with targetSize: CGSize) -> UIImage? {
        guard let image = self.delegate?.transitionThumbnail else {
            return nil
        }
        /// 图片方向不是up时重绘图片，以解决动画显示异常的问题
        let orientation = image.imageOrientation
        guard orientation != .up else {
            return image
        }
        guard JSCGSizeIsValidated(image.size) else {
            return image
        }
        let size = {
            let ratio = image.size.width / image.size.height
            return JSCGSizeCeilPixelValue(CGSize(
                width: targetSize.width,
                height: targetSize.width / ratio
            ))
        }()
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = image.js_opaque
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
}
