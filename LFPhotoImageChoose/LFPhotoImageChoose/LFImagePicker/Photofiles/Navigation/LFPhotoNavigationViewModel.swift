//
//  LFPhotoNavigationViewModel.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit

let LFPhotoOriginSize:CGSize = CGSize(width: -100, height: -100)

//主导航控制器的ViewModel
class LFPhotoNavigationViewModel: LFBaseViewModel {
    var maxNumberOfSelectedPhoto = 9 {
        willSet {
            guard newValue > 0 else {
                return
            }
            
            LFPhotoCacheManager.sharedInstance.maxNumeberOfSelectedPhoto = newValue
        }
    }
    
    //当前图片的规格 默认为LFPhotoOriginSize，原始比例
    var imageSize = LFPhotoOriginSize {
        willSet {
            LFPhotoCacheManager.sharedInstance.imageSize = newValue
        }
    }
    
    //获取图片之后的闭包
    var completeUsingImage:(([UIImage])->Void)? {
        willSet {
            LFPhotoBridgeManager.sharedInstance.completeUsingImage = newValue
        }
    }
    
    //获取图片数据之后的闭包
    var completeUsingData:(([Data]) ->Void)? {
        willSet {
            LFPhotoBridgeManager.sharedInstance.completeUsingData = newValue
        }
    }
    
    
    deinit {
        print("\(self.self)deinit")
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
