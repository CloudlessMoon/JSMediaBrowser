//
//  WebImageMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

public typealias WebImageMediatorDownloadProgress = (_ receivedSize: Int64, _ expectedSize: Int64) -> Void
public typealias WebImageMediatorCompleted = (_ result: Result<WebImageMediationResult, WebImageMediationError>) -> Void

public protocol WebImageMediator {
    
    func requestImage(
        for view: UIView,
        url: URL,
        progress: @escaping WebImageMediatorDownloadProgress,
        completed: @escaping WebImageMediatorCompleted
    )
    
    func cancelRequest(for view: UIView)
    
}

public struct WebImageMediationResult {
    
    public let image: (any ZoomAsset)?
    
    public init(image: (any ZoomAsset)?) {
        self.image = image
    }
    
}

public struct WebImageMediationError: Error {
    
    public let error: NSError
    public let isCancelled: Bool
    
    public init(error: NSError, isCancelled: Bool) {
        self.error = error
        self.isCancelled = isCancelled
    }
}
