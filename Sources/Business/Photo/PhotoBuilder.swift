//
//  PhotoBuilder.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/12.
//

import UIKit

public protocol PhotoBuilder {
    
    associatedtype Mediator: PhotoMediator
    associatedtype View: PhotoView where View.AssetView.Asset == Mediator.Target
    
    func createMediator() -> Mediator
    func createView() -> View
    
}
