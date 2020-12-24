//
//  PagingLayout.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

open class PagingLayout: UICollectionViewFlowLayout {
    
    @objc public var pageSpacing: CGFloat = 10
    private var finalItemSize: CGSize = CGSize.zero
    
    override init() {
        super.init()
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    func didInitialize() -> Void {
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.scrollDirection = .horizontal
        self.sectionInset = .zero
    }
    
}

extension PagingLayout {
    
    open override func prepare() {
        super.prepare()
        var itemSize: CGSize = self.itemSize
        guard let collectionView = self.collectionView else { return }
        if let layoutDelegate = collectionView.delegate,
           layoutDelegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
            let delegate = layoutDelegate as! UICollectionViewDelegateFlowLayout
            itemSize = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: IndexPath(item: 0, section: 0)) ?? CGSize.zero
        }
        self.finalItemSize = itemSize
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray: Array<UICollectionViewLayoutAttributes> = Array()
        let superAttributesArray: Array<UICollectionViewLayoutAttributes> = super.layoutAttributesForElements(in: rect) ?? []
        let halfWidth: CGFloat = self.finalItemSize.width / 2.0
        let centerX: CGFloat = (self.collectionView?.contentOffset.x ?? 0.0) + halfWidth
        for attribute in superAttributesArray {
            if let newAttribute = attribute.copy() as? UICollectionViewLayoutAttributes {
                newAttribute.center = CGPoint(x: newAttribute.center.x + (newAttribute.center.x - centerX) / halfWidth * self.pageSpacing / 2, y: newAttribute.center.y)
                newAttribute.size = self.finalItemSize
                attributesArray.append(newAttribute)
            }
        }
        return attributesArray
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}