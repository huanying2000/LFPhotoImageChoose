//
//  LFPhotoStore.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import Photos

@available(iOS 8.0, *)
class LFPhotoStore: NSObject {
    //负责请求图片对象的图片库
    fileprivate let photoLibrary:PHPhotoLibrary = PHPhotoLibrary.shared()
    
    //配置类的对象
    var config:LFPhotoConfig = LFPhotoConfig()
    
    //相册变化发生的回调
    var photoStoreHasChanged: ((_ changeInstance:PHChange)->Void)?
    
    override init() {
        super.init()
        photoLibrary.register(self as! PHPhotoLibraryChangeObserver)
    }
    
    convenience init(config:LFPhotoConfig)
    {
        self.init()
        self.config = config
    }
    
    
    deinit {
        /// 移除观察者
        photoLibrary.unregisterChangeObserver(self as! PHPhotoLibraryChangeObserver)
    }
    
    //MARK 相册
    // MARK: fetch
    
    /// 获取photos提供的所有的智能分类相册组，与config属性无关
    ///
    /// - Parameter groups: 图片组对象
    func fetch(groups: @escaping ([PHAssetCollection]) -> Void) ->Void {
        lf_fetchBasePhotosGroup { (group) in
            guard let group = group else {
                return
            }
            //group 是PHFetchResult<PHAssetCollection> 需要转换为 [PHAsset]
            LFPhotoHandleManager.resultToArray(group as! PHFetchResult<AnyObject>, complete: { [weak self] (completeGroup, completeResult) in
                groups((self?.lf_handleAssetCollection(completeGroup as! [PHAssetCollection]))!)
            })
        }
    }
    
    //将处理数组中的 胶卷相机排在第一位
    private func lf_handleAssetCollection(_ assCollection:[PHAssetCollection]) ->[PHAssetCollection] {
        var collections:[PHAssetCollection] = assCollection
        for i in 0..<assCollection.count {
            //获取资源
            let collection = assCollection[i]
            guard let collectionTitle = collection.localizedTitle else {
                continue
            }
            if collectionTitle.isEqual(NSLocalizedString(ConfigurationAllPhotos, comment: "")) || collectionTitle.isEqual(NSLocalizedString(ConfigurationCameraRoll,comment:""))
            {
                collections.remove(at: i)
                collections.insert(collection, at: 0)
            }
        }
        return collections
    }
    
    /// 根据photos提供的智能分类相册组 根据config中的groupNamesConfig属性进行筛别
    ///
    /// - Parameter groups: 图片组对象
    func fetchDefault(groups:@escaping ([PHAssetCollection])-> Void) -> Void
    {
        
        lf_fetchBasePhotosGroup { [weak self](result) in
            
            let strongSelf = self;
            
            guard let result = result else { return }
            
            strongSelf!.lf_prepare(result, complete: { (defaultGroup) in
                
                groups((strongSelf?.lf_handleAssetCollection(defaultGroup))!)
                
            })
            
        }
    }
    /// 将configuration属性中的分类进行筛选
    ///
    /// - Parameters:
    ///   - result: 进行筛选的result
    ///   - complete: 处理完毕的数组
    private func lf_prepare(_ result:PHFetchResult<PHAssetCollection>,complete:@escaping(([PHAssetCollection]) -> Void))
    {
        var preparationCollections = [PHAssetCollection]()
        
        result.enumerateObjects({ (obj, idx, stop) in
            
            if self.config.groups.contains(obj.localizedTitle!)
            {
                preparationCollections.append(obj)
            }
            
            if idx == result.count - 1
            {
                complete(preparationCollections)
            }
        })
    }
    
    
    
    //获取最基本的智能分组
    private func lf_fetchBasePhotosGroup(complete: @escaping (PHFetchResult<PHAssetCollection>?) ->Void) {
        lf_checkAuthorizationState(allow: {
            //获取智能分组 返回 PHFetchResult<PHAssetCollection>
            let smartGroups = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
            complete(smartGroups)
            
        }) {
            //用户不允许操作
        }
    }
    
    
    
