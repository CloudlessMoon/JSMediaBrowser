//
//  BrowserViewController.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2023/1/5.
//  Copyright © 2023 jiasong. All rights reserved.
//

import UIKit
import JSMediaBrowser
import SnapKit
import QMUIKit
import SDWebImage

class BrowserViewController: MediaBrowserViewController {
    
    lazy var shareControl: ShareControl = {
        return ShareControl()
    }()
    
    lazy var pageControl: PageControl = {
        return PageControl()
    }()
    
    init() {
        super.init(configuration: .init())
        
        self.eventHandler = DefaultMediaBrowserViewControllerEventHandler(
            didChangedData: { [weak self] _, _ in
                guard let self = self else { return }
                self.updatePageControl()
            },
            willDisplayEmptyView: { emptyView, _, _ in
                emptyView.image = UIImage(named: "img_fail")
            },
            willScrollHalf: { [weak self] in
                guard let self = self else { return }
                self.updatePageControl(for: $1)
            },
            didLongPress: { [weak self] _, _ in
                guard let self = self else { return }
                self.setCurrentPage(Int.random(in: 0..<self.dataSource.count), animated: true)
            }
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.shareControl)
        self.shareControl.snp.makeConstraints { (make) in
            make.right.equalTo(self.view.snp.right).offset(-20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(QMUIHelper.isNotchedScreen ? 0 : -20)
            make.height.equalTo(30)
        }
        self.view.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.snp.width).multipliedBy(0.5)
            make.centerX.equalTo(self.view.snp.centerX)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(QMUIHelper.isNotchedScreen ? 0 : -20)
            make.height.equalTo(30)
        }
        
        self.shareControl.onSave = { [weak self] in
            guard let self = self else { return }
            if let item = self.dataSource[self.currentPage] as? ImageItem {
                SDWebImageManager.shared.loadImage(
                    with: item.source.url,
                    options: [.retryFailed],
                    context: [
                        .queryCacheType: SDImageCacheType.disk.rawValue
                    ],
                    progress: nil
                ) { _, data, _, _, _, _ in
                    guard let data = data else {
                        return
                    }
                    PHPhotoLibrary.shared().performChanges {
                        PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
                    } completionHandler: { success, error in
                        DispatchQueue.main.async {
                            QMUITips.show(withText: success ? "保存成功" : error?.localizedDescription)
                        }
                    }
                }
            }
            
        }
        self.pageControl.onValueChanged = { [weak self] in
            guard let self = self else { return }
            self.setCurrentPage($0, animated: true)
        }
    }
    
    override func forceEnableInteractivePopGestureRecognizer() -> Bool {
        return true
    }
    
}

extension BrowserViewController {
    
    func updatePageControl(for index: Int? = nil) {
        self.pageControl.numberOfPages = self.totalUnitPage
        self.pageControl.currentPage = index ?? self.currentPage
    }
    
}
