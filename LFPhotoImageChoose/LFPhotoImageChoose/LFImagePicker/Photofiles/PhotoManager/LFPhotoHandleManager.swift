//
//  LFPhotoHandleManager.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import Photos
import ObjectiveC

//进行数据处理的类
class LFPhotoHandleManager: NSObject {

    //用于描述runtime的关联属性
    struct LFPhotoAssociate {
        static let lf_assetCollectionAssociate = UnsafeRawPointer(bitPattern: "lf_assetCollection".hashValue)
        static let lf_cacheAssociate = UnsafeRawPointer(bitPattern: "lf_CacheAssociate".hashValue)
        static let lf_assetCacheSizeAssociate = UnsafeRawPointer(bitPattern:"lf_assetCacheSizeAssociate".hashValue)
    }
    /// PHFetchResult对象转成数组的方法 类似数组，存储获取到asset对象集合。
    ///
    /// - Parameters:
    ///   - result: 转型的fetchResult对象
    ///   - complete: 完成的闭包
    public static func resultToArray(_ result:PHFetchResult<AnyObject>,complete:@escaping ([AnyObject],PHFetchResult<AnyObject>) -> Void) {
        guard result.count != 0 else {
            complete([],result)
            return
        }
        
        var array = [AnyObject]()
        //开始遍历
        result.enumerateObjects { (object, index, stop) in
            array.append(object)
            if index == result.count - 1 {
                complete(array,result)
            }
        }
    }
    
    //获取选择图片的数组
    /// - Parameters:
    ///   - allAssets: 所有的资源数组
    ///   - status: 选中状态
    /// - Returns:
    public static func assets(_ allAssets:[PHAsset],status:[Bool]) -> [PHAsset] {
        var assethandle = [PHAsset]()
        for i in 0..<allAssets.count {
            let status = status[i]
            if status {
                assethandle.append(allAssets[i])
            }
        }
        return assethandle
    }
    
    // 获取PHAssetCollection 的详细信息
    /// - Parameters:
    ///   - size: 获得封面图片的大小
    ///   - completion: 取组的标题、照片资源的预估个数以及封面照片,默认为最新的一张
    public static func assetCollection(detailInformationFor collection:PHAssetCollection,size:CGSize,completion:@escaping ((String?,UInt,UIImage?) ->Void)) {
        let assetResult = PHAsset.fetchAssets(in: collection, options: PHFetchOptions())
        if assetResult.count == 0 {
            completion(collection.localizedTitle,0,UIImage())
            return
        }
        
        let image:UIImage? = ((objc_getAssociatedObject(collection, LFPhotoHandleManager.LFPhotoAssociate.lf_assetCollectionAssociate!)) as? UIImage)
        if image != nil {
            completion(collection.localizedTitle,UInt(assetResult.count),image)
            return
        }
        
        //重新获取图片
        let scale = UIScreen.main.scale
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        PHCachingImageManager.default().requestImage(for: assetResult.lastObject!, targetSize: newSize, contentMode: PHImageContentMode.aspectFill, options: nil) { (realImage, info) in
            completion(collection.localizedTitle,UInt(assetResult.count),realImage)
        }
        
    }
    
