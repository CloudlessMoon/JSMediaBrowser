//
//  AssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/31.
//

import UIKit

public typealias AssetMediatorProgress = (_ receivedSize: Int, _ expectedSize: Int) -> Void
public typealias AssetMediatorCompleted = (Result<AssetMediatorResult, AssetMediatorError>) -> Void

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

public protocol AssetMediatorRequestToken {
    
    var isCancelled: Bool { get }
    
    func cancel()
    
}

internal extension UIView {
    
    private struct AssociatedKeys {
        static var token: UInt8 = 0
    }
    
    var requestToken: AssetMediatorRequestToken? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.token) as? AssetMediatorRequestToken
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.token, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
