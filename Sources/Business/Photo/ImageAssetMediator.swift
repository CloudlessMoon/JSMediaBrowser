//
//  ImageAssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/15.
//

import UIKit

public protocol ImageAssetMediator {
    
    func requestImage(
        source: ImageAssetSource,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken?
    
}
