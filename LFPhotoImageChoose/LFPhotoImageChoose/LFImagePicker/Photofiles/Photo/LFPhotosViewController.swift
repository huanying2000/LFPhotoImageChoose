//
//  LFPhotosViewController.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/27.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import Photos


let lf_photos_cellIdentifier = "lfCollectionPhotosCell"
let lf_photos_resuableViewIdentifier = "lfPhotoBottomReusableView"


//选择图片的一级界面控制器
class LFPhotosViewController: UIViewController {

    //当前控制器的viewModel
    var viewModel = LFPhotosViewModel()
    
    //显示的集合视图
    /// 显示的集合视图
    fileprivate lazy var collectionView : UICollectionView = {
        
        var collectionView :UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 44),collectionViewLayout:UICollectionViewFlowLayout())
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if #available(iOS 10, *)
        {
            collectionView.prefetchDataSource = self
        }
        
        collectionView.backgroundColor = .white
        
        //register
        collectionView.register(LFPhotosCell.self, forCellWithReuseIdentifier: lf_photos_cellIdentifier)
        collectionView.register(LFPhotoBottomReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: lf_photos_resuableViewIdentifier)
        
        
        return collectionView
        
    }()
    
    //底部的tabbar
    fileprivate lazy var bottomBar : UITabBar = {
        
        return UITabBar(frame:CGRect(x: 0, y: self.view.bounds.height - 44, width: self.view.bounds.width, height:44))
        
    }()
    
    
    /// 预览按钮
    fileprivate lazy var bowerButton : UIButton = {
        
        var button = UIButton(frame: CGRect(x: 5, y: 5, width: 60, height: 30))
        button.center = CGPoint(x: button.center.x, y: self.bottomBar.bounds.height / 2)
        
        button.setTitle("预览", for: .normal)
        button.setTitle("预览", for: .disabled)
        
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(UIColor.black.withAlphaComponent(0.25), for: .disabled)
        
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.titleLabel?.textAlignment = .center
        
        button.showsTouchWhenHighlighted = true
        
        //默认不可点击
        button.isEnabled = false
        
        //响应
        button.action(at: .touchUpInside, handle: { [weak self](sender) in
            
            let strongSelf = self
            
            strongSelf?.viewModel.pushBrowerControllerByBrowerButtonTap()
            
        })
        
        return button
    }()
    
    
    /// 发送按钮
    fileprivate lazy var sendButton : UIButton = {
        
        var button : UIButton = UIButton(frame: CGRect(x: self.bottomBar.bounds.width - 50 - 5, y: 0, width: 50, height: 40))
        
        button.center = CGPoint(x: button.center.x, y: self.bottomBar.bounds.height / 2)
        
        button.setTitle("发送", for: .normal)
        button.setTitle("发送", for: .disabled)
        
        //        button.setTitleColor(.colorValue(with: 0x2dd58a), for: .normal)
        //        button.setTitleColor(UIColor.colorValue(with: 0x2DD58A)?.withAlphaComponent(0.25), for: .disabled)
        button.setTitleColor(0x2dd58a.lf_color, for: .normal)
        button.setTitleColor(0x2DD58A.lf_color.withAlphaComponent(0.25), for: .disabled)
        
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.titleLabel?.textAlignment = .center
        
        button.showsTouchWhenHighlighted = true
        
        //默认不可用
        button.isEnabled = false
        
        //发送
        button.action(at: .touchUpInside, handle: {[weak self] (sender) in
            
            let strongSelf = self
            
            strongSelf!.viewModel.photoDidSelectedComplete()
        })
        
        return button
        
    }()
    
    
    /// 显示数目的标签
    fileprivate lazy var numberOfLabel : UILabel = {
        
        var label : UILabel = UILabel(frame: CGRect(x: self.sendButton.frame.origin.x - 20, y: 0, width: 20, height: 20))
        label.center = CGPoint(x: label.center.x, y: self.sendButton.center.y)
        
        //        label.backgroundColor = .colorValue(with: 0x2dd58a)
        label.backgroundColor = 0x2dd58a.lf_color
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 14)
        label.text = ""
        label.isHidden = true
        label.textColor = .white
        label.layer.cornerRadius = label.bounds.width / 2.0
        label.clipsToBounds = true
        
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(LFPhotosViewController.dimiss))
        
        //添加视图
        self.view.backgroundColor = .white
        self.view.addSubview(collectionView)
        self.view.addSubview(bottomBar)
        bottomBar.addSubview(bowerButton)
        bottomBar.addSubview(sendButton)
        bottomBar.addSubview(numberOfLabel)
        
        //获得资源数
        let items = viewModel.numberOfItem(in: 0)
        if items >= 1 {
            collectionView.scrollToItem(at: IndexPath(item: items - 1, section: 0), at: UICollectionViewScrollPosition.bottom, animated: false)
            //记得要是配iPhoneX哦
            collectionView.contentOffset = CGPoint(x: 0, y: collectionView.contentOffset.y + 64)
        }
        bindViewModel()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    
    deinit {
        print("我是会被释放的哦")
    }
    
    //更新选中的图片数
    /// - Parameter numberOfAssets: 选中的图片数
    func update(_ numberOfAsset:UInt) {
        let hidden = numberOfAsset == 0
        numberOfLabel.isHidden = hidden
        
        if !hidden {
            numberOfLabel.text = "\(numberOfAsset)"
            numberOfLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.3, animations: {
                self.numberOfLabel.transform = .identity
            })
        }
    }
    
    fileprivate func bindViewModel() {
        //响应是否能够点击预览以及发送按钮 每次选中图片 都会触发
        viewModel.photoSendStatusChangedHandle = { [weak self] (enable,count) in
            let strongSelf = self
            
            strongSelf?.bowerButton.isEnabled = enable
            strongSelf?.sendButton.isEnabled = enable
            strongSelf?.update(count)
        }
        
        viewModel.dismissClosure = { [weak self] in
            let strongSelf = self
            
            strongSelf?.dimiss()
        }
        
        viewModel.warningClosure = { [weak self] (_,count) in
            let strongSelf = self
            strongSelf?.present(alertControllerShow: count)
        }
        //((id,id,id,id,Int) -> Void)
        //assetResult 图片资源。 assetsInResult 所有资源 assets选中资源
        //点击浏览按钮 FetchAssetResult<AnyObject> ,所有资源 所有图片资源 选中资源
        //photoDidTapShouldBrowerHandle?(assetResult!,assetsInResult as id,assets as id,"" as id, index)
        viewModel.photoDidTapShouldBrowerHandle = { [weak self] (result,allAssets,allPhotosAssets,asset,index) in
            let strongSelf = self
            
            //初始化控制器
            let viewController = LFPhotoBrowseController()
            
            //获取viewModel
            let viewModel = viewController.viewModel
            
            //设置
            viewModel.allAssets = allAssets as! [PHAsset]
            viewModel.allPhotoAssets = allPhotosAssets as! [PHAsset]
            viewModel.current = Int(index)
            
            //刷新当前的视图
            viewModel.lf_browseWilldisappearHandle = {
                
                strongSelf?.collectionView.reloadData()
                
                //检测发送按钮的可用性
                strongSelf?.viewModel.lf_checkSendStatusChanged()
                
            }
            
            //进入下一个浏览控制器
            strongSelf?.navigationController?.pushViewController(viewController, animated: true)
        }
        
        
    }
    @objc fileprivate func dimiss()
    {
        self .dismiss(animated: true) { }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension LFPhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return viewModel.collectonViewModel(sizeForItemAt: indexPath, inCollection: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return viewModel.collectonViewModel(referenceSizeForFooterIn: section, inCollection: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return viewModel.collectonViewModel(minimumLineSpacingForSectionIn: section)
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return viewModel.collectonViewModel(minimumInteritemSpacingForSectionIn: section)
    }
    
    
    
    //当前item是否能选中 只有图片才能被选中
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        return viewModel.collectonViewModel(shouldSelectItemAt: indexPath)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //触发 photoDidTapShouldBrowerHandle?(assetResult!,assetsInResult as id,photosAssetResult as id,asset,index) 进入浏览器界面
        viewModel.collectonViewModel(didSelectedItemAt: indexPath)
    }
    
    
    //将要加载某个Item时调用的方法
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        (cell as! LFPhotosCell).selected(viewModel.viewModel(imageDidSelectedAt: indexPath))
    }
}


