//
//  HomeViewController.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import QMUIKit
import SDWebImage
import SnapKit
import JSMediaBrowser
import Then

class HomeViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = false
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    lazy var dataSource: [String] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.addSubview(self.collectionView)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(HomePictureCell.self, forCellWithReuseIdentifier: "\(HomePictureCell.self)")
        
        /// 数据源
        guard let data = try? Data(contentsOf: NSURL.fileURL(withPath: Bundle.main.path(forResource: "data", ofType: "json") ?? "")) else {
            return
        }
        var array = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? [String]
        
        if let image = Bundle.main.url(forResource: "LivePhoto", withExtension: "JPG") {
            array?.append(image.absoluteString)
        }
        if let HDR = Bundle.main.path(forResource: "TestHDR1", ofType: "heic") {
            array?.append(URL(fileURLWithPath: HDR).absoluteString)
        }
        if let HDR = Bundle.main.path(forResource: "TestHDR2", ofType: "JPG") {
            array?.append(URL(fileURLWithPath: HDR).absoluteString)
        }
        if let HDR = Bundle.main.path(forResource: "TestHDR3", ofType: "JPG") {
            array?.append(URL(fileURLWithPath: HDR).absoluteString)
        }
        if let data = Bundle.main.path(forResource: "data1", ofType: "jpg") {
            array?.append(URL(fileURLWithPath: data).absoluteString)
        }
        if let data = Bundle.main.path(forResource: "data2", ofType: "gif") {
            array?.append(URL(fileURLWithPath: data).absoluteString)
        }
        if let data = Bundle.main.path(forResource: "data3", ofType: "jpg") {
            array?.append(URL(fileURLWithPath: data).absoluteString)
        }
        if let data = Bundle.main.path(forResource: "data4", ofType: "jpg") {
            array?.append(URL(fileURLWithPath: data).absoluteString)
        }
        self.dataSource = array ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "图片/视频预览"
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let margin = QMUIHelper.isMac ? 60.0 : 24.0
        self.collectionView.qmui_initialContentInset = UIEdgeInsets(top: self.view.safeAreaInsets.top + 5,
                                                                    left: margin + self.view.safeAreaInsets.left,
                                                                    bottom: self.view.safeAreaInsets.bottom,
                                                                    right: margin + self.view.safeAreaInsets.right)
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.frame = self.view.bounds
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(HomePictureCell.self)", for: indexPath) as? HomePictureCell else {
            fatalError()
        }
        let item = self.dataSource[indexPath.item]
        cell.imageView.sd_setImage(with: URL(string: item), placeholderImage: nil, options: [.decodeFirstFrameOnly])
        return cell
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interitemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
        let columnsCount = QMUIHelper.isMac ? 6.0 : 3.0
        let size = (collectionView.qmui_width - UIEdgeInsetsGetHorizontalValue(collectionView.adjustedContentInset) - (columnsCount - 1) * interitemSpacing) / columnsCount
        return CGSizeFloor(CGSize(width: size, height: size))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browserVC = BrowserViewController()
        browserVC.dataSource = self.dataSource.enumerated().map {
            let cell = collectionView.cellForItem(at: IndexPath(item: $0.offset, section: 0)) as? HomePictureCell
            var item: AssetItem
            if $0.element.contains("LivePhoto") {
                let video = Bundle.main.url(forResource: "LivePhoto", withExtension: "MOV")!
                item = LivePhotoItem(imageURL: URL(string: $0.element)!, videoURL: video, thumbnail: cell?.imageView.image)
            } else {
                item = ImageItem(imageURL: URL(string: $0.element), thumbnail: cell?.imageView.image)
            }
            return item
        }
        browserVC.sourceProvider = .init(sourceView: { [weak self] in
            guard let self = self else { return nil }
            guard let cell = self.pictureCell(at: $0) else {
                return nil
            }
            return cell.imageView
        })
        browserVC.setCurrentPage(indexPath.item, animated: false)
        browserVC.show(from: self, navigationController: QMUINavigationController(rootViewController: browserVC), animated: true)
    }
    
}

extension HomeViewController {
    
    private func pictureCell(at index: Int) -> HomePictureCell? {
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? HomePictureCell else {
            return nil
        }
        return cell
    }
    
}

extension HomeViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
}
