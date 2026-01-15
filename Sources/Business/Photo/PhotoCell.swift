//
//  PhotoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

open class PhotoCell: UICollectionViewCell {
    
    public private(set) var photoView: (any PhotoView)! {
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
        if self.photoView != nil {
            self.photoView.js_frameApplyTransform = self.contentView.bounds
        }
    }
    
}

extension PhotoCell {
    
    internal func createPhotoView(_ photoView: () -> any PhotoView) {
        guard self.photoView == nil else {
            return
        }
        self.photoView = photoView()
    }
    
}
