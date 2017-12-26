//
//  LFPhotoConfig.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit

class LFPhotoConfig: NSObject {
    //默认配置项 如下
    static var groupNames: [String] = [
        NSLocalizedString(ConfigurationCameraRoll, comment: ""),
        NSLocalizedString(ConfigurationAllPhotos, comment: ""),
        NSLocalizedString(ConfigurationSlo_mo, comment: ""),
        NSLocalizedString(ConfigurationScreenshots, comment: ""),
        NSLocalizedString(ConfigurationVideos, comment: ""),
        NSLocalizedString(ConfigurationPanoramas, comment: ""),
        NSLocalizedString(ConfigurationRecentlyAdded, comment: ""),
        NSLocalizedString(ConfigurationSelfies, comment: "")]
    
    /// 获得的配置选项
    var groups : [String]{
        
        get{
            return LFPhotoConfig.groupNames
        }
        
    }
    
    
    override init()
    {
        super.init()
    }
    
    convenience init(groupnames:[String]!)
    {
        self.init()
        
        LFPhotoConfig.groupNames = groupnames
        //本地化
        localizeHandle()
        
    }
    
    //本地化语言处理
    func localizeHandle() {
        let localizedHandle = LFPhotoConfig.groupNames
        let finalHandle = localizedHandle.map { (configurationName) -> String in
            return NSLocalizedString(configurationName, comment: "")
        }
        LFPhotoConfig.groupNames = finalHandle
    }
    
    
    
}
