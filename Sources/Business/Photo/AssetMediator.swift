//
//  AssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/31.
//

import Foundation

public typealias AssetMediatorProgress = (_ receivedSize: Int, _ expectedSize: Int) -> Void
public typealias AssetMediatorCompletion<Target: ZoomAsset> = (Result<Target?, AssetMediatorError>) -> Void

public protocol AssetMediator {
    
    associatedtype Source
    associatedtype Target: ZoomAsset
    
    func request(
        source: Source,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompletion<Target>
    ) -> AssetMediatorRequestToken?
    
}

public protocol AssetMediatorRequestToken {
    
    var isCancelled: Bool { get }
    
    func cancel()
    
}

public struct AssetMediatorError: Error {
    
    public let error: NSError
    public let isCancelled: Bool
    
    public init(error: NSError, isCancelled: Bool) {
        self.error = error
        self.isCancelled = isCancelled
    }
    
}
