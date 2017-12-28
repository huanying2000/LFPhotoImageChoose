//
//  LFPhotoBrowseViewModel.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/28.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import Photos

class LFPhotoBrowseViewModel: LFBaseViewModel {
    struct LFPhotoBrowseViewModelAssociate {
        static let lf_photoBrowViewAssociateBar = UnsafeRawPointer(bitPattern: "lf_photoBrowViewAssociateBar".hashValue)
        static let lf_photoBrowViewEndDeceleratingAssociate = UnsafeRawPointer(bitPattern: "lf_photoBrowViewEndDeceleratingAssociate".hashValue)
    }
    
    //当前图片的位置
    var current : Int = 0
    //存储图片选择的所有资源对象
    var allAssets = [PHAsset]()
    //所有的图片资源
    var allPhotoAssets = [PHAsset]()
    
    //当前cell应该显示清晰图的回调
    var lf_browseCellRefreshHandle : ((UIImage,PHAsset,IndexPath) ->Void)?
    //当前的选中按钮刷新成当前图片状态
    var lf_browseSelectedBtnRefreshHandle : ((UIImage) -> Void)?
    /// 浏览控制器将要消失的回调
    var lf_browseWilldisappearHandle : (() -> Void)?
    /// 响应是否显示当前数目标签以及数目
    var lf_browseStatusChangedHandle : ((Bool,Int)->Void)?
    
    /// 控制器的bar对象隐藏的状态
    var lf_browseBarHiddenChangeHandle : ((Bool) -> Void)?
    
    
    /// 高清状态发生变化
    var lf_browseQuarityChangeHandle : ((Bool) -> Void)?
    
    /// 请求高清数据过程
    var lf_browseRequestQuarityHandle : ((Bool,id) -> Void)?
    
    /// 请求高清数据完毕
    var lf_browseRequestQuarityCompletionHandle : ((id) -> Void)?
    
    //点击选择按钮 触发lf_browseSelectedBtnRefreshHandle
    func select(in scrollView:UICollectionView) {
        let cacheManager = LFPhotoCacheManager.sharedInstance
        //获得当前的偏移量
        let currentIndex = lf_index(indexFromAllPhotosToAll: Int(lf_index(contentOffSetIn: scrollView)))
        //修改标志位
        let temp = cacheManager.assetIsSelectedSignal[currentIndex] ? -1 : 1
        cacheManager.numberOfSelectedPhoto += temp
        
        //判断是否达到上限
        guard cacheManager.numberOfSelectedPhoto <= cacheManager.maxNumeberOfSelectedPhoto else {
            
            //退回
            cacheManager.numberOfSelectedPhoto -= 1
            
            //弹出警告
            warningClosure?(false,UInt(cacheManager.maxNumeberOfSelectedPhoto))
            
            return
        }
        //修改状态
        cacheManager.lf_change(selecteStatusIn: currentIndex)
        
        //检测
        lf_checkPhotoShouldSend()
        //执行
        lf_browseSelectedBtnRefreshHandle?(lf_image(currentIndex))
        
        
    }

    //从所有的图片资源转换为当前资源的位置
    fileprivate func lf_index(indexFromAllPhotosToAll index:Int) ->Int {
        let currentAsset = allPhotoAssets[index]
        return allAssets.index(of: currentAsset)!
    }
    /// 根据scrollView的偏移量获得当前资源的位置
    ///
    /// - Parameter scrollView: scrollView
    /// - Returns: 当前显示资源的位置
    fileprivate func lf_index(contentOffSetIn scrollView:UIScrollView) -> Int
    {
        let collectionView = scrollView as! UICollectionView
        
        return Int(collectionView.contentOffset.x / collectionView.bounds.width)
    }
    
    //检测当前是否可以发送图片
    func lf_checkPhotoShouldSend() {
        let count = LFPhotoCacheManager.sharedInstance.numberOfSelectedPhoto
        
        let enabel = count >= 1
        
        lf_browseStatusChangedHandle?(enabel,count)
    }
    
