//
//  PhotoAssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/31.
//

import Foundation

public typealias PhotoAssetMediatorProgress = (_ receivedSize: Int, _ expectedSize: Int) -> Void
public typealias PhotoAssetMediatorCompletion<Target: ZoomAsset> = (Result<Target?, PhotoAssetMediatorError>) -> Void

public protocol PhotoAssetMediator {
    
    associatedtype Source
    associatedtype Target: ZoomAsset
    
    func request(
        source: Source,
        progress: @escaping PhotoAssetMediatorProgress,
        completed: @escaping PhotoAssetMediatorCompletion<Target>
    ) -> PhotoAssetMediatorRequestToken?
    
}

public protocol PhotoAssetMediatorRequestToken {
    
    var isCancelled: Bool { get }
    
    func cancel()
    
}

public struct PhotoAssetMediatorError: Error {
    
    public let error: NSError
    public let isCancelled: Bool
    
    public init(error: NSError, isCancelled: Bool) {
        self.error = error
        self.isCancelled = isCancelled
    }
    
}
