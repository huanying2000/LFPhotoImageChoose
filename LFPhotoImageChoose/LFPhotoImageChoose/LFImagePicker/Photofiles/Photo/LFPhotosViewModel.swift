//
//  LFPhotosViewModel.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/27.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import Photos

typealias LFPhotoDidTapHandle = PhotoCompleteBlock7 //((id,id,id,id,Int) -> Void)
typealias LFPhotoSendStatusHandle = PhotoCompleteBlock6 //((Bool,UInt) -> Void)

/// 选择图片的一级界面控制器的viewModel
class LFPhotosViewModel: LFBaseViewModel {
    //当前显示的导航标题
    var navigationTitle: String = ""
    
    // MARK: private
    /// 存储该组所有的asset对象的数组
    fileprivate var assetsInResult = [PHAsset]()
    
    /// 存放当前所有的照片对象
    fileprivate var photosAssetResult = [PHAsset]()
    
    /// 缓存单例
    fileprivate var cacheManager = LFPhotoCacheManager.sharedInstance
    
    //存储该组所有的asset对象组合
    var assetResult: PHFetchResult<AnyObject>? {
        willSet {
            //初始化是否为图片数组PHFetchResult<AnyObject>
            LFPhotoCacheManager.sharedInstance.lf_memset(assetIsPictureSignal: (newValue?.count)!)
            //初始化是否被选中数组
            LFPhotoCacheManager.sharedInstance.lf_memset(assetIsSelectedSignal: (newValue?.count)!)
            //所有的照片资源[PHAsset]
            LFPhotoHandleManager.resultToArray(newValue!) { (assets, resultFetch) in
                
                self.assetsInResult = assets as! [PHAsset]
            }
        }
    }
    
    
    //当前显示的组对象
    var assetCollection : PHAssetCollection? {
        willSet {
            //获取到所有的照片资源 PHFetchResult<AnyObject>
            assetResult = LFPhotoStore.fetchPhotos(newValue!)
            
            //初始化所有的图片数组
            LFPhotoHandleManager.fetchResult(in: assetResult as! PHFetchResult<PHAsset>, type: PHAssetMediaType.image) { (allPhotos) in
                
                self.photosAssetResult = allPhotos
            }
        }
    }
    
    
    /// 图片被点击进入浏览控制器 ((id,id,id,id,Int) -> Void)
    var photoDidTapShouldBrowerHandle : LFPhotoDidTapHandle?
    
    /// 响应是否能够点击预览以及发送按钮 ((Bool,UInt) -> Void)
    var photoSendStatusChangedHandle : LFPhotoSendStatusHandle?
    
    /// 点击预览进入浏览控制器的，暂时使用photoSendStatusChangedHandle替代
    var pushBrowerControllerByBrowerButtonHandle : LFPhotoDidTapHandle?
    
    /// 资源数
    var assetCount : Int {
        
        get{
            return (self.assetResult?.count)!
        }
    }
    
    
    //通过点击浏览按钮 弹出浏览控制器 触发 pushBrowerControllerByBrowerButtonHandle
    func pushBrowerControllerByBrowerButtonTap() {
        //获取被选中的图片
        let assets = LFPhotoHandleManager.assets(assetsInResult, status: LFPhotoCacheManager.sharedInstance.assetIsSelectedSignal)
        let index = 0
        //assetResult 图片资源。 assetsInResult 所有资源 assets选中资源
        photoDidTapShouldBrowerHandle?(assetResult!,assetsInResult as id,assets as id,"" as id, index)
    }
    
    //图片选择完毕后调用
    override func photoDidSelectedComplete() {
        //获得筛选的数组
        let assets = LFPhotoHandleManager.filter(assetsIn: self.assetsInResult, status: LFPhotoCacheManager.sharedInstance.assetIsSelectedSignal)
        
        //进行回调
        LFPhotoBridgeManager.sharedInstance.start(renderFor: assets)
        
        super.photoDidSelectedComplete()
    }
    
