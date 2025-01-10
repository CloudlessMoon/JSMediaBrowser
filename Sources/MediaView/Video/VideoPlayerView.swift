//
//  VideoPlayerView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import AVKit
import JSCoreKit

public enum Stauts: Int {
    case stopped = 0
    case ready
    case playing
    case paused
    case ended
    case failed
}

open class VideoPlayerView: BasisMediaView {
    
    public weak var delegate: VideoPlayerViewDelegate?
    
    public var url: URL? {
        didSet {
            if let url = self.url {
                if oldValue != url {
                    let item: AVPlayerItem = AVPlayerItem(url: url)
                    self.playerItem = item
                }
            }
        }
    }
    
    public var asset: AVAsset? {
        didSet {
            if let asset = self.asset {
                if oldValue != asset {
                    let item: AVPlayerItem = AVPlayerItem(asset: asset)
                    self.playerItem = item
                }
            }
        }
    }
    
    public var playerItem: AVPlayerItem? {
        willSet {
            if newValue != nil && newValue != self.playerItem {
                self.removeObserverForPlayerItem()
            }
        }
        didSet {
            if let playerItem = self.playerItem {
                if oldValue != playerItem {
                    self.addObserverForPlayerItem()
                    self.player.replaceCurrentItem(with: playerItem)
                }
            }
        }
    }
    
    public var currentTime: CGFloat {
        return CGFloat(CMTimeGetSeconds(self.player.currentTime()))
    }
    
    public private(set) var totalDuration: CGFloat = 0.0
    
    public var rate: CGFloat {
        get {
            return CGFloat(self.player.rate)
        }
        set {
            self.player.rate = Float(newValue)
        }
    }
    
    public var isAutoPlay: Bool = true
    
    public var status: Stauts = .stopped {
        didSet {
            if self.status == .ready {
                self.delegate?.didReadyForDisplay(in: self)
            } else if self.status == .failed {
                self.delegate?.videoPlayerView(self, didFailed: self.player.error as NSError?)
            } else if self.status == .ended || status == .stopped {
                self.delegate?.didPlayToEndTime(in: self)
            }
            
            if self.status == .ended {
                self.seek(to: 0) { finished in
                    self.player.play()
                }
            }
        }
    }
    
    public var thumbnail: UIImage? {
        didSet {
            self.thumbnailView.image = self.thumbnail
            self.updateThumbnailView()
            self.setNeedsLayout()
        }
    }
    
    private lazy var thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        self.sendSubviewToBack(imageView)
        return imageView
    }()
    
    private lazy var player: AVPlayer = {
        let player = AVPlayer(playerItem: nil)
        self.playerLayer.player = player
        self.playerLayer.videoGravity = .resizeAspect
        return player
    }()
    
    private lazy var playerView: AVPlayerView = {
        let playerView = AVPlayerView()
        return playerView
    }()
    
    private var playerLayer: AVPlayerLayer {
        guard let layer = self.playerView.layer as? AVPlayerLayer else {
            fatalError()
        }
        return layer
    }
    
    private var playerItemObservers = [NSKeyValueObservation]()
    private var playerObservers = [NSKeyValueObservation]()
    private var playerItemCenterObservers = [AnyObject]()
    private var playerTimeObservers = [Any]()
    private var systemObservers = [AnyObject]()
    private var currentFrameImageRef: CGImage?
    
    open override func didInitialize() {
        super.didInitialize()
        self.addSubview(self.playerView)
        self.addObserverForSystem()
        self.addObserverForPlayer()
    }
    
    deinit {
        self.removeObserverForPlayerItem()
        self.removeObserverForPlayer()
        self.removeObserverForSystem()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let viewport = self.finalViewportRect
        self.playerView.js_frameApplyTransform = viewport
        
        if let image = self.thumbnail {
            /// scaleAspectFit
            let horizontalRatio = viewport.width / image.size.width
            let verticalRatio = viewport.height / image.size.height
            let ratio = min(horizontalRatio, verticalRatio)
            let resizedSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
            var rect = CGRect(origin: CGPoint.zero, size: resizedSize)
            rect.origin.x = viewport.minX + (viewport.width - resizedSize.width) / 2.0
            rect.origin.y = viewport.minY + (viewport.height - resizedSize.height) / 2.0
            self.thumbnailView.js_frameApplyTransform = rect
        }
    }
    
    public override var contentView: UIView? {
        if self.isReadyForDisplay {
            return self.playerView
        } else {
            return self.thumbnailView
        }
    }
    
    public override var contentViewFrame: CGRect {
        if self.isReadyForDisplay {
            return self.convert(self.playerLayer.videoRect, from: self.playerView)
        } else {
            return self.convert(self.thumbnailView.frame, from: self.thumbnailView.superview)
        }
    }
    
}

extension VideoPlayerView {
    
    public var isReadyForDisplay: Bool {
        return self.playerLayer.isReadyForDisplay
    }
    
    public func play() {
        if self.status == .ready || self.status == .paused {
            self.player.play()
            self.status = .playing
            self.updateThumbnailView()
        }
    }
    
    public func pause() {
        self.player.pause()
        self.status = .paused
    }
    
    public func reset() {
        self.player.pause()
        self.seek(to: 0) { (finished) in
            self.status = self.playerItem?.status == .readyToPlay ? .ready : .stopped
        }
    }
    
