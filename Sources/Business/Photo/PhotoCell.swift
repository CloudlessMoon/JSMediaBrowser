//
//  PhotoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

open class PhotoCell: BasisCell {
    
    public private(set) var photoView: any PhotoView {
        didSet {
            if oldValue.superview == self.contentView {
                oldValue.removeFromSuperview()
            }
            self.photoView.removeFromSuperview()
            self.contentView.insertSubview(self.photoView, at: 0)
            
            self.setNeedsLayout()
        }
    }
    
    public override init(frame: CGRect) {
        self.photoView = DefaultPhotoView()
        
        super.init(frame: frame)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.photoView.js_frameApplyTransform = self.contentView.bounds
    }
    
}

extension PhotoCell {
    
    internal func createPhotoView(_ photoView: any PhotoView) {
        guard self.photoView is DefaultPhotoView else {
            return
        }
        self.photoView = photoView
    }
    
}

private final class DefaultPhotoView: UIView, PhotoView {
    
    typealias ZoomAssetViewType = UIImageView
    typealias ZoomViewType = ZoomView<UIImageView>
    
    var zoomView: ZoomViewType {
        assertionFailure("此处理论上不会调用，请按照堆栈检查代码")
        return ZoomView(assetView: UIImageView(), thumbnailView: UIImageView())
    }
    
}
