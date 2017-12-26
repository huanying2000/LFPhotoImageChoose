//
//  LFPhotoNavigationViewController.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit

//进入控制器的主导航控制器
class LFPhotoNavigationViewController: UINavigationController {

    var viewModel:LFPhotoNavigationViewModel = LFPhotoNavigationViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.viewControllers =
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    deinit {
        print("\(self.self)deinit")
    }
    

}
