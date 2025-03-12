//
//  PhotoCell+Private.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/16.
//

import UIKit

internal extension PhotoCell {
    
    struct AtomicInt: Equatable {
        
        private var value: UInt
        
        init() {
            self.value = 0
        }
        
        mutating func increment() -> Self {
            self.value += 1
            return self
        }
        
    }
    
    var mb_requestToken: PhotoMediatorRequestToken? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.token) as? PhotoMediatorRequestToken
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
