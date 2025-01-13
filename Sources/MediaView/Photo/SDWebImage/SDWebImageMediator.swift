//
//  SDWebImageMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import SDWebImage

public struct SDWebImageMediator: WebImageMediator {
    
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
        for view: UIView,
        url: URL,
        progress: @escaping WebImageMediatorDownloadProgress,
        completed: @escaping WebImageMediatorCompleted
    ) {
        view.sd_internalSetImage(
            with: url,
            placeholderImage: nil,
            options: self.options,
            context: self.context,
            setImageBlock: nil,
            progress: { (receivedSize: Int, expectedSize: Int, targetURL: URL?) in
                MainThreadTask.currentOrAsync {
                    progress(Int64(receivedSize), Int64(expectedSize))
                }
            },
            completed: { (image: UIImage?, data: Data?, error: Error?, cacheType: SDImageCacheType, finished: Bool, url: URL?) in
                MainThreadTask.currentOrAsync {
                    let nsError = error as? NSError
                    if let nsError = nsError {
                        let error = WebImageMediationError(error: nsError, isCancelled: nsError.code == SDWebImageError.cancelled.rawValue)
                        completed(.failure(error))
                    } else {
                        let result = WebImageMediationResult(image: image)
                        completed(.success(result))
                    }
                }
            })
    }
    
    public func cancelRequest(for view: UIView) {
        view.sd_cancelLatestImageLoad()
    }
    
}

private struct MainThreadTask {
    
    static func currentOrAsync(execute work: @MainActor @Sendable @escaping () -> Void) {
        if Thread.isMainThread {
            MainActor.assumeIsolated(work)
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
}
