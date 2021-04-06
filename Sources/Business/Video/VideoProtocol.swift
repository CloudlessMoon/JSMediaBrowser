//
//  VideoProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/5.
//

import UIKit
import AVKit

@objc(JSMediaBrowserVideoSourceProtocol)
public protocol VideoSourceProtocol: SourceProtocol {
    
    @objc var videoUrl: URL? { get set }
    @objc var videoAsset: AVAsset? { get set }
   
}

@objc(JSMediaBrowserVideoLoaderProtocol)
public protocol VideoLoaderProtocol: LoaderProtocol {
    
}

@objc(JSMediaBrowserViedeoActionViewProtocol)
public protocol ViedeoActionViewProtocol: NSObjectProtocol  {
    
    
}
