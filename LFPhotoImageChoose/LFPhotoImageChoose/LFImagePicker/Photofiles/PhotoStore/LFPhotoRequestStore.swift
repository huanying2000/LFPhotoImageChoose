//
//  LFPhotoRequestStore.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/27.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import Photos

//负责请求图片对象
class LFPhotoRequestStore: NSObject {
    /// 获取资源中的图片对象
    ///
    /// - Parameters:
    ///   - assets: 需要请求的asset数组
    ///   - isHight: 图片是否需要高清图
    ///   - size:  当前图片的截取size
    ///   - ignoreSize: 是否无视size属性，按照图片原本大小获取
    ///   - completion: 返回存放images的数组
    static func startRequestImage(imagesIn assets:[PHAsset],isHight:Bool,size:CGSize,ignoreSize:Bool,completion:@escaping (([UIImage]) ->())) {
        var images = [UIImage]()
        var newSize = size
        
        for i in 0 ..< assets.count {
            //获取资源
            let asset = assets[i]
            //重置大小
            if ignoreSize {
                newSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            }
            //图片类型
            let model = isHight ? PHImageRequestOptionsDeliveryMode.highQualityFormat : PHImageRequestOptionsDeliveryMode.fastFormat
            
            //初始化option
            let option = PHImageRequestOptions()
            option.deliveryMode = model
            option.isSynchronous = true
            //开始请求
            PHImageManager.default().requestImage(for: asset, targetSize: newSize, contentMode: PHImageContentMode.aspectFill, options: option, resultHandler: { (image, info) in
                //添加
                images.append(image!)
                
                if images.count == assets.count {
                    
                    completion(images)
                }
            })
        }
    }
    
    
    
    
    
    
    /// 获取资源中图片的数据对象
    /// - Parameters:
    ///   - assets: 需要请求的asset数组
    ///   - isHight: 图片是否需要高清图
    ///   - completion: 返回存放images的数组
    static func startRequestData(imagesIn assets:[PHAsset],isHight:Bool,completion:@escaping (([Data]) ->())) {
        var datas = [Data]()
        for i in 0 ..< assets.count {
            let asset = assets[i]
            let model = isHight ? PHImageRequestOptionsDeliveryMode.highQualityFormat : PHImageRequestOptionsDeliveryMode.fastFormat
            //初始化 请求条件
            let option = PHImageRequestOptions()
            option.deliveryMode = model
            option.isSynchronous = true
            
            //请求数据
            PHImageManager.default().requestImageData(for: asset, options: option, resultHandler: { (data, dataUTI, orientation, info) in
                datas.append(data!)
                if datas.count == assets.count {
                    completion(datas)
                }
            })
        }
    }
    
    
}