    public func releasePlayer() {
        self.playerItem = nil
        self.player.replaceCurrentItem(with: nil)
        self.status = .stopped
    }
    
    public var currentFrameImage: UIImage? {
        guard let currentFrameImageRef = self.currentFrameImageRef else {
            return nil
        }
        return UIImage(cgImage: currentFrameImageRef)
    }
    
    public func seek(to time: CGFloat, completionHandler: ((Bool) -> Void)? = nil) {
        let startTime: CMTime = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: self.player.currentTime().timescale)
        if !CMTIME_IS_INDEFINITE(startTime) && !CMTIME_IS_INVALID(startTime) {
            self.player.seek(to: startTime, toleranceBefore: CMTimeMake(value: 1, timescale: 1000), toleranceAfter: CMTimeMake(value: 1, timescale: 1000), completionHandler: { (finished) in
                completionHandler?(finished)
            })
        } else {
            completionHandler?(false)
        }
    }
    
}

extension VideoPlayerView {
    
    private func updateThumbnailView() {
        self.thumbnailView.isHidden = self.thumbnail == nil || self.isReadyForDisplay
    }
    
    private func generateCurrentFrameImage() {
        guard let asset = self.player.currentItem?.asset else {
            return
        }
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: self.player.currentTime())]) { _, cgImage, _, _, error in
            guard let cgImage = cgImage else {
                return
            }
            DispatchQueue.main.async {
                self.currentFrameImageRef = cgImage
            }
        }
    }
    
}

extension VideoPlayerView {
    
    private func addObserverForPlayer() {
        /// progress
        self.playerTimeObservers.append(
            self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self](time: CMTime) in
                guard let self = self else {
                    return
                }
                self.delegate?.videoPlayerView(self, periodicTime: CGFloat(CMTimeGetSeconds(time)), totalDuration: self.totalDuration)
                
                self.generateCurrentFrameImage()
            })
        )
        /// isReadyForDisplay
        self.playerObservers.append(
            self.playerLayer.observe(\.self.isReadyForDisplay, options: .new, changeHandler: { [weak self] (playerLayer: AVPlayerLayer, change) in
                guard let self = self else { return }
                if self.playerItem?.status == .readyToPlay {
                    self.updateThumbnailView()
                }
            })
        )
    }
    
    private func addObserverForPlayerItem() {
        if let playerItem = self.playerItem {
            /// status
            self.playerItemObservers.append(
                playerItem.observe(\.status, options: .new, changeHandler: { [weak self](playerItem: AVPlayerItem, change) in
                    guard let self = self else {
                        return
                    }
                    if playerItem.status == .readyToPlay {
                        /// see loadedTimeRanges
                    } else if playerItem.status == .failed {
                        self.status = .failed
                    }
                })
            )
            /// PlayToEndTime
            self.playerItemCenterObservers.append(
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: OperationQueue.main) { [weak self](notification: Notification) in
                    guard let self = self else {
                        return
                    }
                    if self.playerItem == notification.object as? AVPlayerItem {
                        self.status = .ended
                    }
                }
            )
            /// loadedTimeRanges
            self.playerItemObservers.append(
                playerItem.observe(\.loadedTimeRanges, options: .new, changeHandler: { [weak self] (playerItem: AVPlayerItem, change) in
                    guard let self = self else {
                        return
                    }
                    let loadedTimeRanges: [NSValue] = playerItem.loadedTimeRanges
                    guard loadedTimeRanges.count > 0 else {
                        return
                    }
                    // 获取缓冲区域
                    let timeRange: CMTimeRange = loadedTimeRanges.first?.timeRangeValue ?? CMTimeRange.zero
                    // 开始的时间
                    let startSeconds: TimeInterval = CMTimeGetSeconds(timeRange.start)
                    // 表示已经缓冲的时间
                    let durationSeconds: TimeInterval = CMTimeGetSeconds(timeRange.duration)
                    // 计算缓冲总时间
                    let _: TimeInterval = startSeconds + durationSeconds
                    
                    if self.status != .ready && playerItem.status == .readyToPlay {
                        self.status = .ready
                        self.totalDuration = CGFloat(CMTimeGetSeconds(playerItem.duration))
                        self.updateThumbnailView()
                        if self.isAutoPlay {
                            self.play()
                        }
                    }
                })
            )
        }
    }
    
    private func removeObserverForPlayer() {
        /// 移除playerObservers
        for observer in self.playerObservers {
            observer.invalidate()
        }
        self.playerObservers.removeAll()
        /// 移除playerTimeObservers
        for observer in self.playerTimeObservers {
            self.player.removeTimeObserver(observer)
        }
        self.playerTimeObservers.removeAll()
    }
    
    private func removeObserverForPlayerItem() {
        /// 移除playerItemObservers
        for observer in self.playerItemObservers {
            observer.invalidate()
        }
        self.playerItemObservers.removeAll()
        /// 移除playerItemCenterObservers
        for observer in self.self.playerItemCenterObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.playerItemCenterObservers.removeAll()
    }
    
    private func addObserverForSystem() {
        self.systemObservers.append(
            NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main, using: { [weak self](notification: Notification) in
                if let strongSelf = self, strongSelf.status == .playing {
                    strongSelf.pause()
                }
            })
        )
    }
    
    private func removeObserverForSystem() {
        for observer in self.systemObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        self.systemObservers.removeAll()
    }
    
}

private class AVPlayerView: UIView {
    
    public override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
}
