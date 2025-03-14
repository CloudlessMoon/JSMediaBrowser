//
//  BasisCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

open class BasisCell: UICollectionViewCell {
    
    public var onPressEmpty: (() -> Void)?
    public var willDisplayEmptyView: ((EmptyView, NSError) -> Void)?
    
    public private(set) lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.isHidden = true
        return view
    }()
    
    public private(set) lazy var progressView: PieProgressView = {
        let view = PieProgressView()
        view.tintColor = .white
        return view
    }()
    
    private lazy var progressBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.15)
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
    
    private var progress = Progress() {
        didSet {
            guard oldValue != self.progress else {
                return
            }
            self.updateProgress()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    open func didInitialize() {
        self.contentView.addSubview(self.emptyView)
        self.contentView.addSubview(self.progressBackgroundView)
        self.progressBackgroundView.addSubview(self.progressView)
        
        self.emptyView.onPressAction = { [weak self] _ in
            guard let self = self else { return }
            self.onPressEmpty?()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
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

extension BasisCell {
    
    public func setProgress(_ progress: Progress) {
        self.progress = progress
        
        self.progressView.setProgress(Float(progress.fractionCompleted), animated: true)
    }
    
    public func setError(_ error: NSError?) {
        self.error = error
        
        if let error = error {
            self.emptyView.title = NSAttributedString(string: error.localizedDescription, attributes: nil)
            self.willDisplayEmptyView?(self.emptyView, error)
            self.emptyView.isHidden = false
        } else {
            self.emptyView.isHidden = true
        }
    }
    
}

extension BasisCell {
    
    private func updateProgress() {
        if self.error != nil || self.progress.fractionCompleted == 1.0 || self.progress.totalUnitCount == 0 {
            self.progressBackgroundView.isHidden = false
        } else {
            self.progressBackgroundView.isHidden = false
        }
    }
    
}