    ///  当前选择位置显示的图片
    ///
    /// - Parameter isSelected: 选中的状态
    /// - Returns:
    fileprivate func lf_image(status isSelected:Bool = false) -> UIImage
    {
        return (isSelected ? lf_selectedImage : lf_deselectedImage)!
    }
    
    
    fileprivate func lf_image(_ index:Int) -> UIImage
    {
        return lf_image(status: lf_isSelected(index))
    }
    
    /// 所有的资源中是否被选择
    ///
    /// - Parameter index: 当前资源的位置
    /// - Returns: true表示被选，false表示没有被选
    fileprivate func lf_isSelected(_ index:Int) -> Bool
    {
        return LFPhotoCacheManager.sharedInstance.assetIsSelectedSignal[index]
    }
    
    /// 控制器将要消失的方法
    func controllerWillDisAppear()
    {
        lf_browseWilldisappearHandle?()
    }
    /// 点击发送执行的方法
    ///
    /// - Parameter scrollView: collectionView
    func selected(in scrollView:UICollectionView)
    {
        let cacheManager = LFPhotoCacheManager.sharedInstance
        
        //表示没有选择任何的照片
        let isEmpty = cacheManager.numberOfSelectedPhoto == 0
        
        //如果没有选择图片 点击了发送 默认发送当前显示的图片
        if isEmpty {
            
            //获得当前偏移量
            let currentIndex = lf_index(indexFromAllPhotosToAll: Int(lf_index(contentOffSetIn: scrollView)))
            
            //修改当前的标志位
            cacheManager.lf_change(selecteStatusIn: currentIndex)
        }
        
        //获得所有选中的图片
        let  assets = LFPhotoHandleManager.filter(assetsIn: allAssets, status: cacheManager.assetIsSelectedSignal)
        
        //进行bridge
        LFPhotoBridgeManager.sharedInstance.start(renderFor: assets)
        
        //弹出
        dismissClosure?()
    }
    
    
    //获取当前位置的图片对象
    /// - Parameters:
    ///   - indexPath: 所在位置
    ///   - collection: collectionView
    ///   - isThum: 是否为缩略图，如果为false，则按照图片原始比例获得
    ///   - completion: 完成
    func image(at indexPath:IndexPath,in collection:UICollectionView,isThum:Bool,completion:@escaping ((UIImage,PHAsset) -> Void)) {
        //获得当前的资源
        let asset = allPhotoAssets[indexPath.item]
        //图片比
        let scale = CGFloat(asset.pixelHeight) * 1.0 / CGFloat(asset.pixelWidth)
        
        //默认图片大小
        var size = CGSize(width: 60, height: 60 * scale)
        
        // 如果不是缩略图
        if !isThum {
            
            let height = (collection.bounds.width - 10) * scale
            
            size = CGSize(width: height / scale, height: height)
        }
        
        LFPhotoHandleManager.asset(representionIn: asset, size: size) { (image, asset) in
            
            completion(image,asset)
        }
        
    }
    
