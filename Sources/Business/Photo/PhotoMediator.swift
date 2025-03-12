//
//  PhotoMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/31.
//

import Foundation

public typealias PhotoMediatorProgress = (_ receivedSize: Int, _ expectedSize: Int) -> Void
public typealias PhotoMediatorCompletion<Target: ZoomAsset> = (Result<Target?, PhotoMediatorError>) -> Void

public protocol PhotoMediator {
    
    associatedtype Source
    associatedtype Target: ZoomAsset
    
    func request(
        source: Source,
        progress: @escaping PhotoMediatorProgress,
        completed: @escaping PhotoMediatorCompletion<Target>
    ) -> PhotoMediatorRequestToken?
    
}

public protocol PhotoMediatorRequestToken {
    
    var isCancelled: Bool { get }
    
    func cancel()
    
}

public struct PhotoMediatorError: Error {
    
    public let error: NSError
    public let isCancelled: Bool
    
    public init(error: NSError, isCancelled: Bool) {
        self.error = error
        self.isCancelled = isCancelled
    }
    
}
