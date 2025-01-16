//
//  AssetMediator+Private.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/16.
//

import UIKit

internal extension UIView {
    
    struct AtomicInt: Equatable {
        
        private static var current: UInt = 1
        
        private let value: UInt
        
        init() {
            let value = AtomicInt.current
            AtomicInt.current = value + 1
            self.value = value
        }
    }
    
    var mb_requestToken: AssetMediatorRequestToken? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.token) as? AssetMediatorRequestToken
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.token, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var mb_requestIdentifier: AtomicInt? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.requestIdentifier) as? AtomicInt
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.requestIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

private struct AssociatedKeys {
    static var token: UInt8 = 0
    static var requestIdentifier: UInt8 = 0
}
