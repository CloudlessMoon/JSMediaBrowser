//
//  MediaBrowserView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public class MediaBrowserView: UIView {
    
    public weak var dataSource: MediaBrowserViewDataSource? {
        didSet {
            self.collectionView.dataSource = self
        }
    }
    
    public weak var delegate: MediaBrowserViewDelegate? {
        didSet {
            self.collectionView.delegate = self
        }
    }
    
    public weak var gestureDelegate: MediaBrowserViewGestureDelegate?
    
    public var dimmingView: UIView? {
        didSet {
            guard oldValue != self.dimmingView else {
                return
            }
            if let oldValue = oldValue, oldValue.superview == self {
                oldValue.removeFromSuperview()
            }
            if let dimmingView = self.dimmingView {
                dimmingView.removeFromSuperview()
                self.insertSubview(dimmingView, at: 0)
            }
        }
    }
    
    public private(set) lazy var singleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTapGesture))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.delegate = self
        return gesture
    }()
    
    public private(set) lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTapGesture))
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        gesture.delegate = self
        return gesture
    }()
    
    public private(set) lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture))
        gesture.minimumPressDuration = 1
        gesture.delegate = self
        return gesture
    }()
    
    public private(set) lazy var dismissingGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDismissingGesture))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()
    
    public private(set) var currentPage: Int = 0
    
    public var totalUnitPage: Int {
        return self.dataSource?.numberOfPages(in: self) ?? 0
    }
    
    private lazy var collectionView: PagingCollectionView = {
        return PagingCollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewLayout)
    }()
    
    private lazy var collectionViewLayout: PagingLayout = {
        return PagingLayout()
    }()
    
    private var registeredCellIdentifiers = NSMutableSet()
    
    private var previousOffsetIndex: CGFloat = 0.0
    
    private var isScrollingToPage: Bool = false
    private var endScrollingCompletions: [() -> Void] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func didInitialize() {
        self.dimmingView = UIView()
        self.dimmingView?.backgroundColor = .black
        
        self.addSubview(self.collectionView)
        
        self.addGestureRecognizer(self.singleTapGesture)
        self.addGestureRecognizer(self.doubleTapGesture)
        self.addGestureRecognizer(self.longPressGesture)
        self.addGestureRecognizer(self.dismissingGesture)
        
        self.singleTapGesture.require(toFail: self.doubleTapGesture)
        
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: "轻点两下退出预览")
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.dimmingView?.frame = self.bounds
        
        if self.collectionView.bounds.size != self.bounds.size {
            self.collectionView.frame = self.bounds
            self.scrollToPage(at: self.currentPage, animated: false)
        }
    }
    
}

extension MediaBrowserView {
    
    public func setCurrentPage(_ index: Int, animated: Bool, completion: (() -> Void)? = nil) {
        guard self.currentPage != index else {
            completion?()
            return
        }
        let previousPage = self.currentPage
        self.currentPage = index
        
        self.isScrollingToPage = true
        self.delegate?.mediaBrowserView(self, willScrollHalfFrom: previousPage, to: index)
        self.scrollToPage(at: index, animated: animated) { [weak self] in
            guard let self = self else { return }
            self.isScrollingToPage = false
            
            self.delegate?.mediaBrowserView(self, didScrollTo: self.currentPage)
            
            completion?()
        }
    }
    
    public func reloadData() {
        self.collectionView.reloadData()
    }
    
    public func index(for pageCell: UICollectionViewCell) -> Int? {
        if let indexPath = self.collectionView.indexPath(for: pageCell) {
            return indexPath.item
        } else {
            return nil
        }
    }
    
    public func indexForItem(in point: CGPoint) -> Int? {
        return self.collectionView.indexPathForItem(at: point)?.item
    }
    
    public func pageCellForItem<Cell: UICollectionViewCell>(at index: Int) -> Cell? {
        let indexPath = IndexPath(item: index, section: 0)
        return self.collectionView.cellForItem(at: indexPath) as? Cell
    }
    
    public func pageCellForItem<Cell: UICollectionViewCell>(in point: CGPoint) -> Cell? {
        if let index = self.indexForItem(in: point) {
            return self.pageCellForItem(at: index)
        } else {
            return nil
        }
    }
    
    public var currentPageCell: UICollectionViewCell? {
        if let cell = self.pageCellForItem(at: self.currentPage) {
            return cell
        } else {
            return self.collectionView.visibleCells.first
        }
    }
    
    public var visiblePageCells: [UICollectionViewCell] {
        return self.collectionView.visibleCells
    }
    
    public var contentOffset: CGPoint {
        return self.collectionView.contentOffset
    }
    
    public var isTracking: Bool {
        return self.collectionView.isTracking
    }
    
    public var isDragging: Bool {
        return self.collectionView.isDragging
    }
    
    public var isDecelerating: Bool {
        return self.collectionView.isDecelerating
    }
    
    public var isScrollAnimating: Bool {
        return self.isScrollingToPage
    }
    
    public func dequeueReusableCell<Cell: UICollectionViewCell>(_ cellClass: Cell.Type,
                                                                reuseIdentifier: String? = nil,
                                                                at index: Int) -> Cell {
        let identifier: String = reuseIdentifier ?? "Item_\(cellClass)"
        if !self.registeredCellIdentifiers.contains(identifier) {
            self.registeredCellIdentifiers.add(identifier)
            self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
        }
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError()
        }
        return cell
    }
    
    public func dequeueReusableCell<Cell: UICollectionViewCell>(_ nibName: String,
                                                                bundle: Bundle? = Bundle.main,
                                                                reuseIdentifier: String? = nil,
                                                                at index: Int) -> Cell {
        let identifier: String = reuseIdentifier ?? "Item_Nib_\(nibName)"
        if !self.registeredCellIdentifiers.contains(identifier) {
            self.registeredCellIdentifiers.add(identifier)
            let nib = UINib(nibName: nibName, bundle: bundle)
            self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError()
        }
        return cell
    }
    
    public func dequeueReusableCell<Cell: UICollectionViewCell>(_ storyboardReuseIdentifier: String, at index: Int) -> Cell {
        let identifier: String = storyboardReuseIdentifier
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError()
        }
        return cell
    }
    
}

