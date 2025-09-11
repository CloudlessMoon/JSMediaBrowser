//
//  ZoomScrollView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/4.
//

import UIKit

open class ZoomScrollView: UIScrollView {
    
    public init() {
        super.init(frame: .zero)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func didInitialize() {
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.alwaysBounceVertical = false
        self.alwaysBounceHorizontal = false
        self.scrollsToTop = false
        self.contentInsetAdjustmentBehavior = .never
        
        if #available(iOS 26.0, *) {
            self.topEdgeEffect.isHidden = true
            self.leftEdgeEffect.isHidden = true
            self.bottomEdgeEffect.isHidden = true
            self.rightEdgeEffect.isHidden = true
        }
    }
    
    open override func touchesShouldCancel(in view: UIView) -> Bool {
        // 默认情况下只有当view是非UIControl的时候才会返回YES，这里统一对UIControl也返回YES
        guard view is UIControl else {
            return super.touchesShouldCancel(in: view)
        }
        return true
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.next?.touchesBegan(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.next?.touchesEnded(touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        self.next?.touchesMoved(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.next?.touchesCancelled(touches, with: event)
    }
    
    open override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        super.touchesEstimatedPropertiesUpdated(touches)
        self.next?.touchesEstimatedPropertiesUpdated(touches)
    }
    
}

extension ZoomScrollView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard touch.view is UISlider else {
            return true
        }
        return false
    }
    
}
