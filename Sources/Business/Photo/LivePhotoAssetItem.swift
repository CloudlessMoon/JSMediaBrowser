//
//  LivePhotoAssetItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/2.
//

import UIKit

public enum LivePhotoAssetSource {
    
    case url(image: URL?, video: URL?)
    case provider(Any)
    
}

public protocol LivePhotoAssetItem: AssetItem {
    
    var source: LivePhotoAssetSource { get set }
    
}
