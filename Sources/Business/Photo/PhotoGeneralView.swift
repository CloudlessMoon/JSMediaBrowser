//
//  PhotoGeneralView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/3/14.
//

import UIKit

open class PhotoGeneralView<ZoomViewType: ZoomView<ZoomAssetViewType>, ZoomAssetViewType: ZoomAssetView>: UIView, PhotoView {
    
    public struct Configuration {
        public var emptyImage: UIImage?
        
        public init(emptyImage: UIImage? = nil) {
            self.emptyImage = emptyImage
        }
    }
    
    public let configuration: Configuration
    
    public let zoomView: ZoomViewType
    
    public private(set) lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 8
        view.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        return view
    }()
    
    public private(set) lazy var progressView: PieProgressView = {
        let view = PieProgressView()
        view.tintColor = .white
        view.backgroundColor = .black.withAlphaComponent(0.15)
        view.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return view
    }()
    
    private var error: PhotoMediatorError? {
        didSet {
            self.updateProgress()
        }
    }
    
    private var progress: Float? {
        didSet {
            guard oldValue != self.progress else {
                return
            }
            self.updateProgress()
        }
    }
    
    public init(configuration: Configuration, zoomView: ZoomViewType) {
        self.configuration = configuration
        self.zoomView = zoomView
        
        super.init(frame: .zero)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func didInitialize() {
        self.addSubview(self.zoomView)
        self.addSubview(self.progressView)
        self.addSubview(self.emptyView)
        
        self.updateUI()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.zoomView.frame = self.bounds
        
        let spacing = 30.0
        let emptyLimitSize = CGSize(width: self.bounds.width - spacing, height: .greatestFiniteMagnitude)
        let emptySize = self.emptyView.sizeThatFits(emptyLimitSize)
        self.emptyView.frame = CGRect(
            x: (self.bounds.width - emptySize.width) / 2,
            y: (self.bounds.height - emptySize.height) / 2,
            width: emptySize.width,
            height: emptySize.height
        )
        
        let progressSize = min(self.bounds.width * 0.15, 75)
        self.progressView.frame = CGRect(
            x: (self.bounds.width - progressSize) / 2,
            y: (self.bounds.height - progressSize) / 2,
            width: progressSize,
            height: progressSize
        )
        if self.progressView.layer.cornerRadius != progressSize / 2 {
            self.progressView.layer.cornerRadius = progressSize / 2
        }
    }
    
}

extension PhotoGeneralView {
    
    public func setAsset(_ asset: ZoomAssetViewType.Asset?) {
        self.zoomView.asset = asset
    }
    
    public func setThumbnail(_ thumbnail: UIImage?) {
        self.zoomView.thumbnail = thumbnail
    }
    
    public func setProgress(received: Int, expected: Int) {
        if expected > 0 {
            self.progress = Float(received) / Float(expected)
        } else {
            self.progress = nil
        }
        
        self.progressView.setValue(self.progress ?? 0, animated: true)
    }
    
    public func setError(_ error: PhotoMediatorError?) {
        if let error = error, !error.isCancelled {
            self.error = error
        } else {
            self.error = nil
        }
        
        if let error = self.error {
            self.emptyView.title = error.localizedDescription
            self.emptyView.isHidden = false
        } else {
            self.emptyView.isHidden = true
        }
        
        self.setNeedsLayout()
    }
    
}

extension PhotoGeneralView {
    
    private func updateUI() {
        self.emptyView.image = self.configuration.emptyImage
        
        self.setError(nil)
        self.updateProgress()
    }
    
    private func updateProgress() {
        if self.error != nil || self.progress == 1 || self.progress == nil {
            self.progressView.isHidden = true
        } else {
            self.progressView.isHidden = false
        }
    }
    
}
