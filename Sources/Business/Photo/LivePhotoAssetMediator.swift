//
//  LivePhotoAssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/15.
//

import UIKit

public protocol LivePhotoAssetMediator {
    
    func requestLivePhoto(
        source: LivePhotoAssetSource,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken?
    
}
