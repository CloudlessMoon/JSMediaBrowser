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
        imageURL: URL,
        videoURL: URL,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken {
        let id = PHLivePhoto.request(
            withResourceFileURLs: [imageURL, videoURL],
            placeholderImage: nil,
            targetSize: .zero,
            contentMode: .default
        ) {
            guard let isCancelled = $1[PHLivePhotoInfoCancelledKey] as? Bool else {
                return
            }
            if let livePhoto = $0 {
                let result = AssetMediatorResult(asset: livePhoto)
                completed(.success(result))
            } else {
                guard let error = $1[PHLivePhotoInfoErrorKey] as? NSError else {
                    return
                }
                let error1 = AssetMediatorError(error: error, isCancelled: isCancelled)
                completed(.failure(error1))
            }
        }
        return PHLivePhotoRequestToken(id: id)
    }
    
}

public final class PHLivePhotoRequestToken: AssetMediatorRequestToken {
    
    public private(set) var isCancelled: Bool = false
    
    private let id: PHLivePhotoRequestID
    
    fileprivate init(id: PHLivePhotoRequestID) {
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
