//
//  LFPhotoPreviewController.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/28.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import Photos

class LFPhotoPreviewController: UIViewController {

    /// 当前显示的资源对象
    var showAsset : PHAsset = PHAsset()
    
    
    /// 展示图片的视图
    lazy fileprivate var imageView : UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 8.0
        
        return imageView
    }()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //获得资源的宽度与高度的比例
        let scale = CGFloat(showAsset.pixelHeight) * 1.0 / CGFloat(showAsset.pixelWidth)
        
        preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.width * scale)
        
        //添加
        view.addSubview(imageView)
        
        //约束布局
        imageView.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
        }
        
        //获取图片对象
        LFPhotoHandleManager.asset(representionIn: showAsset, size: preferredContentSize) { (image, asset) in
            
            self.imageView.image = image
            
        }
    }

    

    

}
