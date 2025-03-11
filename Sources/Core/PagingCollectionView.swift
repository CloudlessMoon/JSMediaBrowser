//
//  PagingCollectionView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

open class PagingCollectionView: UICollectionView {
    
    public init(layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: layout)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    open func didInitialize() {
        self.backgroundColor = nil
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.alwaysBounceVertical = false
        self.alwaysBounceHorizontal = true
        self.scrollsToTop = false
        self.contentInsetAdjustmentBehavior = .never
    }
    
    open override func touchesShouldCancel(in view: UIView) -> Bool {
        // 默认情况下只有当view是非UIControl的时候才会返回YES，这里统一对UIControl也返回YES
        guard view is UIControl else {
            return super.touchesShouldCancel(in: view)
        }
        return true
    }
    
}

extension PagingCollectionView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard touch.view is UISlider else {
            return true
        }
        return false
    }
    
}
