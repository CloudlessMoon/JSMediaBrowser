//
//  PhotoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public class PhotoCell: BasisCell {
    
    public var zoomView: ZoomView? {
        didSet {
            guard oldValue != self.zoomView else {
                return
            }
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
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.zoomView?.stopPlaying()
        self.zoomView?.asset = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.zoomView?.js_frameApplyTransform = self.contentView.bounds
    }
    
}
