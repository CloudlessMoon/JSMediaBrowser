//
//  AssetItem+Private.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/2/14.
//

import UIKit

internal extension AssetItem {
    
    func request(
        source: Any?,
        progress: @escaping AssetMediatorProgress,
        completed: @escaping AssetMediatorCompleted
    ) -> AssetMediatorRequestToken? {
        guard let source = source as? Mediator.Source else {
            assertionFailure("type mismatch")
            return nil
        }
        return self.mediator.request(source: source, progress: progress, completed: completed)
    }
    
}
