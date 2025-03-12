//
//  SDWebImagePhotosAssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import SDWebImage
import SDWebImagePhotosPlugin
import Photos

public struct SDWebImagePhotosAssetMediator: PhotoMediator {
    
    public enum Source {
        case url(URL?)
        case asset(localIdentifier: String?)
        
        public var url: URL? {
            switch self {
            case .url(let url):
                return url
            case .asset(let identifier):
                guard let identifier = identifier else {
                    return nil
                }
                return NSURL.sd_URL(withAssetLocalIdentifier: identifier) as URL
            }
        }
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
        progress: @escaping PhotoMediatorProgress,
        completed: @escaping PhotoMediatorCompletion<UIImage>
    ) -> PhotoMediatorRequestToken? {
        switch source {
        case .url:
            let mediator = SDWebImageAssetMediator(
                manager: self.manager,
                options: self.options,
                context: self.context
            )
            return mediator.request(source: source.url, progress: progress, completed: completed)
        case .asset(let identifier):
            let context = {
                let context = [.imageLoader: SDImagePhotosLoader.shared] as [SDWebImageContextOption: Any]
                return context.merging(self.context ?? [:], uniquingKeysWith: { $1 })
            }()
            let mediator = SDWebImageAssetMediator(
                manager: self.manager,
                options: self.options,
                context: context
            )
            return mediator.request(source: source.url, progress: progress, completed: completed)
        }
    }
    
}
