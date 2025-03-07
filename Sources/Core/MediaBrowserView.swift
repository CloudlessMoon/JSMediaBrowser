//
//  MediaBrowserView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

open class MediaBrowserView: UIView {
    
    public weak var dataSource: MediaBrowserViewDataSource?
    
    public weak var delegate: MediaBrowserViewDelegate?
    
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
    
    public private(set) lazy var singleTapRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.delegate = self
        return gesture
    }()
    
    public private(set) lazy var doubleTapRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap))
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        gesture.delegate = self
        return gesture
    }()
    
    public private(set) lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        gesture.minimumPressDuration = 0.5
        gesture.delegate = self
        return gesture
    }()
    
    public private(set) var currentPage: Int = 0
    
    public var totalUnitPage: Int {
        return self.dataSource?.numberOfPages(in: self) ?? 0
    }
    
    public var pageSpacing: CGFloat = 10 {
        didSet {
            guard oldValue != self.pageSpacing else {
                return
            }
            self.collectionViewLayout.pageSpacing = self.pageSpacing
            self.collectionViewLayout.invalidateLayout()
        }
    }
    
    private lazy var collectionView: PagingCollectionView = {
        let view = PagingCollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewLayout)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private lazy var collectionViewLayout: PagingLayout = {
        return PagingLayout(pageSpacing: self.pageSpacing)
    }()
    
    private var registeredCellIdentifiers = NSMutableSet()
    
    private var previousOffsetIndex: CGFloat = 0.0
    
    private var isScrollingToPage: Bool = false
    private var draggingPage: Int?
    private var endScrollingCompletions: [() -> Void] = []
    
    public init() {
        super.init(frame: .zero)
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    open func didInitialize() {
        self.dimmingView = UIView()
        self.dimmingView?.backgroundColor = .black
        
        self.addSubview(self.collectionView)
        
        self.addGestureRecognizer(self.singleTapRecognizer)
        self.addGestureRecognizer(self.doubleTapRecognizer)
        self.addGestureRecognizer(self.longPressRecognizer)
        
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: "轻点两下退出预览")
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.collectionView.bounds.size != self.bounds.size {
            self.collectionView.frame = self.bounds
            self.scrollToPage(at: self.currentPage, animated: false)
        }
        
        self.dimmingView?.frame = self.bounds
    }
    
}

extension MediaBrowserView {
    
