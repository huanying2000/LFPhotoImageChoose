//
//  LFPhotoBrowseCell.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/28.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit

class LFPhotoBrowseCell: UICollectionViewCell {
    //显示图片的ImageView
    lazy var lf_imageView : UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    //单击图片执行的闭包
    var lf_photoBrowerSimpleTapHandle:((id) -> Void)?
    
    //是否已经缩放
    fileprivate var isScale = false
    
    /// 最小缩放比例
    fileprivate let minScaleZoome = 1.0
    
    /// 最大缩放比例
    fileprivate let maxScaleZoome = 2.0
    
    //底部负责缩放的滚动视图
    lazy var lf_scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.black
        scrollView.minimumZoomScale = CGFloat(self.minScaleZoome)
        scrollView.maximumZoomScale = CGFloat(self.maxScaleZoome)
        scrollView.delegate = self
        return scrollView
    }()
    
    //单击手势
    lazy fileprivate var lf_simpleTap : UITapGestureRecognizer = {
        let simpleTap = UITapGestureRecognizer()
        
        simpleTap.numberOfTapsRequired = 1
        simpleTap.require(toFail: self.lf_doubleTap)
        //设置响应
        simpleTap.action({ [weak self] (sender) in
            let strongSelf = self
            //执行闭包
            strongSelf?.lf_photoBrowerSimpleTapHandle?(strongSelf! as id )
            /********** 此处不再返回原始比例，如需此功能，请清除此处注释 2017-01-20 ***********/
            /*
             if strongSelf!.lf_scrollView.zoomScale != 1.0 {
             
             strongSelf!.lf_scrollView.setZoomScale(1.0, animated: true)
             }
             */
            /*************************************************************************/
        })
        return simpleTap
    }()
    
    lazy fileprivate var lf_doubleTap : UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer()
        
        doubleTap.numberOfTapsRequired = 2
        
        doubleTap.action({ [weak self](sender) in
            
            let strongSelf = self
            
            //表示需要缩放成1.0
            guard strongSelf!.lf_scrollView.zoomScale == 1.0 else {
                
                strongSelf!.lf_scrollView.setZoomScale(1.0, animated: true); return
            }
            
            //进行放大
            let width = strongSelf!.frame.width
            let scale = width / CGFloat(strongSelf!.maxScaleZoome)
            let point = sender.location(in: strongSelf!.lf_imageView)
            
            //对点进行处理
            let originX = max(0, point.x - width / scale)
            let originY = max(0, point.y - width / scale)
            
            //进行位置的计算
            let rect = CGRect(x: originX, y: originY, width: width / scale, height: width / scale)
            
            //进行缩放
            strongSelf!.lf_scrollView.zoom(to: rect, animated: true)
            
        })
        
        return doubleTap
    }()
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addAndLayoutSubViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        addAndLayoutSubViews()
    }
    
    
    fileprivate func addAndLayoutSubViews()
    {
        contentView.addSubview(lf_scrollView)
        
        lf_scrollView.addSubview(lf_imageView)
        lf_scrollView.addGestureRecognizer(lf_simpleTap)
        lf_scrollView.addGestureRecognizer(lf_doubleTap)
        
        //layout
        lf_scrollView.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(0, 5, 0, 5))
            
        }
        
        lf_imageView.snp.makeConstraints { [weak self](make) in
            
            let strongSelf = self
            
            make.edges.equalToSuperview()
            make.width.equalTo(strongSelf!.lf_scrollView.snp.width)
            make.height.equalTo(strongSelf!.lf_scrollView.snp.height)
        }
    }
}


extension LFPhotoBrowseCell : UIScrollViewDelegate
{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return lf_imageView
    }
    
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        scrollView.setZoomScale(scale, animated: true)
    }
}
