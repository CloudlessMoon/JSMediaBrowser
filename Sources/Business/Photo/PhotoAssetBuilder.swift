//
//  PhotoAssetBuilder.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

public protocol PhotoAssetBuilder {
    
    associatedtype Mediator: PhotoAssetMediator
    associatedtype AssetView: PhotoAssetView where AssetView.View.Asset == Mediator.Target
    
    func createMediator() -> Mediator
    func createAssetView() -> AssetView
    
}
