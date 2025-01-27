//
//  PagingCollectionView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public class PagingCollectionView: UICollectionView {
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func didInitialize() {
        self.backgroundColor = nil
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.alwaysBounceVertical = false
        self.alwaysBounceHorizontal = true
        self.scrollsToTop = false
        self.contentInsetAdjustmentBehavior = .never
    }
    
    public override func touchesShouldCancel(in view: UIView) -> Bool {
        // 默认情况下只有当view是非UIControl的时候才会返回YES，这里统一对UIControl也返回YES
        guard view is UIControl else {
            return super.touchesShouldCancel(in: view)
        }
        return true
    }
    
}

extension PagingCollectionView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UISlider {
            return false
        } else {
            return true
        }
    }
    
}
