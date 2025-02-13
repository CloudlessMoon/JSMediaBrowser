//
//  SDWebImagePhotosAssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import SDWebImage
import SDWebImagePhotosPlugin

public struct SDWebImagePhotosAssetMediator: ImageAssetMediator {
    
    public var options: SDWebImageOptions
    public var context: [SDWebImageContextOption: Any]?
    
    public init(
        options: SDWebImageOptions? = nil,
        context: [SDWebImageContextOption: Any]? = nil
    ) {
        self.options = options ?? [.retryFailed]
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
            let mediator = SDWebImageAssetMediator(
                manager: .photos,
                options: self.options,
                context: self.context
            )
            return mediator.requestImage(source: source, progress: progress, completed: completed)
        }
    }
    
}

public extension SDWebImageManager {
    
    static let photos = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
    
}
