//
//  Transitioner.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/9/17.
//

import UIKit

public enum TransitionerType: Int {
    case presenting
    case dismiss
}

public class Transitioner: NSObject {
    
    public var type: TransitionerType = .presenting
    
    public private(set) weak var context: UIViewControllerContextTransitioning?
    
    public override init() {
        super.init()
    }
    
    deinit {
        assert(self.context == nil, "transitionContext未释放, 检查beginTransition或endTransition是否成对调用")
    }
    
}

extension Transitioner {
    
    public func beginTransition(_ transitionContext: UIViewControllerContextTransitioning, isEntering: Bool) {
        self.context = transitionContext
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        let fromView: UIView = transitionContext.view(forKey: .from) ?? fromViewController.view
        let toView: UIView = transitionContext.view(forKey: .to) ?? toViewController.view
        let containerView: UIView = transitionContext.containerView
        
        /// 添加视图
        if isEntering {
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
        let finalFrame: CGRect = transitionContext.finalFrame(for: toViewController)
        /// dismiss时finalFrame可能与原视图的frame不一致, 导致一些UI异常
        if !finalFrame.isEmpty && isEntering {
            toView.frame = finalFrame
        }
        /// 触发toView的布局, 提前获得toView内视图的Frame, 用作后续动画使用
        toView.setNeedsLayout()
        if toView.window != nil {
            toView.layoutIfNeeded()
        }
    }
    
    public func endTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
}
