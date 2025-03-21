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
            guard oldValue != self.image else {
                return
            }
            self.imageView.image = self.image
            
            self.setNeedsLayout()
        }
    }
    
    public var title: String? {
        didSet {
            guard oldValue != self.title else {
                return
            }
            self.titleLabel.text = self.title
            
            self.setNeedsLayout()
        }
    }
    
    public var space: CGFloat = 10 {
        didSet {
            guard oldValue != self.space else {
                return
            }
            self.setNeedsLayout()
        }
    }
    
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != self.contentInset else {
                return
            }
            self.setNeedsLayout()
        }
    }
    
    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    public private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        return label
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
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds.inset(by: self.contentInset)
        
        let imageSize = self.imageView.sizeThatFits(CGSize(width: bounds.width, height: 0))
        self.imageView.frame = CGRect(
            x: bounds.minX + (bounds.width - imageSize.width) / 2,
            y: bounds.minY,
            width: imageSize.width,
            height: imageSize.height
        )
        
        let titleSize = self.titleLabel.sizeThatFits(CGSize(width: bounds.width, height: 0))
        self.titleLabel.frame = CGRect(
            x: bounds.minX + (bounds.width - titleSize.width) / 2,
            y: self.imageView.frame.maxY + self.space,
            width: titleSize.width,
            height: titleSize.height
        )
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let horizontal = self.contentInset.left + self.contentInset.right
        let vertical = self.contentInset.top + self.contentInset.bottom
        let imageSize = self.imageView.sizeThatFits(CGSize(width: size.width - horizontal, height: 0))
        let titleSize = self.titleLabel.sizeThatFits(CGSize(width: size.width - horizontal, height: 0))
        return CGSize(
            width: max(imageSize.width, titleSize.width) + horizontal,
            height: imageSize.height + titleSize.height + self.space + vertical
        )
    }
    
    open override var intrinsicContentSize: CGSize {
        return self.sizeThatFits(self.bounds.size)
    }
    
}
