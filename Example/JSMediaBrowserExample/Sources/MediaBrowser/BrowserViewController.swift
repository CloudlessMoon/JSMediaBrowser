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
import PhotosUI

class BrowserViewController: MediaBrowserViewController {
    
    lazy var shareControl: ShareControl = {
        return ShareControl().then {
            $0.mediaBrowserVC = self
        }
    }()
    
    lazy var pageControl: PageControl = {
        return PageControl().then {
            $0.mediaBrowserVC = self
        }
    }()
    
    init() {
        super.init(configuration: .init(
            zoomView: { _ in
                return ZoomView(modifier: SDZoomViewModifier())
            },
            webImageMediator: { _ in
                return SDWebImageMediator(
                    options: [.fromLoaderOnly],
                    context: [.animatedImageClass: SDAnimatedImage.self]
                )
            },
            livePhotoMediator: { _ in
                return PHLivePhotoMediator()
            }
        ))
        
        self.eventHandler = DefaultMediaBrowserViewControllerEventHandler(
            willReloadData: { [weak self] _ in
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
            didLongPressTouch: {
                QMUITips.show(withText: "长按")
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
        
        self.updatePageControl()
    }
    
}

extension BrowserViewController {
    
    func updatePageControl(for index: Int? = nil) {
        self.pageControl.numberOfPages = self.totalUnitPage
        self.pageControl.currentPage = index ?? self.currentPage
    }
    
}

private struct SDZoomViewModifier: ZoomViewModifier {
    
    func assetView(for asset: any ZoomAsset) -> (any ZoomAssetView)? {
        if asset is UIImage {
            let imageView = SDAnimatedImageView()
            imageView.autoPlayAnimatedImage = false
            if #available(iOS 17.0, *) {
                imageView.preferredImageDynamicRange = .high
            }
            return imageView
        } else if asset is PHLivePhoto {
            return PHLivePhotoView()
        } else {
            return nil
        }
    }
    
    func thumbnailView() -> UIImageView? {
        let imageView = SDAnimatedImageView()
        imageView.autoPlayAnimatedImage = false
        return imageView
    }
    
}