    /// bar对象的隐藏
    func sendViewBarShouldChangedSignal()
    {
        guard (objc_getAssociatedObject(self, LFPhotoBrowseViewModelAssociate.lf_photoBrowViewAssociateBar!)) != nil else {
            
            //需要隐藏
            objc_setAssociatedObject(self, LFPhotoBrowseViewModelAssociate.lf_photoBrowViewAssociateBar!, true, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            
            lf_browseBarHiddenChangeHandle?(true); return
        }
        
        let isHidden = objc_getAssociatedObject(self, LFPhotoBrowseViewModelAssociate.lf_photoBrowViewAssociateBar!) as! Bool
        
        //变换
        objc_setAssociatedObject(self, LFPhotoBrowseViewModelAssociate.lf_photoBrowViewAssociateBar!, !isHidden, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        
        lf_browseBarHiddenChangeHandle?(!isHidden)
    }
    
    
    /// 高清状态发生变化
    ///
    /// - Parameter scrollView:
    func hightQuality(statusChangedIn scrollView:UIScrollView)
    {
        let isHightQuality = LFPhotoCacheManager.sharedInstance.isHightQuarity
        
        //变换标志位
        LFPhotoCacheManager.sharedInstance.isHightQuarity = !isHightQuality
        
        lf_checkHightQuarityStatus()
        
        //进入高清图进行计算
        if !isHightQuality {
            
            lf_check(hightQuarityChangedAt: lf_index(contentOffSetIn: scrollView))
            
        }
    }
    
    
    /// 检测当前是否为高清状态，并执行响应的block
    ///
    /// - Parameter index: 当前展示图片的索引
    fileprivate func lf_check(hightQuarityChangedAt index:Int)
    {
        let cacheManager = LFPhotoCacheManager.sharedInstance
        
        guard cacheManager.isHightQuarity else {
            
            return
        }
        
        let currentAsset = allPhotoAssets[index]
        
        lf_browseRequestQuarityHandle?(true,"startAnimating" as id)
        
        //获取高清数据
        LFPhotoHandleManager.asset(hightQuarityFor: currentAsset, Size: CGSize(width: currentAsset.pixelWidth, height: currentAsset.pixelHeight)) { (size) in
            
            self.lf_browseRequestQuarityHandle?(false,"stopAnimating" as id)
            self.lf_browseRequestQuarityCompletionHandle?(size as id)
        }
    }
    
    
    /// 检测浏览是否为高清状态
    func lf_checkHightQuarityStatus()
    {
        lf_browseQuarityChangeHandle?(LFPhotoCacheManager.sharedInstance.isHightQuarity)
    }
    
    
    
}


extension LFPhotoBrowseViewModel : LFCollectionViewModel
{
    func scrollViewModel(didEndDeceleratingIn scrollView:UIScrollView) {
        
        let currentIndex = lf_index(contentOffSetIn: scrollView)
        
        //获得当前记录的位置
        let index = current
        
        // 判断是否为第一次进入
        let shouldIgnoreCurrentIndex = objc_getAssociatedObject(self, LFPhotoBrowseViewModelAssociate.lf_photoBrowViewEndDeceleratingAssociate!)
        
        // 如果不是第一次进入并且索引没有变化，不操作
        if shouldIgnoreCurrentIndex != nil && index == currentIndex  {
            
            return
        }
        
        current = currentIndex
        
        //修改
        objc_setAssociatedObject(self, LFPhotoBrowseViewModelAssociate.lf_photoBrowViewEndDeceleratingAssociate!, false, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        
        //获得indexPath
        let indexPath = IndexPath(item: currentIndex, section: 0)
        
        //请求高清图片
        image(at: indexPath, in: scrollView as! UICollectionView, isThum: false) { [weak self](image, asset) in
            
            self?.lf_browseCellRefreshHandle?(image,asset,indexPath)
            
        }
        
        //执行判定
        lf_browseSelectedBtnRefreshHandle?(lf_image(lf_index(indexFromAllPhotosToAll: currentIndex)))
        
        //变化
        lf_check(hightQuarityChangedAt: currentIndex)
    }
    
    
    
    func numberOfItem(in section: Int) -> Int {
        
        return allPhotoAssets.count
    }
    
    
    
    func collectonViewModel(sizeForItemAt indexPath: IndexPath?, inCollection: UICollectionView) -> CGSize {
        
        return CGSize(width: inCollection.bounds.width, height: inCollection.bounds.height)
    }
    
    
    func collectonViewModel(minimumInteritemSpacingForSectionIn section: Int) -> CGFloat {
        
        return 0.0
    }
    
    
    func collectonViewModel(minimumLineSpacingForSectionIn section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func collectonViewModel(didEndDisplayCellForItemAt index: IndexPath) {
        
        lf_browseSelectedBtnRefreshHandle?(lf_image(index.item))
        
    }
}
