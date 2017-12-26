//
//  LFPhotoBridgeManager.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import Photos

//进行桥接 进行回调的manager
class LFPhotoBridgeManager: NSObject {

    //单例对象
    static let sharedInstance = LFPhotoBridgeManager()
    
    //获取图片之后的闭包
    var completeUsingImage:(([UIImage]) ->Void)?
    //获取图片数据之后的闭包
    var completeUsingData:(([Data]) ->Void)?
    
    
    //开始获取图片以及数据
    func start(renderFor assets:[PHAsset]) {
        let size = LFPhotoCacheManager.sharedInstance.imageSize
        //如果是原图 忽略size
        let isIgnore = size.width < 0
        
        //是否为高清图
        let isHightQuarity = LFPhotoCacheManager.sharedInstance.isHightQuarity
    }
    
}
