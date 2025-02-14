//
//  SDWebImagePhotosAssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import SDWebImage
import SDWebImagePhotosPlugin
import Photos

public struct SDWebImagePhotosAssetMediator: AssetMediator {
    
    public enum Source {
        case url(URL?)
        case asset(localIdentifier: String?)
    }
    
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
    
    public func request(
        source: Source,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken? {
        switch source {
        case .url(let url):
            let mediator = SDWebImageAssetMediator(
                manager: self.manager,
                options: self.options,
                context: self.context
            )
            return mediator.request(source: url, progress: progress, completed: completed)
        case .asset(let identifier):
            guard let identifier = identifier else {
                return nil
            }
            let photosURL = NSURL.sd_URL(withAssetLocalIdentifier: identifier) as URL
            let context = {
                let context = [.imageLoader: SDImagePhotosLoader.shared] as [SDWebImageContextOption: Any]
                return context.merging(self.context ?? [:], uniquingKeysWith: { $1 })
            }()
            let mediator = SDWebImageAssetMediator(
                manager: self.manager,
                options: self.options,
                context: context
            )
            return mediator.request(source: photosURL, progress: progress, completed: completed)
        }
    }
    
}
