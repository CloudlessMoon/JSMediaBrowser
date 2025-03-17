//
//  BasisMediaView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import JSCoreKit

open class BasisMediaView: UIView {
    
    public var viewportInsets: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != self.viewportInsets else {
                return
            }
            self.setNeedsLayout()
        }
    }
    
    public var viewportMaximumSize: CGSize = .init(width: .max, height: .max) {
        didSet {
            guard oldValue != self.viewportMaximumSize else {
                return
            }
            self.setNeedsLayout()
        }
    }
    
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
            return .zero
        }
        let viewportInsets = self.viewportInsets
        let size = CGSize(
            width: min(self.bounds.width, self.viewportMaximumSize.width),
            height: min(self.bounds.height, self.viewportMaximumSize.height)
        )
        let top = max(viewportInsets.top, (self.bounds.height - size.height) / 2)
        let left = max(viewportInsets.left, (self.bounds.width - size.width) / 2)
        let bottom = viewportInsets.bottom
        let right = viewportInsets.right
        return CGRect(
            x: left,
            y: top,
            width: min(size.width, self.bounds.width - (left + right)),
            height: min(size.height, self.bounds.height - (top + bottom))
        )
    }
    
}
