//
//  ImageAssetItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public protocol ImageAssetItem: AssetItem {
    
    var image: UIImage? { get set }
    var imageURL: URL? { get set }
    
}