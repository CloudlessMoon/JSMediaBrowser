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
        completed: @escaping (Result<(any ZoomAsset)?, AssetMediatorError>) -> Void
    ) -> AssetMediatorRequestToken? {
        guard let source = source as? Mediator.Source else {
            assertionFailure("type mismatch")
            return nil
        }
        return self.mediator.request(
            source: source,
            progress: progress,
            completed: { result in
                switch result {
                case .success(let asset):
                    completed(.success(asset))
                case .failure(let error):
                    completed(.failure(error))
                }
            }
        )
    }
    
    var targetType: Mediator.Target.Type {
        return Mediator.Target.self
    }
    
}
