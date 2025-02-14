//
//  SDWebImagePhotosAssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import SDWebImage
import SDWebImagePhotosPlugin
import Photos

public struct SDWebImagePhotosAssetMediator: ImageAssetMediator {
    
    public var manager: SDWebImageManager
    public var options: SDWebImageOptions
    public var context: [SDWebImageContextOption: Any]?
    
    public init(
        manager: SDWebImageManager = .shared,
        options: SDWebImageOptions = [.retryFailed],
        context: [SDWebImageContextOption: Any]? = nil
    ) {
        self.manager = manager
        self.options = options
        self.context = context
    }
    
    public func requestImage(
        source: ImageAssetSource,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken? {
        switch source {
        case .url:
            let mediator = SDWebImageAssetMediator(
                manager: self.manager,
                options: self.options,
                context: self.context
            )
            return mediator.requestImage(source: source, progress: progress, completed: completed)
        case .provider(let provider):
            guard let asset = provider as? PHAsset else {
                assertionFailure("not supported")
                return nil
            }
            let photosURL = NSURL.sd_URL(with: asset) as URL
            let source = ImageAssetSource.url(photosURL)
            let context = {
                let context = [.imageLoader: SDImagePhotosLoader.shared] as [SDWebImageContextOption: Any]
                return context.merging(self.context ?? [:], uniquingKeysWith: { $1 })
            }()
            let mediator = SDWebImageAssetMediator(
                manager: self.manager,
                options: self.options,
                context: context
            )
            return mediator.requestImage(source: source, progress: progress, completed: completed)
        }
    }
    
}
