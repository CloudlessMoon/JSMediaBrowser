//
//  Browser.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2025/1/2.
//

import UIKit
import JSMediaBrowser

struct ImageItem: ImageAssetItem {
    
    var thumbnail: UIImage?
    
    var image: UIImage?
    var imageURL: URL?
    
    init(image: UIImage? = nil, imageURL: URL? = nil, thumbnail: UIImage? = nil) {
        self.image = image
        self.imageURL = imageURL
        self.thumbnail = thumbnail
    }
    
}

struct LivePhotoItem: LivePhotoAssetItem {
    
    var thumbnail: UIImage?
    
    var imageURL: URL
    var videoURL: URL
    
    init(imageURL: URL, videoURL: URL, thumbnail: UIImage? = nil) {
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.thumbnail = thumbnail
    }
    
}
