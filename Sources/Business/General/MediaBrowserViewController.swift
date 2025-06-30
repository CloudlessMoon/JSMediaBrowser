//
//  MediaBrowserViewController.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/11.
//

import UIKit
import JSCoreKit

open class MediaBrowserViewController: UIViewController {
    
    public var sourceProvider: MediaBrowserViewControllerSourceProvider?
    
    public var eventHandler: MediaBrowserViewControllerEventHandler?
    
    public var dataSource: [any PhotoItem] = [] {
        didSet {
            defer {
                self.eventHandler?.didChangedData(current: self.dataSource, previous: oldValue)
            }
            
            guard self.isViewLoaded else {
                return
            }
            self.reloadData()
        }
    }
    
    public var dimmingView: UIView? {
        get {
            return self.contentView.dimmingView
        }
        set {
            self.contentView.dimmingView = newValue
        }
    }
    
    public var pageSpacing: CGFloat {
        didSet {
            self.contentView.pageSpacing = self.pageSpacing
        }
    }
    
    public var appearStyle: TransitioningStyle {
        didSet {
            self.transitionAdapter.animator.appearStyle = self.appearStyle
        }
    }
    
    public var disappearStyle: TransitioningStyle {
        didSet {
            self.transitionAdapter.animator.disappearStyle = self.disappearStyle
        }
    }
    
    public var hideWhenSingleTap: Bool
    
    public var hideWhenSliding: Bool
    
    public var hideWhenSlidingDistance: CGFloat
    
    public var zoomWhenDoubleTap: Bool
    
    public let configuration: MediaBrowserViewControllerConfiguration
    
    internal private(set) lazy var contentView: MediaBrowserView = {
        let view = MediaBrowserView()
        view.dataSource = self
        view.delegate = self
        view.pageSpacing = self.pageSpacing
        return view
    }()
    
