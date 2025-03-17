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

public struct PhotoMediatorError: CustomNSError {
    
    public static var errorDomain: String {
        return "com.jiasong.JSMediaBrowser.error"
    }
    
    public let errorCode: Int
    public let errorUserInfo: [String: Any]
    public let isCancelled: Bool
    
    public init(error: NSError, cancelled: Bool) {
        self.errorCode = error.code
        self.errorUserInfo = error.userInfo
        self.isCancelled = cancelled
    }
    
    public init(code: Int, userInfo: [String: Any], cancelled: Bool) {
        self.errorCode = code
        self.errorUserInfo = userInfo
        self.isCancelled = cancelled
    }
    
}
