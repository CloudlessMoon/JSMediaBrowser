//
//  MediaBrowserViewController.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/11.
//

import UIKit
import JSCoreKit

open class MediaBrowserViewController: UIViewController {
    
    public var configuration: MediaBrowserViewControllerConfiguration
    
    public var sourceProvider: MediaBrowserViewControllerSourceProvider?
    
    public var eventHandler: MediaBrowserViewControllerEventHandler?
    
    public var dataSource: [any AssetItem] = [] {
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
    
    public var enteringStyle: TransitioningStyle {
        didSet {
            self.transitionAnimator.enteringStyle = self.enteringStyle
        }
    }
    
    public var exitingStyle: TransitioningStyle {
        didSet {
            self.transitionAnimator.exitingStyle = self.exitingStyle
        }
    }
    
    public var hideWhenSingleTap: Bool
    
    public var hideWhenSliding: Bool
    
    public var hideWhenSlidingDistance: CGFloat
    
    public var zoomWhenDoubleTap: Bool
    
    private lazy var contentView: MediaBrowserView = {
        let view = MediaBrowserView()
        view.dataSource = self
        view.delegate = self
        view.pageSpacing = self.pageSpacing
        return view
    }()
    
    private lazy var transitionAnimator: TransitionAnimator = {
        let animator = TransitionAnimator()
        animator.delegate = self
        animator.enteringStyle = self.enteringStyle
        animator.exitingStyle = self.exitingStyle
        return animator
    }()
    
    private lazy var transitionInteractiver: TransitionInteractiver = {
        let interactiver = TransitionInteractiver()
        return interactiver
    }()
    
    private lazy var dismissRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDismiss))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()
    
    private var gestureBeganLocation = CGPoint.zero
    
    private weak var presentedFromViewController: UIViewController?
    private var isPresented: Bool = false
    
    private var isTransitionFinished: Bool = false {
        didSet {
            guard oldValue != self.isTransitionFinished else {
                return
            }
            guard let photoCell = self.currentPageCell as? PhotoCell else {
                return
            }
            self.startPlaying(for: photoCell, at: self.currentPage)
        }
    }
    
    private var atomicInt = UIView.AtomicInt()
    
    public init(configuration: MediaBrowserViewControllerConfiguration) {
        self.configuration = configuration
        self.enteringStyle = configuration.enteringStyle
        self.exitingStyle = configuration.exitingStyle
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
        if !self.isTransitionFinished {
            self.isTransitionFinished = true
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.contentView.js_frameApplyTransform = self.view.bounds
        
        if let cell = self.currentPageCell as? PhotoCell {
            self.configViewportInsets(for: cell)
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
        self.contentView.setCurrentPage(index, animated: animated, completion: completion)
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
    
    public func show(
        from sender: UIViewController,
        navigationController: UINavigationController? = nil,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        self.isPresented = true
        self.presentedFromViewController = sender
        
        let viewController = navigationController ?? self
        viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = {
            if JSCoreHelper.isIPhone {
                return .custom
            } else {
                return .overCurrentContext
            }
        }()
        viewController.transitioningDelegate = self
        
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
        presenter.present(viewController, animated: animated, completion: completion)
    }
    
    public func hide(animated: Bool, completion: (() -> Void)? = nil) {
        guard self.isPresented else {
            return
        }
        self.dismiss(animated: animated, completion: completion)
    }
    
    public func reloadData() {
        self.contentView.reloadData()
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    public func numberOfPages(in mediaBrowserView: MediaBrowserView) -> Int {
        return self.dataSource.count
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, cellForPageAt index: Int) -> UICollectionViewCell {
        var cell: BasisCell?
        let dataItem = self.dataSource[index]
        if dataItem is any ImageAssetItem {
            cell = mediaBrowserView.dequeueReusableCell(PhotoCell.self, reuseIdentifier: "Image", at: index)
        } else if dataItem is any LivePhotoAssetItem {
            cell = mediaBrowserView.dequeueReusableCell(PhotoCell.self, reuseIdentifier: "LivePhoto", at: index)
        }
        guard let cell = cell else {
            return mediaBrowserView.dequeueReusableCell(UICollectionViewCell.self, at: index)
        }
        self.configCell(cell, at: index)
        return cell
    }
    
    private func configCell(_ cell: BasisCell, at index: Int) {
        cell.onPressEmpty = { [weak self] in
            guard let self = self else { return }
            self.reloadData()
        }
        cell.willDisplayEmptyView = { [weak self] (emptyView: EmptyView, error: NSError) in
            guard let self = self else { return }
            self.eventHandler?.willDisplayEmptyView(emptyView, with: error, at: index)
        }
        
        if let photoCell = cell as? PhotoCell {
            self.configPhotoCell(photoCell, at: index)
        }
    }
    
    private func configPhotoCell(_ cell: PhotoCell, at index: Int) {
        guard index < self.dataSource.count else {
            return
        }
        /// 初始化zoomView
        if cell.zoomView == nil {
            cell.zoomView = self.configuration.zoomView(index)
        }
        
        let updateAsset = { [weak self] (cell: PhotoCell, asset: (any ZoomAsset)?, thumbnail: UIImage?) in
            guard let self = self else { return }
            guard let zoomView = cell.zoomView else {
                return
            }
            zoomView.asset = asset
            zoomView.thumbnail = thumbnail
            /// 解决资源下载完成后不播放的问题
            self.startPlaying(for: cell, at: index)
        }
        let updateError = { (cell: PhotoCell, error: NSError?, isCancelled: Bool) in
            if isCancelled && (cell.zoomView?.asset != nil || cell.zoomView?.thumbnail != nil) {
                cell.setError(nil)
            } else {
                cell.setError(error)
            }
        }
        let updateProgress = { (cell: PhotoCell, receivedSize: Int, expectedSize: Int) in
            let progress = Progress(totalUnitCount: Int64(expectedSize))
            progress.completedUnitCount = Int64(receivedSize)
            cell.setProgress(progress)
        }
        let dataItem = self.dataSource[index]
        
        /// 重置下数据
        updateAsset(cell, nil, dataItem.thumbnail)
        updateProgress(cell, 0, 0)
        updateError(cell, nil, false)
        
        /// 取消请求
        if let token = cell.mb_requestToken, !token.isCancelled {
            token.cancel()
        }
        let identifier = self.atomicInt.increment()
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
            completed: { [weak cell] result in
                JSCurrentOrAsyncExecuteOnMainThread {
                    guard let cell = cell, identifier == cell.mb_requestIdentifier else {
                        return
                    }
                    switch result {
                    case .success(let value):
                        updateAsset(cell, value.asset, nil)
                    case .failure(let error):
                        if !error.isCancelled {
                            updateAsset(cell, nil, nil)
                        }
                        updateError(cell, error.error, error.isCancelled)
                    }
                }
            }
        )
        
        self.configViewportInsets(for: cell)
    }
    
    private func configViewportInsets(for cell: PhotoCell) {
        guard let zoomView = cell.zoomView else {
            return
        }
        zoomView.viewportInsets = {
            let insets = self.view.safeAreaInsets
            if JSCoreHelper.isMac {
                return insets
            } else {
                return UIEdgeInsets(top: 0, left: insets.left, bottom: 0, right: insets.right)
            }
        }()
    }
    
    private func startPlaying(for cell: PhotoCell, at index: Int) {
        guard self.isTransitionFinished else {
            return
        }
        guard !self.isDragging && !self.isDecelerating && !self.isScrollAnimating else {
            return
        }
        guard !cell.isHidden && cell.window != nil, let zoomView = cell.zoomView else {
            return
        }
        if let eventHandler = self.eventHandler {
            if eventHandler.shouldStartPlaying(at: index) {
                zoomView.startPlaying()
            }
        } else {
            zoomView.startPlaying()
        }
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDelegate {
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forPageAt index: Int) {
        if let photoCell = cell as? PhotoCell, let zoomView = photoCell.zoomView {
            self.startPlaying(for: photoCell, at: index)
            
            self.eventHandler?.willDisplayPhotoCell(photoCell, zoomView: zoomView, at: index)
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forPageAt index: Int) {
        if let photoCell = cell as? PhotoCell, let zoomView = photoCell.zoomView {
            zoomView.stopPlaying()
            
            self.eventHandler?.didEndDisplayingPhotoCell(photoCell, zoomView: zoomView, at: index)
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willScrollHalfFrom sourceIndex: Int, to targetIndex: Int) {
        self.eventHandler?.willScrollHalf(from: sourceIndex, to: targetIndex)
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didScrollTo index: Int) {
        if let photoCell = self.currentPageCell as? PhotoCell {
            self.startPlaying(for: photoCell, at: index)
        }
        
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
        guard let photoCell = self.currentPageCell as? PhotoCell, let zoomView = photoCell.zoomView else {
            return
        }
        let minimumZoomScale = zoomView.minimumZoomScale
        if zoomView.zoomScale != minimumZoomScale {
            zoomView.setZoom(scale: minimumZoomScale, animated: true)
        } else {
            let point = zoomView.assetView?.convert(point, from: mediaBrowserView) ?? point
            zoomView.zoom(to: point, scale: zoomView.maximumZoomScale, animated: true)
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didLongPressAt index: Int, point: CGPoint) {
        self.eventHandler?.didLongPress(at: index, point: self.view.convert(point, from: mediaBrowserView))
    }
    
}

extension MediaBrowserViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.dismissingRecognizer {
            guard self.isPresented && self.hideWhenSliding else {
                return false
            }
            guard let photoCell = self.currentPageCell as? PhotoCell, let zoomView = photoCell.zoomView else {
                return true
            }
            let velocity = self.dismissingRecognizer.velocity(in: self.dismissingRecognizer.view)
            let minY = ceil(zoomView.scrollView.js_minimumContentOffset.y)
            let maxY = floor(zoomView.scrollView.js_maximumContentOffset.y)
            let scrollView = zoomView.scrollView
            /// 垂直触摸滑动
            if abs(velocity.x) <= abs(velocity.y) {
                if velocity.y > 0 {
                    /// 手势向下
                    return scrollView.contentOffset.y <= minY && !(scrollView.isDragging || scrollView.isDecelerating)
                } else {
                    /// 手势向上
                    return scrollView.contentOffset.y >= maxY && !(scrollView.isDragging || scrollView.isDecelerating)
                }
            } else {
                return false
            }
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
            self.transitionInteractiver.begin()
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
            self.transitionAnimatorViews?.forEach { (subview) in
                subview.alpha = alpha
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
        if let context = self.transitionInteractiver.context {
            self.transitionAnimator.performAnimation(using: context, isEntering: false) { finished in
                self.transitionInteractiver.finish()
            }
        } else {
            self.resetDismissingAnimation()
        }
    }
    
    private func resetDismissingAnimation() {
        self.gestureBeganLocation = CGPoint.zero
        
        UIView.animate(withDuration: self.transitionAnimator.duration, delay: 0, options: JSCoreHelper.animationOptionsCurveOut) {
            self.currentPageCell?.transform = CGAffineTransform.identity
            self.transitionAnimatorViews?.forEach {
                $0.alpha = 1.0
            }
        } completion: { finished in
            self.transitionInteractiver.cancel()
        }
    }
    
}

extension MediaBrowserViewController: UIViewControllerTransitioningDelegate, TransitionAnimatorDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionAnimator.type = .presenting
        return self.transitionAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionAnimator.type = .dismiss
        return self.transitionAnimator
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.transitionInteractiver.type = .presenting
        return self.transitionInteractiver.wantsInteractiveStart ? self.transitionInteractiver : nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.transitionInteractiver.type = .dismiss
        return self.transitionInteractiver.wantsInteractiveStart ? self.transitionInteractiver : nil
    }
    
    public var transitionThumbnailView: UIImageView? {
        if let photoCell = self.currentPageCell as? PhotoCell, let zoomView = photoCell.zoomView {
            return zoomView.configuration.thumbnailView()
        }
        return nil
    }
    
    public var transitionThumbnail: UIImage? {
        if let photoCell = self.currentPageCell as? PhotoCell, let zoomView = photoCell.zoomView {
            if let image = zoomView.thumbnail {
                return image
            } else if let thumbnail = self.dataSource[self.currentPage].thumbnail {
                return thumbnail
            } else if let image = zoomView.asset as? UIImage {
                return image
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public var transitionSourceView: UIView? {
        return self.sourceProvider?.sourceView?(self.currentPage)
    }
    
    public var transitionSourceRect: CGRect {
        return self.sourceProvider?.sourceRect?(self.currentPage) ?? .zero
    }
    
    public var transitionTargetView: UIView? {
        return self.currentPageCell
    }
    
    public var transitionTargetFrame: CGRect {
        if let photoCell = self.currentPageCell as? PhotoCell, let zoomView = photoCell.zoomView {
            return zoomView.contentViewFrame
        }
        return .zero
    }
    
    public var transitionAnimatorViews: [UIView]? {
        var animatorViews: [UIView] = []
        if let dimmingView = self.contentView.dimmingView {
            animatorViews.append(dimmingView)
        }
        self.view.subviews.forEach { (subview) in
            if subview != self.contentView {
                animatorViews.append(subview)
            }
        }
        return animatorViews
    }
    
    public func transitionViewWillMoveToSuperview(_ transitionView: UIView) {
        self.contentView.addSubview(transitionView)
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
