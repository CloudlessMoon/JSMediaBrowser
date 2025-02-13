//
//  SDWebImageAssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import SDWebImage

public struct SDWebImageAssetMediator: ImageAssetMediator {
    
    public var manager: SDWebImageManager
    public var options: SDWebImageOptions
    public var context: [SDWebImageContextOption: Any]?
    
    public init(
        manager: SDWebImageManager = .shared,
        options: SDWebImageOptions? = nil,
        context: [SDWebImageContextOption: Any]? = nil
    ) {
        self.manager = manager
        self.options = options ?? [.retryFailed]
        self.context = context
    }
    
    public func requestImage(
        source: ImageAssetSource,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken? {
        switch source {
        case .url(let url):
            return self.manager.loadImage(
                with: url,
                options: self.options,
                context: self.context,
                progress: { receivedSize, expectedSize, targetUR in
                    MainThreadTask.currentOrAsync {
                        progress(receivedSize, expectedSize)
                    }
                },
                completed: { image, data, error, cacheType, finished, url in
                    MainThreadTask.currentOrAsync {
                        let nsError = error as? NSError
                        if let nsError = nsError {
                            let error = AssetMediatorError(error: nsError, isCancelled: nsError.code == SDWebImageError.cancelled.rawValue)
                            completed(.failure(error))
                        } else {
                            let result = AssetMediatorResult(asset: image)
                            completed(.success(result))
                        }
                    }
                }
            )
        case .provider:
            assertionFailure("not supported")
            return nil
        }
        
    }
    
}

extension SDWebImageCombinedOperation: AssetMediatorRequestToken {}

private struct MainThreadTask {
    
    static func currentOrAsync(execute work: @MainActor @Sendable @escaping () -> Void) {
        if Thread.isMainThread {
            MainActor.assumeIsolated(work)
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
}
