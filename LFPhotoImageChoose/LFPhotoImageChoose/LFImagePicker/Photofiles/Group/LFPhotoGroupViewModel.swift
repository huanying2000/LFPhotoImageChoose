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
    
}