    //请求当前位置图片对象
    /// - Parameters:
    ///   - index: 所在位置
    ///   - inCollection: 所在的集合视图
    ///   - completion: 请求完成的图片，请求的资源对象，是否为图片，如果是视频存在时长
    func viewModel(imageAt index:IndexPath,inCollection:UICollectionView,completion:@escaping((UIImage,PHAsset,Bool,TimeInterval) -> Void)) {
        //当前图片资源
        let currentAsset = (assetResult?[index.item] as! PHAsset)
        let size = collectonViewModel(sizeForItemAt: nil, inCollection: inCollection)
        //获取详细的信息
        LFPhotoHandleManager.asset(representionIn: currentAsset
        , size: size) { (image, asset) in
            var isImage = false
            if asset.mediaType == .image {
                isImage = true
                self.cacheManager.assetIsPictureSignal[index.item] = true
            }
            completion(image,asset,isImage,asset.duration)
        }
    }
    
    //图片被选中的处理方法
    func viewModel(didSelectedImageAt index:IndexPath) -> Bool {
        //修改标志位
        let isSelected = cacheManager.assetIsSelectedSignal[index.item]
        //记录
        cacheManager.numberOfSelectedPhoto += (isSelected ? -1 : 1)
        //如果已经超出最大限制
        guard cacheManager.numberOfSelectedPhoto <= cacheManager.maxNumeberOfSelectedPhoto else {
            cacheManager.numberOfSelectedPhoto -= 1
            //弹出框
            //弹出提醒框
            warningClosure?(false,UInt(cacheManager.maxNumeberOfSelectedPhoto))
            
            return false
        }
        //修改
        cacheManager.assetIsSelectedSignal[index.item] = !isSelected
        //检测变化
        lf_checkSendStatusChanged()
        return true
    }
    
    
    /// 检测当前可用状态
    func lf_checkSendStatusChanged()
    {
        let count = cacheManager.numberOfSelectedPhoto
        let enable = count >= 1
        
        
        photoSendStatusChangedHandle?(enable,UInt(count))
    }
    
    
    //该位置的图片是否被选中
    /// - Parameter index: 所在位置
    /// - Returns: 当前图片的状态
    func viewModel(imageDidSelectedAt index:IndexPath) ->Bool {
        return cacheManager.assetIsSelectedSignal[index.item]
    }
    
    deinit {
        cacheManager.free()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


extension LFPhotosViewModel : LFCollectionViewModel
{
    
    var title: String{
        
        get{
            return self.navigationTitle
        }
    }
    
    
    
    func numberOfSection() -> Int {
        
        return 1
    }
    
    
    func numberOfItem(in section: Int) -> Int {
        
        return (assetResult?.count)!
    }
    
    
    func collectonViewModel(sizeForItemAt indexPath: IndexPath?, inCollection: UICollectionView) -> CGSize {
        
        let height = (inCollection.bounds.width - 3) / 4
        
        return CGSize(width: height, height: height)
    }
    
    
    func collectonViewModel(referenceSizeForFooterIn section: Int, inCollection: UICollectionView) -> CGSize {
        
        return CGSize(width:inCollection.bounds.width,height:44)
    }
    
    
    
    func collectonViewModel(minimumLineSpacingForSectionIn section: Int) -> CGFloat {
        
        return 1.0
    }
    
    
    
    func collectonViewModel(minimumInteritemSpacingForSectionIn section: Int) -> CGFloat {
        
        return 1.0
    }
    
    //是否可以选中某个item 只有是图片的才能被选中
    func collectonViewModel(shouldSelectItemAt index: IndexPath) -> Bool {
        
        return LFPhotoCacheManager.sharedInstance.assetIsPictureSignal[index.item]
    }
    
    
    func collectonViewModel(didSelectedItemAt index: IndexPath) {
        
        // 获取当前的图片对象
        let asset = assetResult?[index.item] as! PHAsset
        
        //获得当前的位置
        let index : Int = photosAssetResult.index(of: asset)!
        
        photoDidTapShouldBrowerHandle?(assetResult!,assetsInResult as id,photosAssetResult as id,asset,index)
    }
    
    
    
    @available(iOS 10,*)
    func collectonViewModel(prefetchItemsAt indexs: [IndexPath]) {
        
    }
    
    @available(iOS 10,*)
    func collectonViewModel(cancelPrefetchingForItemsAt indexs: [IndexPath]) {
        
    }
    
}
