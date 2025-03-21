//
//  PieProgressView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit

open class PieProgressView: UIControl {
    
    public enum Shape: Int {
        case sector
        case ring
    }
    
    public private(set) var value: Float = 0.0
    
    public var shape: Shape = .sector {
        didSet {
            guard oldValue != self.shape else {
                return
            }
            self.progressLayer.shape = self.shape
        }
    }
    
    public var animationDuration: CFTimeInterval = 0.5 {
        didSet {
            guard oldValue != self.animationDuration else {
                return
            }
            self.progressLayer.animationDuration = self.animationDuration
        }
    }
    
    public var minimumProgress: Float = 0.05 {
        didSet {
            guard oldValue != self.minimumProgress else {
                return
            }
            self.setValue(self.value, animated: false)
        }
    }
    
    public var trackWidth: CGFloat = 2.0 {
        didSet {
            guard oldValue != self.trackWidth else {
                return
            }
            self.progressLayer.trackWidth = self.trackWidth
            self.trackLayer.borderWidth = self.trackWidth
        }
    }
    
    public var trackColor: UIColor? {
        didSet {
            guard oldValue != self.trackColor else {
                return
            }
            self.progressLayer.trackColor = self.trackColor
            self.trackLayer.borderColor = self.trackColor?.cgColor
        }
    }
    
    public var lineWidth: CGFloat = 2.0 {
        didSet {
            guard oldValue != self.lineWidth else {
                return
            }
            self.progressLayer.lineWidth = self.lineWidth
        }
    }
    
    public var spacing: CGFloat = 3.0 {
        didSet {
            guard oldValue != self.spacing else {
                return
            }
            self.progressLayer.spacing = self.spacing
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
    
    private lazy var progressLayer: PieProgressLayer = {
        return PieProgressLayer()
    }()
    
    private lazy var trackLayer: CALayer = {
        return CALayer()
    }()
    
    public init() {
        super.init(frame: .zero)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func didInitialize() {
        self.backgroundColor = nil
        self.layer.addSublayer(self.trackLayer)
        self.layer.addSublayer(self.progressLayer)
        
        self.updateUI()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds.inset(by: self.contentInset)
        
        self.progressLayer.frame = bounds
        self.progressLayer.cornerRadius = min(bounds.width, bounds.height) / 2
        
        self.trackLayer.frame = self.progressLayer.frame
        self.trackLayer.cornerRadius = self.progressLayer.cornerRadius
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        self.progressLayer.fillColor = self.tintColor
        self.progressLayer.strokeColor = self.tintColor
        
        if self.trackColor == nil {
            self.progressLayer.trackColor = self.tintColor
            self.trackLayer.borderColor = self.tintColor.cgColor
        }
    }
    
}

extension PieProgressView {
    
    public func setValue(_ value: Float, animated: Bool) {
        let value = max(self.minimumProgress, min(1.0, value))
        guard self.value != value else {
            return
        }
        self.value = value
        
        self.progressLayer.shouldChangeProgressWithAnimation = animated
        self.progressLayer.progress = self.value
        self.progressLayer.setNeedsDisplay()
        self.sendActions(for: UIControl.Event.valueChanged)
    }
    
}

extension PieProgressView {
    
    private func updateUI() {
        self.progressLayer.shape = self.shape
        
        self.progressLayer.animationDuration = self.animationDuration
        
        self.progressLayer.trackWidth = self.trackWidth
        self.trackLayer.borderWidth = self.trackWidth
        
        self.progressLayer.trackColor = self.trackColor
        self.trackLayer.borderColor = self.trackColor?.cgColor
        
        self.progressLayer.lineWidth = self.lineWidth
        
        self.progressLayer.spacing = self.spacing
        
        self.setValue(self.minimumProgress, animated: false)
    }
    
}

private class PieProgressLayer: CALayer {
    
    @NSManaged var progress: Float
    @NSManaged var fillColor: UIColor?
    @NSManaged var strokeColor: UIColor?
    @NSManaged var trackWidth: CGFloat
    @NSManaged var trackColor: UIColor?
    @NSManaged var lineWidth: CGFloat
    @NSManaged var spacing: CGFloat
    
    fileprivate var shape: PieProgressView.Shape = .sector
    fileprivate var animationDuration: CFTimeInterval = 0.5
    fileprivate var shouldChangeProgressWithAnimation: Bool = true
    
    override init() {
        super.init()
        self.didInitialize()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didInitialize() {
        self.contentsScale = UIScreen.main.scale
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        return key == #keyPath(progress) || super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == #keyPath(progress) && self.shouldChangeProgressWithAnimation {
            let animation: CABasicAnimation = CABasicAnimation(keyPath: event)
            animation.fromValue = self.presentation()?.value(forKey: event)
            animation.duration = self.animationDuration
            return animation
        }
        return super.action(forKey: event)
    }
    
    override func draw(in context: CGContext) {
        super.draw(in: context)
        if self.bounds.isEmpty {
            return
        }
        
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let startAngle = CGFloat(-Float.pi / 2)
        let endAngle = CGFloat(Float.pi * 2 * self.progress) + startAngle
        
        switch self.shape {
        case .sector:
            // 绘制扇形进度区域
            let radius = min(center.x, center.y) - self.trackWidth - self.spacing
            context.setFillColor(self.fillColor?.cgColor ?? UIColor.clear.cgColor)
            context.move(to: center)
            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.closePath()
            context.fillPath()
        case .ring:
            // 绘制环形进度区域
            let radius = min(center.x, center.y) - max(self.trackWidth, self.lineWidth) / 2 - self.spacing
            context.setLineWidth(self.lineWidth)
            context.setStrokeColor(self.strokeColor?.cgColor ?? UIColor.clear.cgColor)
            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.strokePath()
        }
    }
    
}
