//
//  ShareControl.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/26.
//

import UIKit
import JSCoreKit
import JSMediaBrowser
import SnapKit
import QMUIKit

class ShareControl: UIButton {
    
    var onSave: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        self.setTitle("保存", for: UIControl.State.normal)
        self.setTitleColor(.white, for: UIControl.State.normal)
        self.accessibilityLabel = "保存"
        self.addTarget(self, action: #selector(self.onPress), for: UIControl.Event.touchUpInside)
    }
    
    @available(*, unavailable, message: "use init()")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onPress() {
        self.onSave?()
    }
    
}
