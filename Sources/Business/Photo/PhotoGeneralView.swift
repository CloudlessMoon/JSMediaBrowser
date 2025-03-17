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
        public var progressTintColor: UIColor?
        public var progressBackgroundColor: UIColor?
        
        public init(
            emptyImage: UIImage? = nil,
            progressTintColor: UIColor? = .white,
            progressBackgroundColor: UIColor? = .black.withAlphaComponent(0.15)
        ) {
            self.emptyImage = emptyImage
            self.progressTintColor = progressTintColor
            self.progressBackgroundColor = progressBackgroundColor
        }
    }
    
    public let configuration: Configuration
    
    public let zoomView: ZoomViewType
    
    public private(set) lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.isHidden = true
        return view
    }()
    
    public private(set) lazy var progressView: PieProgressView = {
        let view = PieProgressView()
        return PieProgressView()
    }()
    
    public private(set) lazy var progressBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private var error: NSError? {
        didSet {
            guard oldValue != self.error else {
                return
            }
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
        self.addSubview(self.emptyView)
        self.addSubview(self.progressBackgroundView)
        self.progressBackgroundView.addSubview(self.progressView)
        
        self.emptyView.image = self.configuration.emptyImage
        self.progressView.tintColor = self.configuration.progressTintColor
        self.progressBackgroundView.backgroundColor = self.configuration.progressBackgroundColor
        
        self.updateProgress()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.zoomView.frame = self.bounds
        self.emptyView.frame = self.bounds
        
        let progressBackgroundSize = min(self.bounds.width * 0.16, 80)
        self.progressBackgroundView.frame = CGRect(
            x: (self.bounds.width - progressBackgroundSize) / 2,
            y: (self.bounds.height - progressBackgroundSize) / 2,
            width: progressBackgroundSize,
            height: progressBackgroundSize
        )
        let progressSize = progressBackgroundSize - 20
        self.progressView.frame = CGRect(
            x: (progressBackgroundSize - progressSize) / 2,
            y: (progressBackgroundSize - progressSize) / 2,
            width: progressSize,
            height: progressSize
        )
    }
    
}

extension PhotoGeneralView {
    
    public func setAsset(_ asset: ZoomAssetViewType.Asset?, thumbnail: UIImage?) {
        self.zoomView.asset = asset
        self.zoomView.thumbnail = thumbnail
    }
    
    public func setProgress(received: Int, expected: Int) {
        if expected > 0 {
            self.progress = Float(received) / Float(expected)
        } else {
            self.progress = nil
        }
        
        self.progressView.setProgress(self.progress ?? 0, animated: true)
    }
    
    public func setError(_ error: NSError?, cancelled: Bool) {
        self.error = error
        
        if let error = error {
            self.emptyView.title = NSAttributedString(string: error.localizedDescription, attributes: nil)
            self.emptyView.isHidden = false
        } else {
            self.emptyView.isHidden = true
        }
    }
    
}

extension PhotoGeneralView {
    
    private func updateProgress() {
        if self.error != nil || self.progress == 1 || self.progress == nil {
            self.progressBackgroundView.isHidden = true
        } else {
            self.progressBackgroundView.isHidden = false
        }
    }
    
}
