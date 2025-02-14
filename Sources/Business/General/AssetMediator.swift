//
//  AssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/31.
//

import Foundation

public typealias AssetMediatorProgress = (_ receivedSize: Int, _ expectedSize: Int) -> Void
public typealias AssetMediatorCompleted = (Result<AssetMediatorResult, AssetMediatorError>) -> Void

public protocol AssetMediator {
    
    associatedtype Source
    
    func request(
        source: Source,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken?
    
}

public protocol AssetMediatorRequestToken {
    
    var isCancelled: Bool { get }
    
    func cancel()
    
}

public struct AssetMediatorResult {
    
    public let asset: (any ZoomAsset)?
    
    public init(asset: (any ZoomAsset)?) {
        self.asset = asset
    }
    
}

public struct AssetMediatorError: Error {
    
    public let error: NSError
    public let isCancelled: Bool
    
    public init(error: NSError, isCancelled: Bool) {
        self.error = error
        self.isCancelled = isCancelled
    }
    
}
