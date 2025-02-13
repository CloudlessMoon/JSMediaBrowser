//
//  ImageAssetItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public enum ImageAssetSource {
    
    case url(URL?)
    case provider(Any)
    
}

public protocol ImageAssetItem: AssetItem {
    
    var source: ImageAssetSource { get set }
    
}
