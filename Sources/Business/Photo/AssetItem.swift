//
//  AssetItem.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public protocol AssetItem {
    
    associatedtype Mediator: AssetMediator
    
    var source: Mediator.Source { get }
    
    var thumbnail: UIImage? { get }
    
    var mediator: Mediator { get }
    
}
