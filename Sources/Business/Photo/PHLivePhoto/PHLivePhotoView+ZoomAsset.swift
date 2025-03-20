//
//  PHLivePhotoView+ZoomAsset.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/30.
//

import PhotosUI

extension PHLivePhoto: ZoomAsset {}

extension PHLivePhotoView: ZoomAssetView {
    
    public var asset: PHLivePhoto? {
        get {
            return self.livePhoto
        }
        set {
            self.livePhoto = newValue
        }
    }
    
    public var renderedImage: UIImage? {
        return nil
    }
    
    public var isPlaying: Bool {
        return self.delegator?.isPlaying ?? false
    }
    
    public func startPlaying() {
        self.delegate = self.delegator
        
        self.startPlayback(with: .full)
    }
    
    public func stopPlaying() {
        self.stopPlayback()
    }
    
    private var delegator: PHLivePhotoViewDelegator? {
        var delegator = objc_getAssociatedObject(self, &AssociatedKeys.delegator) as? PHLivePhotoViewDelegator
        if delegator == nil {
            delegator = PHLivePhotoViewDelegator()
            objc_setAssociatedObject(self, &AssociatedKeys.delegator, delegator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return delegator
    }
    
}

private final class PHLivePhotoViewDelegator: NSObject, PHLivePhotoViewDelegate {
    
    var isPlaying: Bool = false
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.isPlaying = true
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.isPlaying = false
    }
    
}

private struct AssociatedKeys {
    static var delegator: UInt8 = 0
}
