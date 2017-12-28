//
//  ViewController.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func chooseImage(_ sender: Any) {
        //获得控制器
        let viewController : LFPhotoNavigationViewController = LFPhotoNavigationViewController()
        
        //设置viewModel属性
        let viewModel = viewController.viewModel
        
        // 获得图片
        viewModel.completeUsingImage = {(images) in
            
           print("得到的照片  \(images)")
        }
        
        // 获得资源的data数据
        viewModel.completeUsingData = {(datas) in
            
            //coding for data ex: uploading..
            print("data = \(datas)")
        }
        
        
        
        self.present(viewController, animated: true) {}
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

