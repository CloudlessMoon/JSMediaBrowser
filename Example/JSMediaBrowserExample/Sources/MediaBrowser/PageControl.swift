//
//  PageControl.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/24.
//

import UIKit
import JSCoreKit
import JSMediaBrowser
import SnapKit
import QMUIKit

class PageControl: UIPageControl {
    
    var onValueChanged: ((Int) -> Void)?
    
    init() {
        super.init(frame: .zero)
        
        self.addTarget(self, action: #selector(self.handleValueChanged), for: .valueChanged)
    }
    
    @available(*, unavailable, message: "use init()")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleValueChanged() {
        self.onValueChanged?(self.currentPage)
    }
    
}