extension MediaBrowserView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfPages(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.dataSource?.mediaBrowserView(self, cellForPageAt: indexPath.item) ?? self.dequeueReusableCell(UICollectionViewCell.self, at: indexPath.item)
    }
    
}

extension MediaBrowserView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.delegate?.mediaBrowserView(self, willDisplay: cell, forPageAt: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.delegate?.mediaBrowserView(self, didEndDisplaying: cell, forPageAt: indexPath.item)
    }
    
}

extension MediaBrowserView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// 横竖屏旋转会触发scrollViewDidScroll, 会导致self.currentPage被改变, 所以这里加个isPossiblyRotating控制下。
        guard !self.collectionView.bounds.isEmpty && !self.isPossiblyRotating else {
            return
        }
        defer {
            self.delegate?.mediaBrowserViewDidScroll(self)
        }
        
        let betweenOrEqual = { (minimumValue: CGFloat, value: CGFloat, maximumValue: CGFloat) -> Bool in
            return minimumValue <= value && value <= maximumValue
        }
        let offsetIndex = self.offsetIndex
        let fastToRight = (floor(offsetIndex) - floor(self.previousOffsetIndex) >= 1.0) && (floor(offsetIndex) - self.previousOffsetIndex > 0.5)
        let turnPageToRight = fastToRight || betweenOrEqual(self.previousOffsetIndex, floor(offsetIndex) + 0.5, offsetIndex)
        let fastToLeft = (floor(self.previousOffsetIndex) - floor(offsetIndex) >= 1.0) && (self.previousOffsetIndex - ceil(offsetIndex) > 0.5)
        let turnPageToLeft = fastToLeft || betweenOrEqual(offsetIndex, floor(offsetIndex) + 0.5, self.previousOffsetIndex)
        
        if turnPageToRight || turnPageToLeft {
            let index = Int(round(offsetIndex))
            if index >= 0 && index < self.totalUnitPage && self.currentPage != index {
                self.delegate?.mediaBrowserView(self, willScrollHalfFrom: self.currentPage, to: index)
                
                self.currentPage = index
            }
            self.previousOffsetIndex = offsetIndex
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        self.delegate?.mediaBrowserView(self, didScrollTo: self.currentPage)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.mediaBrowserView(self, didScrollTo: self.currentPage)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.endScrollingCompletions.removeAll {
            $0()
            return true
        }
    }
    
    private var offsetIndex: CGFloat {
        let maximumPage = CGFloat(self.totalUnitPage - 1)
        let pageWidth = self.collectionView.bounds.width
        guard pageWidth > 0 && maximumPage >= 0 else {
            return 0
        }
        
        let contentOffsetX = self.collectionView.contentOffset.x
        let offsetIndex = contentOffsetX / pageWidth
        guard offsetIndex >= 0 else {
            return 0
        }
        
        guard offsetIndex <= maximumPage else {
            return maximumPage
        }
        return offsetIndex
    }
    
    private var isPossiblyRotating: Bool {
        guard let animationKeys = self.collectionView.layer.animationKeys() else {
            return false
        }
        let rotationAnimationKeys = ["position", "bounds.origin", "bounds.size"]
        return animationKeys.contains(where: { rotationAnimationKeys.contains($0) })
    }
    
    private func scrollToPage(at index: Int, animated: Bool, completion: (() -> Void)? = nil) {
        guard !self.collectionView.bounds.isEmpty else {
            completion?()
            return
        }
        guard index >= 0 && index < self.totalUnitPage else {
            completion?()
            return
        }
        /// iOS 14, 当isPagingEnabled为true, scrollToItem有bug
        /// https://stackoverflow.com/questions/41884645/uicollectionview-scroll-to-item-not-working-with-horizontal-direction
        let contentOffset = CGPoint(x: self.collectionView.bounds.width * CGFloat(index),
                                    y: self.collectionView.contentOffset.y)
        self.collectionView.setContentOffset(contentOffset, animated: animated)
        
        if animated {
            if let completion = completion {
                self.endScrollingCompletions.append(completion)
            }
        } else {
            completion?()
        }
    }
    
}

extension MediaBrowserView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.gestureDelegate?.mediaBrowserView(self, shouldBegin: gestureRecognizer) ?? super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.gestureDelegate?.mediaBrowserView(self, gestureRecognizer: gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer) ?? false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return self.gestureDelegate?.mediaBrowserView(self, gestureRecognizer: gestureRecognizer, shouldReceive: touch) ?? true
    }
    
    @objc private func handleSingleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        self.gestureDelegate?.mediaBrowserView(self, singleTouch: gestureRecognizer)
    }
    
    @objc private func handleDoubleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        self.gestureDelegate?.mediaBrowserView(self, doubleTouch: gestureRecognizer)
    }
    
    @objc private func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.gestureDelegate?.mediaBrowserView(self, longPressTouch: gestureRecognizer)
        }
    }
    
    @objc private func handleDismissingGesture(gestureRecognizer: UIPanGestureRecognizer) {
        self.gestureDelegate?.mediaBrowserView(self, dismissingChanged: gestureRecognizer)
    }
    
}