extension LFPhotosViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.viewModel.numberOfItem(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell  {
        let cell : LFPhotosCell = collectionView.dequeueReusableCell(withReuseIdentifier: lf_photos_cellIdentifier, for: indexPath) as! LFPhotosCell
        
        //开始获取图片对象
        viewModel.viewModel(imageAt: indexPath, inCollection: collectionView) { (image, asset, isImage, timeDuation) in
            if isImage {
                cell.lf_imageView.image = image
            }
            //是图片才能显示
            cell.lf_chooseControl.isHidden = !isImage
            if !isImage { //如果不是图片 显示时长
                cell.lf_messageView.isHidden = isImage
                //                cell?.ritl_messageLabel.text = ritl_timeFormat(timeDuation)
                cell.lf_messageLabel.text = timeDuation.lf_time
            }
        }
        
        //响应
        cell.chooseImageDidSelectHandle = { [weak self] (sender) in
            if (self?.viewModel.viewModel(didSelectedImageAt: indexPath))! {
                
                sender.selected((self?.viewModel.viewModel(imageDidSelectedAt: indexPath))!)
            }
        }
        
        //响应3D Touch
        if #available(iOS 9.0, *) {
            
            // 确认为3D Touch可用
            if traitCollection.forceTouchCapability == .available {
                
                registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: cell)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let resuableView : LFPhotoBottomReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: lf_photos_resuableViewIdentifier, for: indexPath) as! LFPhotoBottomReusableView
        
        // 设置显示的数目
        resuableView.lf_numberOfAsset = viewModel.assetCount
        
        return resuableView
    }
}

@available(iOS 10, *)
extension LFPhotosViewController : UICollectionViewDataSourcePrefetching
{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        viewModel.collectonViewModel(prefetchItemsAt: indexPaths)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
        viewModel.collectonViewModel(cancelPrefetchingForItemsAt: indexPaths)
    }
}

@available(iOS 9.0,*)

extension LFPhotosViewController : UIViewControllerPreviewingDelegate
{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        let indexPath = collectionView.indexPath(for: previewingContext.sourceView as! LFPhotosCell)
        
        viewModel.collectonViewModel(didSelectedItemAt: indexPath!)
    }
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        //获得索引
        let item = collectionView.indexPath(for: previewingContext.sourceView as! LFPhotosCell)?.item
        
        //获得当前的资源
        let asset : PHAsset = viewModel.assetResult?[item!] as! PHAsset
        
        guard asset.mediaType == .image else {
            
            return nil
        }
        
        let viewController = LFPhotoPreviewController()
        
        viewController.showAsset = asset
        
        return viewController
    }
}



