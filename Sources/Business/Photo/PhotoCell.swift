//
//  PhotoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

open class PhotoCell: BasisCell {
    
    public var photoView: (any PhotoContentView)? {
        didSet {
            if let oldValue = oldValue, oldValue.superview == self.contentView {
                oldValue.removeFromSuperview()
            }
            guard let photoView = self.photoView else {
                return
            }
            photoView.removeFromSuperview()
            self.contentView.insertSubview(photoView, at: 0)
            
            self.setNeedsLayout()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.photoView?.js_frameApplyTransform = self.contentView.bounds
    }
    
}
