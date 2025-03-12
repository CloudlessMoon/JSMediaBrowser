//
//  ShareControl.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/26.
//

import UIKit
import JSCoreKit
import JSMediaBrowser
import SnapKit
import QMUIKit

class ShareControl: UIButton {
    
    weak var mediaBrowserVC: BrowserViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitle("保存", for: UIControl.State.normal)
        self.setTitleColor(.white, for: UIControl.State.normal)
        self.accessibilityLabel = "保存"
        self.addTarget(self, action: #selector(self.onPress), for: UIControl.Event.touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onPress() {
//        guard let mediaBrowserVC = self.mediaBrowserVC else {
//            return
//        }
//        guard let photoCell = mediaBrowserVC.currentPageCell as? PhotoCell else {
//            return
//        }
//        guard let image = photoCell.photoView?.asset as? UIImage else {
//            return
//        }
//        PHPhotoLibrary.shared().performChanges {
//            guard let imageData = image.sd_imageData() else {
//                return
//            }
//            PHAssetCreationRequest.forAsset().addResource(with: .photo, data: imageData, options: nil)
//        } completionHandler: { success, error in
//            DispatchQueue.main.async {
//                QMUITips.show(withText: success ? "保存成功" : error?.localizedDescription)
//            }
//        }
    }
    
}