    //检测权限
    private func lf_checkAuthorizationState(allow:@escaping (() ->Void),denied:@escaping(() ->Void)) {
        //获得权限
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: //允许
            allow()
        case .notDetermined://询问
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    allow()
                }else {
                    denied()
                }
            })
        case .denied: //不允许
            fallthrough
        case .restricted:
            denied()
        }
    }
    
    /// 根据photos提供的智能分类相册组 根据config中的groupNamesConfig属性进行筛别 并添加上其他在手机中创建的相册
    ///
    /// - Parameter groups:
    
    func fetchDefaultAllGroups(_ groups:@escaping (([PHAssetCollection],PHFetchResult<AnyObject>) -> Void)) {
        var defaultAllGroups = [PHAssetCollection]()
        fetchDefault { (defaultGroups) in
            defaultAllGroups.append(contentsOf: defaultGroups)
            //遍历自定义数组
            LFPhotoHandleManager.resultToArray(PHCollection.fetchTopLevelUserCollections(with: PHFetchOptions()) as! PHFetchResult<AnyObject>, complete: { (topLevelArray, result) in
                defaultAllGroups.append(contentsOf:topLevelArray as! [PHAssetCollection])
                //进行主线程回调
                if Thread.isMainThread {
                    
                    groups(defaultAllGroups,result); return
                }
                DispatchQueue.global().async {
                    
                    //主线程刷新UI
                    DispatchQueue.main.async {
                        
                        groups(defaultAllGroups,result)
                        
                    }
                }
            })
        }
    }
    
    
    
    //MARK 相片
    //获取某个相册的所有图片的简便方法
    static func fetchPhotos(_ group: PHAssetCollection) ->PHFetchResult<AnyObject> {
        return PHAsset.fetchAssets(in: group, options: PHFetchOptions()) as! PHFetchResult<AnyObject>
    }
    
    
}
    
extension LFPhotoStore : PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        //相册改变的回调
        self.photoStoreHasChanged?(changeInstance)
    }

}

// MARK 对组的操作

extension LFPhotoStore {
    //创建一个相册
    ///
    /// - Parameters:
    ///   - title: 相册的名称
    ///   - complete: 完成
    ///   - fail: 失败
    func add(customGroupNamed title:String,complete:@escaping(() -> Void),fail:@escaping((String?) -> Void)) {
        photoLibrary.performChanges({
            //执行请求
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
        }) { (success, error) in
            if success == true {
                complete()
                return
            }
            fail(error?.localizedDescription)
        }
    }
    
    //创建一个相册
    /// - Parameters:
    ///   - title: 相册的名称
    ///   - photos: 同时添加进相册的默认图片
    ///   - complete: 完成
    ///   - fail: 失败
    func add(customGroupNamed title:String,including photos:[PHAsset],complete:@escaping(()->Void),fail:@escaping((String?) -> Void)) {
        photoLibrary.performChanges({
            
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
            
            //添加图片资源
            request.addAssets(photos as NSFastEnumeration)
            
        }) { (success, error) in
            
            if success == true {
                
                complete()
                return
            }
            
            fail(error?.localizedDescription)
            
        }
    }
    
    /// 检测是否存在同名相册,如果存在返回第一个同名相册
    ///
    /// - Parameters:
    ///   - title: 相册的名称
    ///   - result: 如果存在返回第一个同名相册
    func check(groupnamed title:String,result closure:@escaping((Bool,PHAssetCollection)-> Void)) {
        LFPhotoHandleManager.resultToArray(PHCollection.fetchTopLevelUserCollections(with: PHFetchOptions()) as! PHFetchResult<AnyObject>) { (topLevelArray, result) in
            var isExist = false
            var isExistCollection:PHAssetCollection?
            //开始遍历
            for i in 0 ..< topLevelArray.count
            {
                
                if topLevelArray[i].localizedDescription == title
                {
                    isExist = true
                    isExistCollection = (topLevelArray[i] as! PHAssetCollection)
                    break
                }
            }
            
            closure(isExist,isExistCollection!)
        }
    }
}

// MARK: - 对照片的处理
extension LFPhotoStore {
    /// 向组对象中添加image对象
    ///
    /// - Parameters:
    ///   - image: 添加的image
    ///   - collection: 组
    ///   - completeHandle: 完成
    ///   - fail: 失败
    func add(_ image:UIImage, to collection:PHAssetCollection,completeHandle:@escaping(()-> Void),fail:@escaping((_ error:String)-> Void))
    {
        photoLibrary.performChanges({
            
            if collection.canPerform(PHCollectionEditOperation.addContent)
            {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                
                let groupRequest = PHAssetCollectionChangeRequest(for: collection)
                
                groupRequest?.addAssets([request.placeholderForCreatedAsset!] as NSFastEnumeration)
            }
            
        }) { (success, error) in
            
            if success == true
            {
                completeHandle(); return
            }
            
            fail((error?.localizedDescription)!)
        }
    }
    
    
    
    
    /// 向组对象中添加image对象
    ///
    /// - Parameters:
    ///   - path: image对象的路径
    ///   - collection: 组
    ///   - completeHandle: 完成
    ///   - fail: 失败
    func add(imageAtPath path:String,to collection:PHAssetCollection,completeHandle:@escaping(()-> Void),fail:@escaping((_ error:String)-> Void))
    {
        let image = UIImage(contentsOfFile: path)
        
        add(image!, to: collection, completeHandle: completeHandle, fail: fail)
    }
    
    
    
}

    
    
    
    
    
    
    
    
    
    

