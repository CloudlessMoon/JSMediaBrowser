//
//  PhotoItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public protocol PhotoItem {
    
    associatedtype Builder: PhotoBuilder
    
    typealias Mediator = Builder.Mediator
    typealias Source = Builder.Mediator.Source
    typealias Target = Builder.Mediator.Target
    typealias View = Builder.View
    
    var source: Source { get }
    
    var thumbnail: UIImage? { get }
    
    var builder: Builder { get }
    
}