    public var currentPageCell: UICollectionViewCell? {
        if let cell = self.cellForPage(at: self.currentPage) {
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
    
    public func setCurrentPage(_ index: Int, animated: Bool, completion: (() -> Void)? = nil) {
        guard self.currentPage != index else {
            return
        }
        let previousPage = self.currentPage
        self.currentPage = index
        
        self.callWillScrollHalf(from: previousPage, to: index)
        
        self.isScrollingToPage = true
        self.scrollToPage(at: index, animated: animated) { [weak self] in
            guard let self = self else { return }
            self.isScrollingToPage = false
            
            self.callDidScrollToIndex()
            
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
    
    public func indexForPage(in point: CGPoint) -> Int? {
        return self.collectionView.indexPathForItem(at: point)?.item
    }
    
    private func index(of gestureRecognizer: UIGestureRecognizer) -> Int? {
        let location = gestureRecognizer.location(in: self.collectionView)
        return self.indexForPage(in: location)
    }
    
    public func cellForPage<Cell: UICollectionViewCell>(at index: Int) -> Cell? {
        let indexPath = IndexPath(item: index, section: 0)
        return self.collectionView.cellForItem(at: indexPath) as? Cell
    }
    
    public func cellForPage<Cell: UICollectionViewCell>(in point: CGPoint) -> Cell? {
        if let index = self.indexForPage(in: point) {
            return self.cellForPage(at: index)
        } else {
            return nil
        }
    }
    
    public func dequeueReusableCell<Cell: UICollectionViewCell>(_ cellClass: Cell.Type,
                                                                reuseIdentifier: String? = nil,
                                                                at index: Int) -> Cell {
        let identifier = reuseIdentifier ?? "Page_\(cellClass)"
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
        let identifier = reuseIdentifier ?? "Page_Nib_\(nibName)"
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
    
}

extension MediaBrowserView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.singleTapRecognizer {
            return otherGestureRecognizer == self.doubleTapRecognizer && self.doubleTapRecognizer.isEnabled
        } else {
            return false
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == self.singleTapRecognizer || gestureRecognizer == self.doubleTapRecognizer {
            guard touch.view is UIControl else {
                return true
            }
            return false
        }
        return true
    }
    
    @objc private func handleSingleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.mediaBrowserView(
            _: self,
            didSingleTapAt: self.index(of: gestureRecognizer) ?? self.currentPage,
            point: gestureRecognizer.location(in: self)
        )
    }
    
    @objc private func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.mediaBrowserView(
            _: self,
            didDoubleTapAt: self.index(of: gestureRecognizer) ?? self.currentPage,
            point: gestureRecognizer.location(in: self)
        )
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            return
        }
        self.delegate?.mediaBrowserView(
            _: self,
            didLongPressAt: self.index(of: gestureRecognizer) ?? self.currentPage,
            point: gestureRecognizer.location(in: self)
        )
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
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
}

extension MediaBrowserView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard self.dataSource != nil else {
            return .zero
        }
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
        guard !self.collectionView.bounds.isEmpty else {
            return
        }
        let offsetIndex = self.offsetIndex
        defer {
            self.previousOffsetIndex = offsetIndex
        }
        guard self.isDragging || self.isDecelerating || self.isTracking else {
            return
        }
        let betweenOrEqual = { (minimumValue: CGFloat, value: CGFloat, maximumValue: CGFloat) -> Bool in
            return minimumValue <= value && value <= maximumValue
        }
        let fastToRight = (floor(offsetIndex) - floor(self.previousOffsetIndex) >= 1.0) && (floor(offsetIndex) - self.previousOffsetIndex > 0.5)
        let turnPageToRight = fastToRight || betweenOrEqual(self.previousOffsetIndex, floor(offsetIndex) + 0.5, offsetIndex)
        let fastToLeft = (floor(self.previousOffsetIndex) - floor(offsetIndex) >= 1.0) && (self.previousOffsetIndex - ceil(offsetIndex) > 0.5)
        let turnPageToLeft = fastToLeft || betweenOrEqual(offsetIndex, floor(offsetIndex) + 0.5, self.previousOffsetIndex)
        guard turnPageToRight || turnPageToLeft else {
            return
        }
        let index = Int(round(offsetIndex))
        guard index >= 0 && index < self.totalUnitPage && self.currentPage != index else {
            return
        }
        let previousPage = self.currentPage
        self.currentPage = index
        
        self.callWillScrollHalf(from: previousPage, to: index)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.handleBeginDragging()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        self.handleEndDecelerating()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.handleEndDecelerating()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.endScrollingCompletions.removeAll {
            $0()
            return true
        }
    }
    
    private var offsetIndex: CGFloat {
        let maximumIndex = CGFloat(self.totalUnitPage - 1)
        let pageWidth = self.collectionView.bounds.width
        guard pageWidth > 0 && maximumIndex >= 0 else {
            return 0
        }
        let contentOffsetX = self.collectionView.contentOffset.x
        let offsetIndex = contentOffsetX / pageWidth
        return max(min(offsetIndex, maximumIndex), 0)
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
    
    private func handleBeginDragging() {
        guard self.draggingPage == nil else {
            return
        }
        self.draggingPage = self.currentPage
    }
    
    private func handleEndDecelerating() {
        if self.draggingPage != self.currentPage {
            self.draggingPage = nil
            
            self.callDidScrollToIndex()
        } else {
            self.draggingPage = nil
        }
    }
    
    private func callWillScrollHalf(from sourceIndex: Int, to targetIndex: Int) {
        print("willScrollHalf from: \(sourceIndex) to: \(targetIndex)")
        
        self.delegate?.mediaBrowserView(self, willScrollHalfFrom: sourceIndex, to: targetIndex)
    }
    
    private func callDidScrollToIndex() {
        print("didScrollTo to: \(self.currentPage)")
        
        self.delegate?.mediaBrowserView(self, didScrollTo: self.currentPage)
    }
    
}