    //获取PHAsset的照片资源
    /// - Parameters:
    ///   - asset: 获取资源的对象
    ///   - size: 截取图片的大小
    ///   - completion: 获取的图片，以及当前的资源对象
    public static func asset(representionIn asset:PHAsset,size:CGSize,completion:@escaping ((UIImage,PHAsset) ->Void)) {
        if objc_getAssociatedObject(asset, LFPhotoHandleManager.LFPhotoAssociate.lf_cacheAssociate!) == nil {
            
            objc_setAssociatedObject(asset, LFPhotoHandleManager.LFPhotoAssociate.lf_cacheAssociate!, [CGSize](), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        var caches : [CGSize] = objc_getAssociatedObject(asset, LFPhotoHandleManager.LFPhotoAssociate.lf_cacheAssociate!) as! [CGSize]
        
        let scale = UIScreen.main.scale
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        //开始请求
        PHCachingImageManager.default().requestImage(for: asset, targetSize: newSize, contentMode: PHImageContentMode.aspectFill, options: PHImageRequestOptions()) { (image, info) in
            
            completion(image!,asset)
            
        }
        //进行缓存
        if !caches.contains(newSize) {
            
            (PHCachingImageManager.default() as! PHCachingImageManager).startCachingImages(for: [asset], targetSize: newSize, contentMode: PHImageContentMode.aspectFill, options: PHImageRequestOptions())
            
            caches.append(newSize)
            
            //重新赋值
            objc_setAssociatedObject(asset, LFPhotoHandleManager.LFPhotoAssociate.lf_cacheAssociate!, caches, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    //获取PHAsset的高清图片资源
    /// - Parameters:
    ///   - asset: 获取资源的对象
    ///   - size: 获取图片的大小
    ///   - completion: 完成
    public static func asset(hightQuarityFor asset:PHAsset,Size size:CGSize,completion:@escaping ((String)->Void)) {
        let newSize = size
        if objc_getAssociatedObject(asset, LFPhotoAssociate.lf_assetCacheSizeAssociate!) == nil {
            
            let associateData = Dictionary<String, Any>()
            
            objc_setAssociatedObject(asset, LFPhotoAssociate.lf_assetCacheSizeAssociate!, associateData, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        /// 获得当前所有的存储
        var assicciateData : Dictionary<String, Any> = objc_getAssociatedObject(asset, LFPhotoAssociate.lf_assetCacheSizeAssociate!) as! Dictionary <String, Any>
        guard assicciateData.index(forKey: NSStringFromCGSize(newSize)) == nil else {
            let index = assicciateData.index(forKey: NSStringFromCGSize(newSize))//获得索引
            let size = assicciateData[index!].value as! String//获得数据
            
            completion(size)
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        //请求数据
        PHCachingImageManager.default().requestImageData(for: asset, options: options) { (data, dataUTI, orientation, info) in
            let size = data?.count.lf_dataSize
            //新增值
            assicciateData.updateValue(size!, forKey: NSStringFromCGSize(newSize))
            //缓存
            objc_setAssociatedObject(asset, LFPhotoAssociate.lf_assetCacheSizeAssociate!, assicciateData, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            completion(size!)
        }
    }
    
    
    //获取PHFetchResult符合媒体类型的PHAsset 对象
    /// - Parameters:
    ///   - result: 获取数据的对象
    ///   - type: 媒体类型
    ///   - enumerateObject: 每次获得符合媒体类型的对象调用一次
    ///   - matchedObject: 每次都会调用一次
    ///   - completion: 完成之后返回存放符合媒体类型的PHAsset数组
    public static func fetchResult(in result:PHFetchResult<PHAsset>,type:PHAssetMediaType,enumerateObject:((PHAsset) -> Void)?,matchedObject:((PHAsset) -> Void)?,completion:(([PHAsset]) -> Void)?) {
        var assets = [PHAsset]()
        //如果当前没有数据
        guard result.count >= 0 else {
            completion?(assets)
            return
        }
        
        //开始遍历
        result.enumerateObjects { (obj, idx, stop) in
            enumerateObject?(obj)
            if obj.mediaType == type {
                matchedObject?(obj)
                assets.append(obj)
            }
            if idx == result.count - 1 { // 说明完成
                
                completion?(assets)
            }
        }
        
    }
    
    
    /// 获取PHFetchResult符合媒体类型的PHAsset对象
    ///
    /// - Parameters:
    ///   - result: 获取资源的对象
    ///   - type: 媒体类型
    ///   - completion: 完成之后返回存放符合媒体类型的PHAsset数组
    public static func fetchResult(in result:PHFetchResult<PHAsset>,type:PHAssetMediaType,completion:(([PHAsset]) -> Void)?) {
        fetchResult(in: result, type: type, enumerateObject: nil, matchedObject: nil, completion: completion)
    }
    
    
    //获取选择的资源数组
    /// - Parameters:
    ///   - assets: 存放资源的数组
    ///   - status: 对应资源的选中状态数组
    /// - Returns: 筛选完毕的数组
    public static func filter(assetsIn assets:[PHAsset], status:[Bool]) -> [PHAsset]
    {
        var assetHandle = [PHAsset]()
        
        for asset in assets {
            
            //如果状态为选中
            if status[assets.index(of: asset)!] {
                
                assetHandle .append(asset)
            }
        }
        
        return assetHandle
    }
    
}
