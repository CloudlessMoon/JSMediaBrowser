//
//  PHLivePhotoMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/31.
//

import UIKit
import PhotosUI

public struct PHLivePhotoMediator: LivePhotoAssetMediator {
    
    public init() {
        
    }
    
    public func requestLivePhoto(
        source: LivePhotoAssetSource,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken? {
        let handler = { (livePhoto: PHLivePhoto?, info: [AnyHashable: Any]?) in
            guard let isCancelled = info?[PHLivePhotoInfoCancelledKey] as? Bool else {
                return
            }
            if let livePhoto = livePhoto {
                let result = AssetMediatorResult(asset: livePhoto)
                completed(.success(result))
            } else {
                guard let error = info?[PHLivePhotoInfoErrorKey] as? NSError else {
                    completed(.failure(AssetMediatorError(error: .init(), isCancelled: isCancelled)))
                    return
                }
                let error1 = AssetMediatorError(error: error, isCancelled: isCancelled)
                completed(.failure(error1))
            }
        }
        switch source {
        case .url(let image, let video):
            guard let image = image, let video = video else {
                return nil
            }
            let id = PHLivePhoto.request(
                withResourceFileURLs: [image, video],
                placeholderImage: nil,
                targetSize: .zero,
                contentMode: .default,
                resultHandler: handler
            )
            return PHLivePhotoRequestToken(id: id)
        case .provider(let provider):
            guard let asset = provider as? PHAsset else {
                assertionFailure("not supported")
                return nil
            }
            let id = PHImageManager.default().requestLivePhoto(
                for: asset,
                targetSize: .zero,
                contentMode: .default,
                options: nil,
                resultHandler: handler)
            return PHLivePhotoRequestToken(id: id)
        }
    }
    
}

public final class PHLivePhotoRequestToken: AssetMediatorRequestToken {
    
    public private(set) var isCancelled: Bool = false
    
    private let id: Int32
    
    fileprivate init(id: Int32) {
        self.id = id
    }
    
    public func cancel() {
        guard !self.isCancelled else {
            return
        }
        self.isCancelled = true
        PHLivePhoto.cancelRequest(withRequestID: self.id)
    }
    
}
