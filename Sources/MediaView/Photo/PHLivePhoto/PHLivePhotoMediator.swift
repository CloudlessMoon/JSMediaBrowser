//
//  PHLivePhotoMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/31.
//

import UIKit
import PhotosUI

public struct PHLivePhotoMediator: LivePhotoMediator {
    
    public init() {
        
    }
    
    public func requestLivePhoto(
        for view: UIView,
        imageURL: URL,
        videoURL: URL,
        progress: @escaping LivePhotoMediatorDownloadProgress,
        completed: @escaping (Result<LivePhotoMediationResult, LivePhotoMediationError>) -> Void
    ) {
        let taskIdentifier = PHLivePhoto.request(
            withResourceFileURLs: [imageURL, videoURL],
            placeholderImage: nil,
            targetSize: .zero,
            contentMode: .default
        ) {
            guard let isCancelled = $1[PHLivePhotoInfoCancelledKey] as? Bool else {
                return
            }
            if let livePhoto = $0 {
                let result = LivePhotoMediationResult(livePhoto: livePhoto)
                completed(.success(result))
            } else {
                guard let error = $1[PHLivePhotoInfoErrorKey] as? NSError else {
                    return
                }
                let error1 = LivePhotoMediationError(error: error, isCancelled: isCancelled)
                completed(.failure(error1))
            }
        }
        view.jsmbph_taskIdentifier = taskIdentifier
    }
    
    public func cancelRequest(for view: UIView) {
        guard let taskIdentifier = view.jsmbph_taskIdentifier else {
            return
        }
        PHLivePhoto.cancelRequest(withRequestID: taskIdentifier)
    }
    
}

private struct AssociatedKeys {
    static var taskIdentifier: UInt8 = 0
}

private extension UIView {
    
    var jsmbph_taskIdentifier: PHLivePhotoRequestID? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.taskIdentifier) as? PHLivePhotoRequestID
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.taskIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
