//
//  SDWebImageAssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import SDWebImage

public struct SDWebImageAssetMediator: AssetMediator {
    
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
        source: URL?,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken? {
        return self.manager.loadImage(
            with: source,
            options: self.options,
            context: self.context,
            progress: { receivedSize, expectedSize, targetUR in
                progress(receivedSize, expectedSize)
            },
            completed: { image, data, error, cacheType, finished, url in
                let nsError = error as? NSError
                if let nsError = nsError {
                    let error = AssetMediatorError(error: nsError, isCancelled: nsError.code == SDWebImageError.cancelled.rawValue)
                    completed(.failure(error))
                } else {
                    let result = AssetMediatorResult(asset: image)
                    completed(.success(result))
                }
            }
        )
    }
    
}

extension SDWebImageCombinedOperation: AssetMediatorRequestToken {}
