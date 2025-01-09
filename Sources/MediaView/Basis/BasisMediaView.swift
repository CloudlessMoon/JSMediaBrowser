//
//  BasisMediaView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import JSCoreKit

open class BasisMediaView: UIView {
    
    public var isEnableVerticalSafeArea = JSCoreHelper.isMac ? true : false
    
    /// 以下属性viewportRect为zero时才会生效, 若自定义viewportRect, 请自行实现
    private var viewportRectMaxWidth: CGFloat = 580
    
    public init() {
        super.init(frame: .zero)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func didInitialize() {
        
    }
    
    open var containerView: UIView {
        return self
    }
    
    open var contentView: UIView? {
        return nil
    }
    
    open var contentViewFrame: CGRect {
        return CGRect.zero
    }
    
    public var finalViewportRect: CGRect {
        guard !self.bounds.isEmpty else {
            return CGRect.zero
        }
        var safeAreaInsets = self.safeAreaInsets
        if !self.isEnableVerticalSafeArea {
            /// 关闭垂直的安全区域
            safeAreaInsets.top = 0
            safeAreaInsets.bottom = 0
        }
        let size = CGSize(width: min(self.containerView.bounds.width, self.viewportRectMaxWidth), height: self.containerView.bounds.height)
        let offsetX = (self.containerView.bounds.width - size.width) / 2
        let top = safeAreaInsets.top
        let left = max(safeAreaInsets.left, offsetX)
        let bottom = safeAreaInsets.bottom
        let right = safeAreaInsets.right
        return CGRect(
            x: left,
            y: top,
            width: min(size.width, self.containerView.bounds.width - (left + right)),
            height: size.height - (top + bottom)
        )
    }
    
}
