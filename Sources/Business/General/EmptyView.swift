//
//  EmptyView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/28.
//

import UIKit

open class EmptyView: UIView {
    
    public var image: UIImage? {
        didSet {
            self.imageView.image = self.image
            self.setNeedsLayout()
        }
    }
    
    public var title: NSAttributedString? {
        didSet {
            self.titleLabel.attributedText = self.title
            self.setNeedsLayout()
        }
    }
    
    public var subtitle: NSAttributedString? {
        didSet {
            self.subtitleLabel.attributedText = self.subtitle
            self.setNeedsLayout()
        }
    }
    
    public var actionTitle: String? {
        didSet {
            self.actionButton.setTitle(self.actionTitle, for: UIControl.State.normal)
            self.actionButton.setTitle(self.actionTitle, for: UIControl.State.selected)
            self.actionButton.setTitle(self.actionTitle, for: UIControl.State.highlighted)
            self.setNeedsLayout()
        }
    }
    
    public var onPressAction: ((UIButton) -> Void)?
    
    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    public private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    public private(set) lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    public private(set) lazy var actionButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(.white, for: UIControl.State.normal)
        button.contentEdgeInsets = UIEdgeInsets(top: CGFloat.leastNonzeroMagnitude, left: 0, bottom: CGFloat.leastNonzeroMagnitude, right: 0)
        button.addTarget(self, action: #selector(self.handleAction(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    public init() {
        super.init(frame: .zero)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    open func didInitialize() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.actionButton)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = self.imageView.sizeThatFits(CGSize(
            width: min(self.bounds.width * 0.4, 120),
            height: 0
        ))
        let titleSize = self.titleLabel.sizeThatFits(CGSize(
            width: min(self.bounds.width * 0.6, 280),
            height: 0
        ))
        let subtitleSize = self.subtitleLabel.sizeThatFits(CGSize(
            width: min(self.bounds.width * 0.75, 350),
            height: 0
        ))
        let buttonSize = self.actionButton.sizeThatFits(CGSize(
            width: subtitleSize.width * 0.6,
            height: 0
        ))
        
        let margin = 12.0
        let buttonMarginTop = 15.0
        let subviewsHeight = imageSize.height + titleSize.height + subtitleSize.height + buttonSize.height + margin * 2 + buttonMarginTop
        self.imageView.frame = CGRect(
            x: (self.bounds.width - imageSize.width) / 2,
            y: (self.bounds.height - subviewsHeight) / 2,
            width: imageSize.width,
            height: imageSize.height
        )
        self.titleLabel.frame = CGRect(
            x: (self.bounds.width - titleSize.width) / 2,
            y: self.imageView.frame.maxY + margin,
            width: titleSize.width,
            height: titleSize.height
        )
        self.subtitleLabel.frame = CGRect(
            x: (self.bounds.width - subtitleSize.width) / 2,
            y: self.titleLabel.frame.maxY + margin,
            width: subtitleSize.width,
            height: subtitleSize.height
        )
        self.actionButton.frame = CGRect(
            x: (self.bounds.width - buttonSize.width) / 2,
            y: self.subtitleLabel.frame.maxY + buttonMarginTop,
            width: buttonSize.width,
            height: buttonSize.height
        )
        
        self.imageView.isHidden = imageSize == CGSize.zero
        self.titleLabel.isHidden = titleSize.height == 0
        self.subtitleLabel.isHidden = subtitleSize.height == 0
        self.actionButton.isHidden = buttonSize.height == 0
    }
    
}

extension EmptyView {
    
    @objc private func handleAction(button: UIButton) {
        self.onPressAction?(button)
    }
    
}
