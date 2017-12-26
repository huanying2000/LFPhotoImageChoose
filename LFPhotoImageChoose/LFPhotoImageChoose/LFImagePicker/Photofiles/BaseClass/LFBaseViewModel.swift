//
//  LFBaseViewModel.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit

typealias LFShouldDismissClosure  = (() -> Void)
typealias LFShouldAlertToWarningClosure = ((Bool,UInt) -> Void)

//基础的ViewModel
class LFBaseViewModel: NSObject {
    //选择图片达到最大上限 需要提示
    var warningClosure:LFShouldAlertToWarningClosure?
    
    var dismissClosure: LFShouldDismissClosure?
    
    //选择图片完成
    func photoDidSelectedComplete() {
        dismissClosure?()
    }

}
