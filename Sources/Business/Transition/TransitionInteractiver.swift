//
//  TransitionInteractiver.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/9/17.
//

import UIKit

public class TransitionInteractiver: Transitioner {
    
    private var isInteractive: Bool = false
    
}

extension TransitionInteractiver: UIViewControllerInteractiveTransitioning {
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        if self.isInteractive {
            self.beginTransition(transitionContext)
        } else {
            /// 极端情况下isInteractive已经设置为false, 但是此时未处理transitionContext时会出现异常
            /// 所以这里规避下, 出现异常时直接取消
            /// 此时若执行取消, 后续获取transitionWasCancelled还是false, 所以直接在这里结束还是会存在异常，顺延到下一个runloop执行
            DispatchQueue.main.async {
                transitionContext.cancelInteractiveTransition()
                self.endTransition(transitionContext)
            }
        }
    }
    
    public var completionSpeed: CGFloat {
        return 1.0
    }
    
    public var completionCurve: UIView.AnimationCurve {
        return .easeInOut
    }
    
    public var wantsInteractiveStart: Bool {
        return self.isInteractive
    }
    
}

extension TransitionInteractiver {
    
    public func begin() {
        self.checkInteractiveEnd()
        
        self.isInteractive = true
    }
    
    public func finish() {
        self.checkInteractiveBegan()
        
        self.isInteractive = false
        
        if let context = self.context {
            context.finishInteractiveTransition()
            self.endTransition(context)
        }
    }
    
    public func cancel() {
        self.checkInteractiveBegan()
        
        self.isInteractive = false
        
        if let context = self.context {
            context.cancelInteractiveTransition()
            self.endTransition(context)
        }
    }
    
    private func checkInteractiveBegan() {
        assert(self.isInteractive, "可能未调用begin(), 请检查代码, 保证begin与finish、cancel成对出现")
    }
    
    private func checkInteractiveEnd() {
        assert(!self.isInteractive, "可能未调用finish()或者cancel(), 请检查代码, 保证begin与finish、cancel成对出现")
    }
    
}
