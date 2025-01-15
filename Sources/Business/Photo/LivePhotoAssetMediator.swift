//
//  LivePhotoAssetMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/15.
//

import Foundation

public protocol LivePhotoAssetMediator {
    
    func requestLivePhoto(
        imageURL: URL,
        videoURL: URL,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken
    
}