    private lazy var dismissRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDismiss))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()
    
    private var gestureBeganLocation = CGPoint.zero
    
    private lazy var transitionAdapter: TransitionAdapter = {
        let adapter = TransitionAdapter(owner: self)
        adapter.animator.appearStyle = self.appearStyle
        adapter.animator.disappearStyle = self.disappearStyle
        return adapter
    }()
    
    private weak var presentedFromViewController: UIViewController?
    private var isPresented: Bool = false
    
    private var isViewAppeared: Bool = false {
        didSet {
            guard oldValue != self.isViewAppeared else {
                return
            }
            self.notifyDisplayedCurrentCell()
        }
    }
    
    private var photoAtomicInt = PhotoCell.AtomicInt()
    
    public init(configuration: MediaBrowserViewControllerConfiguration = .init()) {
        self.configuration = configuration
        self.appearStyle = configuration.appearStyle
        self.disappearStyle = configuration.disappearStyle
        self.hideWhenSingleTap = configuration.hideWhenSingleTap
        self.hideWhenSliding = configuration.hideWhenSliding
        self.hideWhenSliding = configuration.hideWhenSliding
        self.hideWhenSlidingDistance = configuration.hideWhenSlidingDistance
        self.zoomWhenDoubleTap = configuration.zoomWhenDoubleTap
        self.pageSpacing = configuration.pageSpacing
        
        super.init(nibName: nil, bundle: nil)
        
        self.didInitialize()
    }
    
    @available(*, unavailable, message: "use init()")
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    open func didInitialize() {
        self.extendedLayoutIncludesOpaqueBars = true
        self.accessibilityViewIsModal = true
    }
    
    deinit {
        print("\(Self.self) 释放")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = nil
        self.view.addSubview(self.contentView)
        
        self.view.addGestureRecognizer(self.dismissingRecognizer)
        
        /// 当contentView未布局且dataSource为空时，调用collectionView.cellForItem(at:)会导致代理不回调，应该是UIKit的bug
        /// 这里加上reloadData可以解决，保证标记一次刷新
        self.reloadData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isPresented {
            /// 外部可能设置导航栏, 这里需要隐藏
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isViewAppeared = true
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.contentView.js_frameApplyTransform = self.view.bounds
        
        if let cell = self.currentPageCell as? PhotoCell {
            self.configViewport(for: cell)
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    open override var shouldAutorotate: Bool {
        guard let orientationViewController = self.orientationViewController else {
            return true
        }
        return orientationViewController.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let orientationViewController = self.orientationViewController else {
            return .allButUpsideDown
        }
        return orientationViewController.supportedInterfaceOrientations
    }
    
}

extension MediaBrowserViewController {
    
    public var currentPage: Int {
        return self.contentView.currentPage
    }
    
    public var totalUnitPage: Int {
        return self.contentView.totalUnitPage
    }
    
    public var currentPageCell: UICollectionViewCell? {
        return self.contentView.currentPageCell
    }
    
    public func cellForPage<Cell: UICollectionViewCell>(at index: Int) -> Cell? {
        return self.contentView.cellForPage(at: index)
    }
    
    public func setCurrentPage(_ index: Int, animated: Bool, completion: (() -> Void)? = nil) {
        self.contentView.setCurrentPage(index, animated: animated) { [weak self] in
            guard let self = self else { return }
            self.notifyDisplayedCurrentCell()
            
            completion?()
        }
    }
    
    public var isTracking: Bool {
        return self.contentView.isTracking
    }
    
    public var isDragging: Bool {
        return self.contentView.isDragging
    }
    
    public var isDecelerating: Bool {
        return self.contentView.isDecelerating
    }
    
    public var isScrollAnimating: Bool {
        return self.contentView.isScrollAnimating
    }
    
    public var singleTapRecognizer: UITapGestureRecognizer {
        return self.contentView.singleTapRecognizer
    }
    
    public var doubleTapRecognizer: UITapGestureRecognizer {
        return self.contentView.doubleTapRecognizer
    }
    
    public var longPressRecognizer: UILongPressGestureRecognizer {
        return self.contentView.longPressRecognizer
    }
    
    public var dismissingRecognizer: UIPanGestureRecognizer {
        return self.dismissRecognizer
    }
    
    public func reloadData() {
        self.contentView.reloadData()
    }
    
    public func show(
        from sender: UIViewController,
        navigationController: UINavigationController? = nil,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        self.isPresented = true
        self.presentedFromViewController = sender
        
        var presenter = sender
        guard presenter.isViewLoaded else {
            assertionFailure()
            return
        }
        if !(presenter is UITabBarController), let tabBarController = presenter.tabBarController, tabBarController.isViewLoaded {
            if !tabBarController.tabBar.isHidden && tabBarController.tabBar.bounds.height > 0 && !presenter.hidesBottomBarWhenPushed {
                presenter = tabBarController
            }
        }
        if let presentedViewController = presenter.presentedViewController {
            presenter = presentedViewController
        }
        
        let viewController = navigationController ?? self
        viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = {
            if JSCoreHelper.isIPhone || JSCoreHelper.isIPod {
                return .custom
            } else {
                return .overCurrentContext
            }
        }()
        viewController.transitioningDelegate = self.transitionAdapter
        
        presenter.present(viewController, animated: animated, completion: completion)
    }
    
    public func hide(animated: Bool, completion: (() -> Void)? = nil) {
        guard self.isPresented else {
            return
        }
        self.dismiss(animated: animated, completion: completion)
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    public func numberOfPages(in mediaBrowserView: MediaBrowserView) -> Int {
        return self.dataSource.count
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, cellForPageAt index: Int) -> UICollectionViewCell {
        let dataItem = self.dataSource[index]
        let cell = mediaBrowserView.dequeueReusableCell(PhotoCell.self, reuseIdentifier: "Photo_\(dataItem.targetType)", at: index)
        self.configPhotoCell(cell, at: index)
        return cell
    }
    
    private func configPhotoCell(_ cell: PhotoCell, at index: Int) {
        guard index < self.dataSource.count else {
            return
        }
        let dataItem = self.dataSource[index]
        
        /// create
        cell.createPhotoView(dataItem.builder.createPhotoView())
        
        let updateAsset = { (cell: PhotoCell, asset: (any ZoomAsset)?, index: Int) in
            cell.photoView.asset = asset
        }
        let updateThumbnail = { (cell: PhotoCell, thumbnail: UIImage?) in
            cell.photoView.thumbnail = thumbnail
        }
        let updateProgress = { (cell: PhotoCell, receivedSize: Int, expectedSize: Int) in
            cell.photoView.setProgress(received: receivedSize, expected: expectedSize)
        }
        let updateError = { (cell: PhotoCell, error: PhotoMediatorError?) in
            cell.photoView.setError(error)
        }
        
        updateAsset(cell, nil, index)
        updateThumbnail(cell, dataItem.thumbnail)
        updateProgress(cell, 0, 0)
        updateError(cell, nil)
        
        if let token = cell.mb_requestToken, !token.isCancelled {
            token.cancel()
        }
        let identifier = self.photoAtomicInt.increment()
        cell.mb_requestIdentifier = identifier
        cell.mb_requestToken = dataItem.request(
            source: dataItem.source,
            progress: { [weak cell] receivedSize, expectedSize in
                JSCurrentOrAsyncExecuteOnMainThread {
                    guard let cell = cell, identifier == cell.mb_requestIdentifier else {
                        return
                    }
                    updateProgress(cell, receivedSize, expectedSize)
                }
            },
            completed: { [weak cell, weak self] result in
                JSCurrentOrAsyncExecuteOnMainThread {
                    guard let self = self else { return }
                    guard let cell = cell, identifier == cell.mb_requestIdentifier else {
                        return
                    }
                    switch result {
                    case .success(let asset):
                        updateAsset(cell, asset, index)
                        if asset != nil {
                            /// 资源下载完成后调用一次
                            self.didDisplayedCell(cell, at: index)
                        }
                    case .failure(let error):
                        updateError(cell, error)
                    }
                }
            }
        )
        
        self.configViewport(for: cell)
    }
    
    private func configViewport(for cell: PhotoCell) {
        let insets = {
            let insets = self.view.safeAreaInsets
            if JSCoreHelper.isMac {
                return insets
            } else {
                return UIEdgeInsets(top: 0, left: insets.left, bottom: 0, right: insets.right)
            }
        }()
        let size = {
            return CGSize(width: 580, height: .max)
        }()
        cell.photoView.setViewport(insets: insets, maximumSize: size)
    }
    
    private func notifyDisplayedCurrentCell() {
        guard let cell = self.currentPageCell as? PhotoCell else {
           return
        }
        self.didDisplayedCell(cell, at: self.currentPage)
    }
    
    private func didDisplayedCell(_ cell: PhotoCell, at index: Int) {
        guard self.isViewAppeared && !self.isDragging && !self.isDecelerating && !self.isScrollAnimating else {
            return
        }
        guard !self.view.isHidden && self.view.window != nil else {
            return
        }
        guard !cell.isHidden && cell.window != nil else {
            return
        }
        cell.photoView.assetView.didDisplayed()
        
        self.startPlaying(for: cell, at: index)
    }
    
    private func didEndDisplayedCell(_ cell: PhotoCell, at index: Int) {
        cell.photoView.assetView.didEndDisplayed()
        
        self.stopPlaying(for: cell, at: index)
    }
    
    private func startPlaying(for cell: PhotoCell, at index: Int) {
        if let eventHandler = self.eventHandler {
            if eventHandler.shouldStartPlaying(at: index) {
                cell.photoView.startPlaying()
            }
        } else {
            cell.photoView.startPlaying()
        }
    }
    
    private func stopPlaying(for cell: PhotoCell, at index: Int) {
        cell.photoView.stopPlaying()
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDelegate {
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forPageAt index: Int) {
        if let cell = cell as? PhotoCell {
            self.didDisplayedCell(cell, at: index)
            
            self.eventHandler?.willDisplayPhotoCell(cell, at: index)
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forPageAt index: Int) {
        if let cell = cell as? PhotoCell {
            self.didEndDisplayedCell(cell, at: index)
            
            self.eventHandler?.didEndDisplayingPhotoCell(cell, at: index)
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willScrollHalfFrom sourceIndex: Int, to targetIndex: Int) {
        self.eventHandler?.willScrollHalf(from: sourceIndex, to: targetIndex)
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didScrollTo index: Int) {
        self.eventHandler?.didScroll(to: index)
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didSingleTapAt index: Int, point: CGPoint) {
        defer {
            self.eventHandler?.didSingleTap(at: index, point: self.view.convert(point, from: mediaBrowserView))
        }
        
        guard self.hideWhenSingleTap else {
            return
        }
        self.hide(animated: true)
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didDoubleTapAt index: Int, point: CGPoint) {
        defer {
            self.eventHandler?.didDoubleTap(at: index, point: self.view.convert(point, from: mediaBrowserView))
        }
        
        guard self.zoomWhenDoubleTap else {
            return
        }
        guard let cell = self.currentPageCell as? PhotoCell else {
            return
        }
        cell.photoView.doubleTap(at: point, from: mediaBrowserView)
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didLongPressAt index: Int, point: CGPoint) {
        self.eventHandler?.didLongPress(at: index, point: self.view.convert(point, from: mediaBrowserView))
    }
    
    public func mediaBrowserViewDidScroll(_ mediaBrowserView: MediaBrowserView) {
        
    }
    
    public func mediaBrowserViewWillBeginDragging(_ mediaBrowserView: MediaBrowserView) {
        
    }
    
    public func mediaBrowserViewDidEndDragging(_ mediaBrowserView: MediaBrowserView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        self.notifyDisplayedCurrentCell()
    }
    
    public func mediaBrowserViewDidEndDecelerating(_ mediaBrowserView: MediaBrowserView) {
        self.notifyDisplayedCurrentCell()
    }
    
}

extension MediaBrowserViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.dismissingRecognizer {
            guard self.isPresented && self.hideWhenSliding else {
                return false
            }
            guard let cell = self.currentPageCell as? PhotoCell else {
                return true
            }
            let velocity = self.dismissingRecognizer.velocity(in: self.dismissingRecognizer.view)
            return !cell.photoView.isScrolling(with: velocity)
        } else {
            return true
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.dismissingRecognizer {
            guard let scrollView = otherGestureRecognizer.view as? UIScrollView else {
                return false
            }
            guard otherGestureRecognizer == scrollView.panGestureRecognizer || otherGestureRecognizer == scrollView.pinchGestureRecognizer else {
                return false
            }
            return true
        }
        return false
    }
    
    @objc private func handleDismiss(_ gestureRecognizer: UIPanGestureRecognizer) {
        let gestureRecognizerView = gestureRecognizer.view ?? self.contentView
        
        switch gestureRecognizer.state {
        case .possible:
            break
        case .began:
            self.gestureBeganLocation = gestureRecognizer.location(in: gestureRecognizerView)
            self.transitionAdapter.interactiver.begin()
            self.hide(animated: true)
        case .changed:
            let location = gestureRecognizer.location(in: gestureRecognizerView)
            let height = NSNumber(value: Double(gestureRecognizerView.bounds.height / 2))
            let horizontalDistance = location.x - self.gestureBeganLocation.x
            let verticalDistance = location.y - self.gestureBeganLocation.y
            let ratio = JSCoreHelper.interpolateValue(
                abs(verticalDistance),
                inputRange: [0, height],
                outputRange: [1.0, 0.4],
                extrapolateLeft: .clamp,
                extrapolateRight: .clamp
            )
            let alpha = JSCoreHelper.interpolateValue(
                abs(verticalDistance),
                inputRange: [0, height],
                outputRange: [1.0, 0.2],
                extrapolateLeft: .clamp,
                extrapolateRight: .clamp
            )
            let transform = CGAffineTransform(translationX: horizontalDistance, y: verticalDistance).scaledBy(x: ratio, y: ratio)
            self.currentPageCell?.transform = transform
            self.transitionAdapter.transitionAnimatorViews.forEach {
                $0.alpha = alpha
            }
        case .ended, .cancelled, .failed:
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            let verticalDistance = location.y - self.gestureBeganLocation.y
            if abs(verticalDistance) > self.hideWhenSlidingDistance {
                self.beginDismissingAnimation()
            } else {
                self.resetDismissingAnimation()
            }
        @unknown default:
            break
        }
    }
    
    private func beginDismissingAnimation() {
        if let context = self.transitionAdapter.interactiver.context {
            self.transitionAdapter.animator.performAnimation(using: context) { finished in
                self.transitionAdapter.interactiver.finish()
            }
        } else {
            self.resetDismissingAnimation()
        }
    }
    
    private func resetDismissingAnimation() {
        self.gestureBeganLocation = CGPoint.zero
        
        UIView.animate(withDuration: self.transitionAdapter.animator.duration, delay: 0, options: .curveEaseInOut) {
            self.currentPageCell?.transform = CGAffineTransform.identity
            self.transitionAdapter.transitionAnimatorViews.forEach {
                $0.alpha = 1.0
            }
        } completion: { finished in
            self.transitionAdapter.interactiver.cancel()
        }
    }
    
}

extension MediaBrowserViewController {
    
    private var orientationViewController: UIViewController? {
        if let presentedFromViewController = self.presentedFromViewController {
            return presentedFromViewController
        } else if let viewControllers = self.navigationController?.viewControllers, let index = viewControllers.firstIndex(of: self) {
            return index > 0 ? viewControllers[index - 1] : nil
        } else {
            return nil
        }
    }
    
}
