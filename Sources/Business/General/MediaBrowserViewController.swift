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
    
    public var enteringStyle: TransitioningStyle = .zoom {
        didSet {
            self.transitionAnimator.enteringStyle = enteringStyle
        }
    }
    
    public var exitingStyle: TransitioningStyle = .zoom {
        didSet {
            self.transitionAnimator.exitingStyle = exitingStyle
        }
    }
    
    public var dataSource: [AssetItem] = [] {
        didSet {
            guard self.isViewLoaded else {
                return
            }
            
            self.eventHandler?.willReloadData(self.dataSource)
            
            self.mediaBrowserView.reloadData()
        }
    }
    
    public private(set) lazy var mediaBrowserView: MediaBrowserView = {
        return MediaBrowserView()
    }()
    
    public private(set) weak var presentedFromViewController: UIViewController?
    
    private lazy var transitionAnimator: TransitionAnimator = {
        let animator = TransitionAnimator()
        animator.delegate = self
        return animator
    }()
    
    private lazy var transitionInteractiver: TransitionInteractiver = {
        let interactiver = TransitionInteractiver()
        return interactiver
    }()
    
    private var gestureBeganLocation: CGPoint = CGPoint.zero
    
    private weak var cacheSourceView: UIView?
    
    private var dismissWhenSlidingDistance: CGFloat = 70
    
    public init(configuration: MediaBrowserViewControllerConfiguration) {
        self.configuration = configuration
        
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
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = nil
        self.view.addSubview(self.mediaBrowserView)
        
        self.mediaBrowserView.dataSource = self
        self.mediaBrowserView.delegate = self
        self.mediaBrowserView.gestureDelegate = self
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mediaBrowserView.js_frameApplyTransform = self.view.bounds
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 外部可能设置导航栏, 这里需要隐藏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.cacheSourceView = self.sourceProvider?.sourceView?(self.currentPage)
        self.cacheSourceView?.isHidden = true
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cacheSourceView?.isHidden = false
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.cacheSourceView?.isHidden = false
        coordinator.animateAlongsideTransition(in: self.view, animation: nil) { context in
            guard self.view.window != nil else {
                return
            }
            self.cacheSourceView = self.sourceProvider?.sourceView?(self.currentPage)
            self.cacheSourceView?.isHidden = true
        }
    }
    
}

extension MediaBrowserViewController {
    
    public var currentPage: Int {
        return self.mediaBrowserView.currentPage
    }
    
    public var totalUnitPage: Int {
        return self.mediaBrowserView.totalUnitPage
    }
    
    public var currentPageCell: UICollectionViewCell? {
        return self.mediaBrowserView.currentPageCell
    }
    
    public func setCurrentPage(_ index: Int, animated: Bool, completion: (() -> Void)? = nil) {
        self.mediaBrowserView.setCurrentPage(index, animated: animated, completion: completion)
    }
    
    public func show(from sender: UIViewController,
                     navigationController: UINavigationController? = nil,
                     animated: Bool,
                     completion: (() -> Void)? = nil) {
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
        if self.isPresented {
            self.dismiss(animated: animated, completion: completion)
        } else {
            self.navigationController?.popViewController(animated: animated)
            if let transitionCoordinator = self.transitionCoordinator {
                transitionCoordinator.animate(alongsideTransition: nil) { context in
                    completion?()
                }
            } else {
                completion?()
            }
        }
    }
    
