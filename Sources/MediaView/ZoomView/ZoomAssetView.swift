//
//  ZoomAssetView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/2.
//

import UIKit

public protocol ZoomAsset: Equatable {
    
    var size: CGSize { get }
    
}

public protocol ZoomAssetView: UIView {
    
    associatedtype ZoomAssetType: ZoomAsset
    
    var asset: ZoomAssetType? { get set }
    
    var isPlaying: Bool { get }
    
    func startPlaying()
    func stopPlaying()
    
}

internal extension ZoomAssetView {
    
    func isEqual(_ asset: (any ZoomAsset)?) -> Bool {
        let lhs = self.asset
        let rhs = self.asAsset(asset)
        return lhs == rhs
    }
    
    func setAsset(_ asset: (any ZoomAsset)?) {
        guard let asset = asset else {
            self.asset = nil
            return
        }
        assert(self.isAsset(asset), "类型不匹配")
        self.asset = self.asAsset(asset)
    }
    
    private func asAsset(_ asset: (any ZoomAsset)?) -> ZoomAssetType? {
        return asset as? ZoomAssetType
    }
    
    private func isAsset(_ asset: any ZoomAsset) -> Bool {
        return asset is ZoomAssetType
    }
    
}
