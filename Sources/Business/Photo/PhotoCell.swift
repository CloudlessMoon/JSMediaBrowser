//
//  PhotoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

open class PhotoCell: UICollectionViewCell {
    
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
        self.photoView = UselessPhotoView()
        
        super.init(frame: frame)
    }
    
    @available(*, unavailable, message: "use init()")
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.photoView.js_frameApplyTransform = self.contentView.bounds
    }
    
}

extension PhotoCell {
    
    internal func createPhotoView(_ photoView: any PhotoView) {
        guard self.photoView is UselessPhotoView else {
            return
        }
        self.photoView = photoView
    }
    
}

private final class UselessPhotoView: UIView, PhotoView {
    
    typealias ZoomViewType = ZoomView<UIImageView>
    typealias ZoomAssetViewType = UIImageView
    
    var zoomView: ZoomViewType {
        self.assertion()
        return ZoomView(assetView: UIImageView(), thumbnailView: UIImageView())
    }
    
    func setAsset(_ asset: ZoomAssetViewType.Asset?, thumbnail: UIImage?) {
        self.assertion()
    }
    
    func setProgress(received: Int, expected: Int) {
        self.assertion()
    }
    
    func setError(_ error: NSError?, cancelled: Bool) {
        self.assertion()
    }
    
    private func assertion() {
        assertionFailure("此处理论上不会调用，请按照堆栈检查代码")
    }
    
}
