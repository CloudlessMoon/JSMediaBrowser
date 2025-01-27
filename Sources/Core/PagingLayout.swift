//
//  PagingLayout.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public class PagingLayout: UICollectionViewFlowLayout {
    
    public var pageSpacing: CGFloat = 10
    
    public override init() {
        super.init()
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func didInitialize() {
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.scrollDirection = .horizontal
        self.sectionInset = .zero
    }
    
}

extension PagingLayout {
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var resultAttributes: [UICollectionViewLayoutAttributes] = []
        let originalAttributes: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect) ?? []
        for originalAttributesItem in originalAttributes {
            if let attributesItem = self.layoutAttributesForItem(at: originalAttributesItem.indexPath), attributesItem.frame.intersects(rect) {
                resultAttributes.append(attributesItem)
            }
        }
        return resultAttributes
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = self.collectionView else {
            return nil
        }
        if let attributesItem = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes {
            if attributesItem.size.width <= 0 || attributesItem.size.height <= 0 {
                return attributesItem
            }
            
            let halfWidth: CGFloat = attributesItem.size.width / 2.0
            let centerX: CGFloat = collectionView.contentOffset.x + halfWidth
            attributesItem.center = CGPoint(
                x: attributesItem.center.x + (attributesItem.center.x - centerX) / halfWidth * self.pageSpacing / 2,
                y: attributesItem.center.y
            )
            return attributesItem
        } else {
            return nil
        }
    }
    
}

extension PagingLayout {
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context: UICollectionViewLayoutInvalidationContext = super.invalidationContext(forBoundsChange: newBounds)
        if let flowContext = context as? UICollectionViewFlowLayoutInvalidationContext {
            flowContext.invalidateFlowLayoutDelegateMetrics = true
            flowContext.invalidateFlowLayoutAttributes = true
        }
        return context
    }
    
}
