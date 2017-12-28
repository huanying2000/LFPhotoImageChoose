//
//  LFPhotoGroupViewModel.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import Photos

typealias PhotoGroupCompletionClosure = PhotoCompleteBlock0
typealias PhotoGroupSelectedClosure = PhotoCompleteBlock4
typealias PhotoGroupMessageClosure = PhotoCompleteBlock2


class LFPhotoGroupViewModel: LFBaseViewModel {

    //图片的大小
    var imageSize:CGSize = CGSize(width: 60, height: 60)
    
    //获取相册组完成的闭包 ((id) -> Void)
    var fetchGroupsCompletion:PhotoGroupCompletionClosure?
    
    //点击相册触发的闭包 ((id,id,Bool) -> Void)
    var selectedCompletion : PhotoGroupSelectedClosure?
    
    //请求图片对象的Store
    fileprivate let photoStore = LFPhotoStore()
    
    //存放所有组的数据源
    fileprivate var groups = [PHAssetCollection]()
    
    //控制器模态弹回 触发dismissGroupBlock (() -> Void)
    @objc func dismiss() {
        dismissClosure?()
    }
    
    deinit {
        LFPhotoCacheManager.sharedInstance.reset()
    }
    
    //请求获取默认的相册组 完成触发 fetchGroupsCompletion ((id) -> Void)
    func fetchDefaultGroups() {
        photoStore.fetchDefaultAllGroups { [weak self] (allGroups, collections) in
            if let strongSelf = self {
                strongSelf.groups = allGroups
                strongSelf.fetchGroupsCompletion?(allGroups as id)
            }
        }
    }
    
    /// 当前位置的PHAssetCollection对象
    ///
    /// - Parameter indexPathAt: 所在的位置
    /// - Returns: 当前位置的PHAssetCollection对象
    func assetCollection(indexPathAt indexPath:IndexPath) -> PHAssetCollection? {
        let row = indexPath.row
        
        if row > groups.count {
            return nil
        }
        return groups[row]
    }
    
    //获取当前位置的相册组和标题 ((id,id,id,UInt) -> Void)
    /// - Parameters:
    ///   - indexPath: 当前的位置
    ///   - completion: 获取信息完成的闭包,返回顺序:标题，图片，按照默认格式拼接的title,数量
    func loadGroupMessage(At indexPath:IndexPath,completion:@escaping PhotoGroupMessageClosure) {
        let collection = assetCollection(indexPathAt: indexPath)
        //获取资源
        LFPhotoHandleManager.assetCollection(detailInformationFor: collection!, size: imageSize) { (title, count, image) in
            let realTitle = "\(NSLocalizedString(title!, comment: ""))(\(count))"
            
            completion(title as id,image as id, realTitle as id,count)
        }
    }
    
    
    //获取当前位置相册的所有照片集合
    func fetchResult(photosIndexPathAt indexPath:IndexPath) -> PHFetchResult<AnyObject>
    {
        return PHAsset.fetchAssets(in: assetCollection(indexPathAt: indexPath)!, options: PHFetchOptions()) as! PHFetchResult<AnyObject>
    }
    
    /// 当前tableView的row被点击触发
    ///
    /// - Parameters:
    ///   - indexPath: 当前位置
    ///   - animated: 是否进行动画跳转
    func groupViewModel(lf_didSelectRowAt indexPath:IndexPath,animated:Bool) {
        //相册 indexPath 是否动画
        self.selectedCompletion?(assetCollection(indexPathAt: indexPath) as id ,indexPath as id, animated)
    }
}


extension LFPhotoGroupViewModel: LFTableViewModel{
    var title:String {
        get {
            return "相册"
        }
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func tableView(_ numberOfRowInSection: Int) -> Int {
        
        return self.groups.count
    }
    
    func tableViewModel(heightForCellRowAt indexPath: IndexPath) -> Float {
        return 80
    }
    
    
    
}