    public var isPresented: Bool {
        return self.presentedFromViewController != nil
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    public func numberOfPages(in mediaBrowserView: MediaBrowserView) -> Int {
        return self.dataSource.count
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, cellForPageAt index: Int) -> UICollectionViewCell {
        var cell: BasisCell?
        let dataItem = self.dataSource[index]
        if dataItem is ImageAssetItem {
            cell = mediaBrowserView.dequeueReusableCell(PhotoCell.self, reuseIdentifier: "Image", at: index)
        } else if dataItem is LivePhotoAssetItem {
            cell = mediaBrowserView.dequeueReusableCell(PhotoCell.self, reuseIdentifier: "LivePhoto", at: index)
        } else if dataItem is VideoAssetItem {
            cell = mediaBrowserView.dequeueReusableCell(VideoCell.self, at: index)
        }
        guard let cell = cell else {
            return mediaBrowserView.dequeueReusableCell(UICollectionViewCell.self, at: index)
        }
        self.configureCell(cell, at: index)
        return cell
    }
    
    private func configureCell(_ cell: BasisCell, at index: Int) {
        cell.onPressEmpty = { [weak self] (cell: UICollectionViewCell) in
            guard let self = self else { return }
            self.mediaBrowserView.reloadData()
        }
        cell.willDisplayEmptyView = { [weak self] (cell: UICollectionViewCell, emptyView: EmptyView, error: NSError) in
            guard let self = self else {
                return
            }
            self.eventHandler?.willDisplayEmptyView(emptyView, with: error, at: index)
        }
        if let photoCell = cell as? PhotoCell {
            self.configurePhotoCell(photoCell, at: index)
        } else if let videoCell = cell as? VideoCell {
            self.configureVideoCell(videoCell, at: index)
        }
    }
    
    private func configurePhotoCell(_ cell: PhotoCell, at index: Int) {
        /// 初始化zoomView
        if cell.zoomView == nil {
            cell.zoomView = self.configuration.zoomView(index)
        }
        assert(cell.zoomView != nil)
        
        let updateProgress = { [weak cell] (receivedSize: Int64, expectedSize: Int64) in
            let progress = Progress(totalUnitCount: expectedSize)
            progress.completedUnitCount = receivedSize
            cell?.setProgress(progress)
        }
        let updateCell = { [weak cell] (error: NSError?, cancelled: Bool) in
            cell?.setError(error, cancelled: cancelled)
        }
        let updateAsset = { [weak cell, weak self] (asset: (any ZoomAsset)?) in
            guard let cell = cell, let self = self else {
                return
            }
            cell.zoomView?.asset = asset
            
            /// 解决资源下载完成后不播放的问题
            if let eventHandler = self.eventHandler {
                if eventHandler.shouldStartPlaying(at: index) {
                    cell.zoomView?.startPlaying()
                }
            } else {
                cell.zoomView?.startPlaying()
            }
        }
        let updateThumbnail = { [weak cell] (thumbnail: UIImage?) in
            guard let cell = cell else {
                return
            }
            cell.zoomView?.thumbnail = thumbnail
        }
        if let dataItem = self.dataSource[index] as? ImageAssetItem {
            let webImageMediator = self.configuration.webImageMediator(index)
            /// 取消请求
            webImageMediator.cancelRequest(for: cell)
            /// 如果存在image, 且imageURL为nil时, 则代表是本地图片, 无须网络请求
            if let image = dataItem.image, dataItem.imageURL == nil {
                updateAsset(image)
                updateCell(nil, false)
            } else if let url = dataItem.imageURL {
                /// 缩略图
                updateThumbnail(dataItem.thumbnail)
                /// 请求图片
                webImageMediator.requestImage(
                    for: cell,
                    url: url,
                    progress: {
                        updateProgress($0, $1)
                    },
                    completed: {
                        switch $0 {
                        case .success(let value):
                            updateAsset(value.image)
                            updateThumbnail(nil)
                            updateCell(nil, false)
                        case .failure(let error):
                            updateAsset(nil)
                            updateCell(error.error, error.isCancelled)
                        }
                    })
            } else {
                updateThumbnail(dataItem.thumbnail)
            }
        } else if let dataItem = self.dataSource[index] as? LivePhotoAssetItem {
            // 缩略图
            updateThumbnail(dataItem.thumbnail)
            
            let livePhotoMediator = self.configuration.livePhotoMediator(index)
            livePhotoMediator.cancelRequest(for: cell)
            livePhotoMediator.requestLivePhoto(
                for: cell,
                imageURL: dataItem.imageURL,
                videoURL: dataItem.videoURL,
                progress: {
                    updateProgress($0, $1)
                },
                completed: {
                    switch $0 {
                    case .success(let value):
                        updateAsset(value.livePhoto)
                        updateThumbnail(nil)
                        updateCell(nil, false)
                    case .failure(let error):
                        updateAsset(nil)
                        updateCell(error.error, error.isCancelled)
                    }
                })
        }
    }
    
    private func configureVideoCell(_ cell: VideoCell, at index: Int) {
        guard let dataItem = self.dataSource[index] as? VideoAssetItem else {
            return
        }
        cell.videoPlayerView.thumbnail = dataItem.thumbnail
        /// 前后url不相同时需要释放之前的player, 否则会先显示之前的画面, 再显示当前的
        if cell.videoPlayerView.url != dataItem.videoURL {
            cell.videoPlayerView.releasePlayer()
        }
        cell.setProgress(Progress())
        cell.videoPlayerView.isAutoPlay = !cell.isHidden
        cell.videoPlayerView.url = dataItem.videoURL
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDelegate {
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forPageAt index: Int) {
        if let photoCell = cell as? PhotoCell, let zoomView = photoCell.zoomView {
            if let eventHandler = self.eventHandler {
                if eventHandler.shouldStartPlaying(at: index) {
                    zoomView.startPlaying()
                }
            } else {
                zoomView.startPlaying()
            }
            
            self.eventHandler?.willDisplayZoomView(zoomView, at: index)
        } else if let videoCell = cell as? VideoCell {
            let startPlaying = {
                let status = videoCell.videoPlayerView.status
                if status == .ready || status == .paused {
                    videoCell.videoPlayerView.play()
                }
            }
            if let eventHandler = self.eventHandler {
                if eventHandler.shouldStartPlaying(at: index) {
                    startPlaying()
                }
            } else {
                startPlaying()
            }
            
            self.eventHandler?.willDisplayVideoPlayerView(videoCell.videoPlayerView, at: index)
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forPageAt index: Int) {
        if let photoCell = cell as? PhotoCell {
            photoCell.zoomView?.stopPlaying()
        } else if let videoCell = cell as? VideoCell {
            videoCell.videoPlayerView.reset()
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willScrollHalfFrom sourceIndex: Int, to targetIndex: Int) {
        self.cacheSourceView?.isHidden = false
        self.cacheSourceView = self.sourceProvider?.sourceView?(targetIndex)
        self.cacheSourceView?.isHidden = true
        
        self.eventHandler?.willScrollHalf(from: sourceIndex, to: targetIndex)
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didScrollTo index: Int) {
        self.eventHandler?.didScroll(to: index)
    }
    
    public func mediaBrowserViewDidScroll(_ mediaBrowserView: MediaBrowserView) {
        
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewGestureDelegate {
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, shouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool? {
        if gestureRecognizer == mediaBrowserView.dismissingGesture, let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            guard let photoCell = self.currentPageCell as? PhotoCell, let zoomView = photoCell.zoomView else {
                return true
            }
            let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
            let minY = zoomView.scrollView.js_minimumContentOffset.y
            let maxY = zoomView.scrollView.js_maximumContentOffset.y
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
            return nil
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool? {
        if gestureRecognizer == mediaBrowserView.dismissingGesture {
            guard let scrollView = otherGestureRecognizer.view as? UIScrollView else {
                return nil
            }
            guard otherGestureRecognizer == scrollView.panGestureRecognizer || otherGestureRecognizer == scrollView.pinchGestureRecognizer else {
                return nil
            }
            return true
        }
        return nil
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool? {
        if gestureRecognizer == mediaBrowserView.singleTapGesture || gestureRecognizer == mediaBrowserView.doubleTapGesture {
            guard touch.view is UIControl else {
                return nil
            }
            return false
        }
        return nil
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer) {
        defer {
            self.eventHandler?.didSingleTouch()
        }
        
        guard self.isPresented else {
            return
        }
        
        self.hide(animated: true)
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        guard let photoCell = self.currentPageCell as? PhotoCell, let zoomView = photoCell.zoomView else {
            return
        }
        let minimumZoomScale = zoomView.minimumZoomScale
        if zoomView.zoomScale != minimumZoomScale {
            zoomView.setZoom(scale: minimumZoomScale, animated: true)
        } else {
            let gesturePoint: CGPoint = gestureRecognizer.location(in: zoomView.contentView)
            zoomView.zoom(to: gesturePoint, animated: true)
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPressTouch gestureRecognizer: UILongPressGestureRecognizer) {
        self.eventHandler?.didLongPressTouch()
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissingChanged gestureRecognizer: UIPanGestureRecognizer) {
        let gestureRecognizerView: UIView = gestureRecognizer.view ?? mediaBrowserView
        switch gestureRecognizer.state {
        case .began:
            self.gestureBeganLocation = gestureRecognizer.location(in: gestureRecognizerView)
            self.transitionInteractiver.begin()
            if self.isPresented {
                self.hide(animated: true)
            }
        case .changed:
            let location = gestureRecognizer.location(in: gestureRecognizerView)
            let horizontalDistance = location.x - self.gestureBeganLocation.x
            var verticalDistance = location.y - self.gestureBeganLocation.y
            let height = NSNumber(value: Double(gestureRecognizerView.bounds.height / 2))
            var ratio = 1.0
            var alpha = 1.0
            if self.isPresented {
                ratio = JSCoreHelper.interpolateValue(abs(verticalDistance), inputRange: [0, height], outputRange: [1.0, 0.4], extrapolateLeft: .clamp, extrapolateRight: .clamp)
                alpha = JSCoreHelper.interpolateValue(abs(verticalDistance), inputRange: [0, height], outputRange: [1.0, 0.2], extrapolateLeft: .clamp, extrapolateRight: .clamp)
            } else {
                verticalDistance = -JSCoreHelper.bounce(fromValue: 0, toValue: verticalDistance > 0 ? -height.doubleValue : height.doubleValue, time: abs(verticalDistance) / height.doubleValue, coeff: 1.2)
            }
            let transform = CGAffineTransform(translationX: horizontalDistance, y: verticalDistance).scaledBy(x: ratio, y: ratio)
            self.currentPageCell?.transform = transform
            self.transitionAnimatorViews?.forEach { (subview) in
                subview.alpha = alpha
            }
        case .ended, .cancelled, .failed:
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            let verticalDistance = location.y - self.gestureBeganLocation.y
            if abs(verticalDistance) > self.dismissWhenSlidingDistance && self.isPresented {
                self.beginDismissingAnimation()
            } else {
                self.resetDismissingAnimation()
            }
        default:
            break
        }
    }
    
    public func beginDismissingAnimation() {
        if let context = self.transitionInteractiver.context {
            self.transitionAnimator.performAnimation(using: context, isEntering: false) { finished in
                self.transitionInteractiver.finish()
            }
        } else {
            self.resetDismissingAnimation()
        }
    }
    
    public func resetDismissingAnimation() {
        self.gestureBeganLocation = CGPoint.zero
        UIView.animate(withDuration: self.transitionAnimator.duration, delay: 0, options: JSCoreHelper.animationOptionsCurveOut) {
            self.currentPageCell?.transform = CGAffineTransform.identity
            self.transitionAnimatorViews?.forEach { (subview) in
                subview.alpha = 1.0
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
            return zoomView.modifier.thumbnailView()
        } else if self.currentPageCell is VideoCell {
            return UIImageView()
        }
        return nil
    }
    
    public var transitionThumbnail: UIImage? {
        let dataItem = self.dataSource[self.currentPage]
        
        if let photoCell = self.currentPageCell as? PhotoCell, let zoomView = photoCell.zoomView {
            if let image = zoomView.thumbnail {
                return image
            } else if let dataItem = dataItem as? ImageAssetItem, let image = dataItem.image ?? dataItem.thumbnail {
                return image
            } else if let dataItem = dataItem as? LivePhotoAssetItem, let image = dataItem.thumbnail {
                return image
            } else if let image = zoomView.asset as? UIImage {
                return image
            } else {
                return nil
            }
        } else if let videoCell = self.currentPageCell as? VideoCell {
            if let image = videoCell.videoPlayerView.thumbnail {
                return image
            } else {
                return dataItem.thumbnail
            }
        } else {
            return nil
        }
    }
    
    public var transitionSourceView: UIView? {
        return self.cacheSourceView
    }
    
    public var transitionSourceRect: CGRect {
        return self.sourceProvider?.sourceRect?(self.currentPage) ?? CGRect.zero
    }
    
    public var transitionTargetView: UIView? {
        return self.currentPageCell
    }
    
    public var transitionTargetFrame: CGRect {
        if let photoCell = self.currentPageCell as? PhotoCell, let zoomView = photoCell.zoomView {
            return zoomView.contentViewFrame
        } else if let videoCell = self.currentPageCell as? VideoCell {
            return videoCell.videoPlayerView.contentViewFrame
        }
        return .zero
    }
    
    public var transitionAnimatorViews: [UIView]? {
        var animatorViews: [UIView] = []
        if let dimmingView = self.mediaBrowserView.dimmingView {
            animatorViews.append(dimmingView)
        }
        self.view.subviews.forEach { (subview) in
            if subview != self.mediaBrowserView {
                animatorViews.append(subview)
            }
        }
        return animatorViews
    }
    
    public func transitionViewWillMoveToSuperview(_ transitionView: UIView) {
        self.mediaBrowserView.addSubview(transitionView)
    }
    
}

extension MediaBrowserViewController {
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
}

extension MediaBrowserViewController {
    
    public override var shouldAutorotate: Bool {
        guard let orientationViewController = self.orientationViewController else {
            return true
        }
        
        return orientationViewController.shouldAutorotate
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let orientationViewController = self.orientationViewController else {
            return .allButUpsideDown
        }
        
        return orientationViewController.supportedInterfaceOrientations
    }
    
    private var orientationViewController: UIViewController? {
        if let presentedFromViewController = self.presentedFromViewController {
            return presentedFromViewController
        } else if let viewControllers = self.navigationController?.viewControllers, let index = viewControllers.firstIndex(of: self) {
            return index > 0 ? viewControllers[index - 1] : nil
        }
        return nil
    }
    
}
