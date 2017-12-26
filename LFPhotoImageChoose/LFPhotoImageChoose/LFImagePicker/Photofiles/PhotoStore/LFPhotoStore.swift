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
    
    
    // MARK: fetch
    
    /// 获取photos提供的所有的智能分类相册组，与config属性无关
    ///
    /// - Parameter groups: 图片组对象
    func fetch(groups: @escaping ([PHAssetCollection]) -> Void) ->Void {
        
    }
    
    
    
    
    
    //获取最基本的智能分组
    private func lf_fetchBasePhotosGroup(complete: @escaping (PHFetchResult<PHAssetCollection>?) ->Void) {
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
