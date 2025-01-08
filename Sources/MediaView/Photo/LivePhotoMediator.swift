//
//  LivePhotoMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/31.
//

import UIKit

public typealias LivePhotoMediatorDownloadProgress = (_ receivedSize: Int64, _ expectedSize: Int64) -> Void
public typealias LivePhotoMediatorCompleted = (_ result: Result<LivePhotoMediationResult, LivePhotoMediationError>) -> Void

public protocol LivePhotoMediator {
    
    func requestLivePhoto(
        for view: UIView,
        imageURL: URL,
        videoURL: URL,
        progress: @escaping LivePhotoMediatorDownloadProgress,
        completed: @escaping LivePhotoMediatorCompleted
    )
    
    func cancelRequest(for view: UIView)
    
}

public struct LivePhotoMediationResult {
    
    public let livePhoto: (any ZoomAsset)?
    
    public init(livePhoto: (any ZoomAsset)?) {
        self.livePhoto = livePhoto
    }
    
}

public struct LivePhotoMediationError: Error {
    
    public let error: NSError
    public let isCancelled: Bool
    
    public init(error: NSError, isCancelled: Bool) {
        self.error = error
        self.isCancelled = isCancelled
    }
}
