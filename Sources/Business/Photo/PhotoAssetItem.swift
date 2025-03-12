//
//  PhotoAssetItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public protocol PhotoAssetItem {
    
    associatedtype Builder: PhotoAssetBuilder
    
    typealias Mediator = Builder.Mediator
    typealias Source = Builder.Mediator.Source
    typealias Target = Builder.Mediator.Target
    typealias AssetView = Builder.AssetView
    
    var source: Source { get }
    
    var thumbnail: UIImage? { get }
    
    var builder: Builder { get }
    
}
