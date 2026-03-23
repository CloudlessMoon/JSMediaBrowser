//
//  Transition.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2026/3/20.
//

public enum TransitionStyle: Equatable {
    case zoom
    case fade
}

public enum TransitionType: Equatable {
    case appear(style: TransitionStyle)
    case disappear(style: TransitionStyle)
    
    public var isAppear: Bool {
        switch self {
        case .appear:
            return true
        case .disappear:
            return false
        }
    }
    
    public var isDisappear: Bool {
        switch self {
        case .appear:
            return false
        case .disappear:
            return true
        }
    }
    
    public var style: TransitionStyle {
        switch self {
        case .appear(let style):
            return style
        case .disappear(let style):
            return style
        }
    }
}

public struct TransitionContext {
    
    public let type: TransitionType
    public let isInteractive: Bool
    public let percentComplete: CGFloat
    public let isCancelled: Bool
    
    public init(
        type: TransitionType,
        isInteractive: Bool,
        percentComplete: CGFloat,
        isCancelled: Bool
    ) {
        self.type = type
        self.isInteractive = isInteractive
        self.percentComplete = percentComplete
        self.isCancelled = isCancelled
    }
    
}

public typealias TransitionContextCaller = (TransitionContext) -> Void
