//
//  BasisCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

open class BasisCell: UICollectionViewCell {
    
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
    
    public var onPressEmpty: (() -> Void)?
    public var willDisplayEmptyView: ((EmptyView, NSError) -> Void)?
    
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
        self.contentView.addSubview(self.progressView)
        
        self.emptyView.onPressAction = { [weak self] _ in
            guard let self = self else { return }
            self.onPressEmpty?()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.emptyView.frame = self.bounds
        
        let width = min(self.bounds.width * 0.12, 60)
        let progressSize = CGSize(width: width, height: width)
        let progressPoint = CGPoint(x: (self.bounds.width - progressSize.width) / 2, y: (self.bounds.height - progressSize.height) / 2)
        self.progressView.frame = CGRect(origin: progressPoint, size: progressSize)
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
            self.progressView.isHidden = true
        } else {
            self.progressView.isHidden = false
        }
    }
    
}
