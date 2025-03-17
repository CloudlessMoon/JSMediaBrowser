//
//  SDWebImageMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import SDWebImage

public struct SDWebImageMediator: PhotoMediator {
    
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
        progress: @escaping PhotoMediatorProgress,
        completed: @escaping PhotoMediatorCompletion<UIImage>
    ) -> PhotoMediatorRequestToken? {
        return self.manager.loadImage(
            with: source,
            options: self.options,
            context: self.context,
            progress: { receivedSize, expectedSize, targetURL in
                progress(receivedSize, expectedSize)
            },
            completed: { image, data, error, cacheType, finished, url in
                if let error = error as? NSError {
                    let error = PhotoMediatorError(error, cancelled: error.code == SDWebImageError.cancelled.rawValue)
                    completed(.failure(error))
                } else {
                    completed(.success(image))
                }
            }
        )
    }
    
}

extension SDWebImageCombinedOperation: PhotoMediatorRequestToken {}
