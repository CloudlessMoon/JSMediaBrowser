//
//  PHLivePhotoMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/31.
//

import UIKit
import PhotosUI

public struct PHLivePhotoMediator: AssetMediator {
    
    public enum Source {
        case url(image: URL?, video: URL?)
        case asset(PHAsset?)
    }
    
    public var targetSize: CGSize
    public var contentMode: PHImageContentMode
    public var options: PHLivePhotoRequestOptions?
    
    public init(
        targetSize: CGSize = .zero,
        contentMode: PHImageContentMode = .default,
        options: PHLivePhotoRequestOptions? = nil
    ) {
        self.targetSize = targetSize
        self.contentMode = contentMode
        self.options = options
    }
    
    public func request(
        source: Source,
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
                targetSize: self.targetSize,
                contentMode: self.contentMode,
                resultHandler: handler
            )
            return PHLivePhotoRequestToken(id: id, imageManager: nil)
        case .asset(let asset):
            guard let asset = asset else {
                return nil
            }
            let imageManager = PHImageManager.default()
            let id = imageManager.requestLivePhoto(
                for: asset,
                targetSize: self.targetSize,
                contentMode: self.contentMode,
                options: self.options,
                resultHandler: handler
            )
            return PHLivePhotoRequestToken(id: id, imageManager: imageManager)
        }
    }
    
}

public final class PHLivePhotoRequestToken: AssetMediatorRequestToken {
    
    public private(set) var isCancelled: Bool = false
    
    private let id: Int32
    
    private weak var imageManager: PHImageManager?
    
    fileprivate init(id: Int32, imageManager: PHImageManager?) {
        self.id = id
        self.imageManager = imageManager
    }
    
    public func cancel() {
        guard !self.isCancelled else {
            return
        }
        self.isCancelled = true
        
        if let imageManager = self.imageManager {
            imageManager.cancelImageRequest(self.id)
        } else {
            PHLivePhoto.cancelRequest(withRequestID: self.id)
        }
    }
    
}
