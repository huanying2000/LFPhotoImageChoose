//
//  LFPublicViewModel.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import Foundation


@objc protocol LFPublicViewModel: NSObjectProtocol {
    
    //当前控制器的导航标题
    @objc optional var title:String {get}
    
}
