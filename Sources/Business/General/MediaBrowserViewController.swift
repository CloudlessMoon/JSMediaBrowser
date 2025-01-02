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
    
    public var sourceReference: MediaBrowserViewControllerSourceReference?
    
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
        
        self.cacheSourceView = self.sourceReference?.sourceView?(self.currentPage)
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
            self.cacheSourceView = self.sourceReference?.sourceView?(self.currentPage)
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
        viewController.modalPresentationStyle = .overCurrentContext
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
        defer {
            self.eventHandler?.willDisplayZoomView(cell.zoomView, at: index)
        }
        /// zoomView修改器
        cell.zoomView.modifier = self.configuration.zoomViewModifier(index)
        
        let updateProgress = { [weak cell] (receivedSize: Int64, expectedSize: Int64) in
            let progress = Progress(totalUnitCount: expectedSize)
            progress.completedUnitCount = receivedSize
            cell?.setProgress(progress)
        }
        let updateCell = { [weak cell] (error: NSError?, cancelled: Bool) in
            cell?.setError(error, cancelled: cancelled)
        }
        let updateAsset = { [weak cell] (asset: (any ZoomAsset)?) in
            guard let cell = cell else {
                return
            }
            cell.zoomView.asset = asset
            /// 解决资源下载完成后不播放的问题
            cell.zoomView.startPlaying()
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
                updateAsset(dataItem.thumbImage)
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
                            updateCell(nil, false)
                        case .failure(let error):
                            updateAsset(nil)
                            updateCell(error.error, error.isCancelled)
                        }
                    })
            } else {
                updateAsset(dataItem.thumbImage)
            }
        } else if let dataItem = self.dataSource[index] as? LivePhotoAssetItem {
            /// 缩略图
            updateAsset(dataItem.thumbImage)
            // todo
            
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
        cell.videoPlayerView.thumbImage = dataItem.thumbImage
        /// 前后url不相同时需要释放之前的player, 否则会先显示之前的画面, 再显示当前的
        if cell.videoPlayerView.url != dataItem.videoURL {
            cell.videoPlayerView.releasePlayer()
        }
        cell.setProgress(Progress())
        cell.videoPlayerView.isAutoPlay = !cell.isHidden
        cell.videoPlayerView.url = dataItem.videoURL
        
        self.eventHandler?.willDisplayVideoPlayerView(cell.videoPlayerView, at: index)
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDelegate {
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forPageAt index: Int) {
        if let photoCell = cell as? PhotoCell {
            photoCell.zoomView.startPlaying()
        } else if let videoCell = cell as? VideoCell {
            let status = videoCell.videoPlayerView.status
            if status == .ready || status == .paused {
                videoCell.videoPlayerView.play()
            }
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forPageAt index: Int) {
        if let photoCell = cell as? PhotoCell {
            photoCell.zoomView.stopPlaying()
        } else if let videoCell = cell as? VideoCell {
            videoCell.videoPlayerView.reset()
        }
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willScrollHalfFrom sourceIndex: Int, to targetIndex: Int) {
        self.cacheSourceView?.isHidden = false
        self.cacheSourceView = self.sourceReference?.sourceView?(targetIndex)
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
        if gestureRecognizer == mediaBrowserView.dismissingGesture {
            let gestureRecognizer = mediaBrowserView.dismissingGesture
            guard let photoCell = self.currentPageCell as? PhotoCell else {
                return true
            }
            let zoomView = photoCell.zoomView
            let velocity: CGPoint = gestureRecognizer.velocity(in: gestureRecognizer.view)
            let minY: CGFloat = ceil(zoomView.minContentOffset.y)
            let maxY: CGFloat = floor(zoomView.maxContentOffset.y)
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
        if gestureRecognizer == mediaBrowserView.longPressGesture {
            guard let photoCell = self.currentPageCell as? PhotoCell else {
                return true
            }
            return nil
        } else {
            return nil
        }
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
        guard let photoCell = self.currentPageCell as? PhotoCell else {
            return
        }
        let zoomView = photoCell.zoomView
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
    
    public var transitionModifier: TransitioningModifier {
        return self.configuration.transitioningModifier(self.currentPage)
    }
    
    public var transitionSourceView: UIView? {
        return self.cacheSourceView
    }
    
    public var transitionSourceRect: CGRect {
        return self.sourceReference?.sourceRect?(self.currentPage) ?? CGRect.zero
    }
    
    public var transitionThumbImage: UIImage? {
        let dataItem = self.dataSource[self.currentPage]
        if let dataItem = dataItem as? ImageAssetItem {
            // todo
            var result: UIImage?
            if let photoCell = self.currentPageCell as? PhotoCell, let image = photoCell.zoomView.asset as? UIImage {
                result = image
            } else if let image = dataItem.image != nil ? dataItem.image : dataItem.thumbImage {
                result = image
            }
            return result
        } else if let dataItem = dataItem as? LivePhotoAssetItem {
            // todo
            return dataItem.thumbImage
        } else if let dataItem = dataItem as? VideoAssetItem {
            if let videoCell = self.currentPageCell as? VideoCell {
                return videoCell.videoPlayerView.thumbImage
            } else if let image = dataItem.thumbImage {
                return image
            }
        }
        return nil
    }
    
    public var transitionTargetView: UIView? {
        return self.currentPageCell
    }
    
    public var transitionTargetFrame: CGRect {
        if let photoCell = self.currentPageCell as? PhotoCell {
            return self.transitionThumbImage != nil ? photoCell.zoomView.contentViewFrame : CGRect.zero
        } else if let videoCell = self.currentPageCell as? VideoCell {
            return self.transitionThumbImage != nil ? videoCell.videoPlayerView.contentViewFrame : CGRect.zero
        }
        return CGRect.zero
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
