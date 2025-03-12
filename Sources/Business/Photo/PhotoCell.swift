//
//  PhotoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

open class PhotoCell: BasisCell {
    
    public var zoomView: (any ZoomViewProtocol)? {
        didSet {
//            guard oldValue != self.zoomView else {
//                return
//            }
            if let oldValue = oldValue, oldValue.superview == self.contentView {
                oldValue.removeFromSuperview()
            }
            guard let zoomView = self.zoomView else {
                return
            }
            zoomView.removeFromSuperview()
            self.contentView.insertSubview(zoomView, at: 0)
            
            self.setNeedsLayout()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.zoomView?.js_frameApplyTransform = self.contentView.bounds
    }
    
}

public protocol ZoomViewProtocol: UIView {
    
    associatedtype AssetView: ZoomAssetView
    
}

extension ZoomView: ZoomViewProtocol {
    
    public typealias AssetView = View11
    
    
}
