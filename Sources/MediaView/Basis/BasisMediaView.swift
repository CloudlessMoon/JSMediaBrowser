//
//  BasisMediaView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import JSCoreKit

open class BasisMediaView: UIView {
    
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != self.contentInset else {
                return
            }
            self.setNeedsLayout()
        }
    }
    
    /// 以下属性viewportRect为zero时才会生效, 若自定义viewportRect, 请自行实现
    private var viewportRectMaxWidth = 580.0
    
    public init() {
        super.init(frame: .zero)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    open func didInitialize() {
        
    }
    
    open var contentView: UIView? {
        return nil
    }
    
    open var contentViewFrame: CGRect {
        return .zero
    }
    
}

extension BasisMediaView {
    
    public var viewportRect: CGRect {
        guard !self.bounds.isEmpty else {
            return CGRect.zero
        }
        let contentInset = self.contentInset
        let size = CGSize(width: min(self.bounds.width, self.viewportRectMaxWidth), height: self.bounds.height)
        let offsetX = (self.bounds.width - size.width) / 2
        let top = contentInset.top
        let left = max(contentInset.left, offsetX)
        let bottom = contentInset.bottom
        let right = contentInset.right
        return CGRect(
            x: left,
            y: top,
            width: min(size.width, self.bounds.width - (left + right)),
            height: size.height - (top + bottom)
        )
    }
    
}
