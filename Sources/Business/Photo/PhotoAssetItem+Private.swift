//
//  PhotoAssetItem+Private.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/2/14.
//

import UIKit

internal extension PhotoAssetItem {
    
    func request(
        source: Any?,
        progress: @escaping PhotoAssetMediatorProgress,
        completed: @escaping (Result<(any ZoomAsset)?, PhotoAssetMediatorError>) -> Void
    ) -> PhotoAssetMediatorRequestToken? {
        guard let source = source as? Builder.Mediator.Source else {
            assertionFailure("type mismatch")
            return nil
        }
        return self.builder.createMediator().request(
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
    
    var targetType: Target.Type {
        return Target.self
    }
    
}
