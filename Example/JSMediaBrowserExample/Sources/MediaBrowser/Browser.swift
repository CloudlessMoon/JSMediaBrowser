//
//  Browser.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2025/1/2.
//

import UIKit
import JSMediaBrowser

struct ImageItem: ImageAssetItem {

    var source: ImageAssetSource
    
    var thumbnail: UIImage?
    
}

struct LivePhotoItem: LivePhotoAssetItem {
    
    var source: LivePhotoAssetSource
    
    var thumbnail: UIImage?

}
