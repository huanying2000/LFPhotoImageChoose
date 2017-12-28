//
//  LFPhotosCell.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/27.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit

typealias LFPhotoCellOperationClosure = ((LFPhotosCell) -> Void)

let lf_deselectedImage = UIImage(named: "photoUnSelected")
let lf_selectedImage  = UIImage(named: "photoSelected")

//选择图片的cell
class LFPhotosCell: UICollectionViewCell {
    //control 对象点击的闭包
    var chooseImageDidSelectHandle: LFPhotoCellOperationClosure?
    
    //显示图片的背景图片
    lazy var lf_imageView : UIImageView = {
        
        var imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    /// 显示信息的视图，比如视频的时间长度，默认hidden = true
    lazy var lf_messageView : UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .black
        return view
        
    }()
    
    /// 显示在lf_messageView上显示时间长度的标签
    lazy var lf_messageLabel : UILabel = {
        
        var messageLabel = UILabel()
        messageLabel.font = .systemFont(ofSize: 11)
        messageLabel.textColor = .white
        messageLabel.textAlignment = .right
        messageLabel.text = "00:25"
        
        return messageLabel
        
    }()
    
    /// 模拟显示选中的按钮
    lazy var lf_chooseImageView : UIImageView = {
        
        var chooseImageView = UIImageView()
        chooseImageView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        chooseImageView.layer.cornerRadius = 25 / 2.0
        chooseImageView.clipsToBounds = true
        chooseImageView.image = lf_deselectedImage
        
        return chooseImageView
        
    }()
    
    //模拟响应选中状态的control对象
    lazy var lf_chooseControl:UIControl = {
        var chooseControl = UIControl()
        chooseControl.backgroundColor = .clear
        chooseControl.action(at: .touchUpInside, handle: { [weak self] (sender) in
            let strongSelf = self
            //响应选择回调
            strongSelf?.chooseImageDidSelectHandle?(strongSelf!)
        })
        return chooseControl
    }()
    
    override init(frame: CGRect){
        
        super.init(frame: frame)
        addAndLayoutSubViews()
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        addAndLayoutSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// cell进行点击
    ///
    /// - Parameter isSelected: 当前选中的状态
    func selected(_ isSelected:Bool)
    {
        lf_chooseImageView.image = !isSelected ? lf_deselectedImage : lf_selectedImage
        
        if isSelected {
            
            animatedForSelected()
        }
    }
    
    /// 选中动画
    fileprivate func animatedForSelected()
    {
        UIView.animate(withDuration: 0.2, animations: {
            
            self.lf_chooseImageView.transform = CGAffineTransform(scaleX: 1.2,y: 1.2)
            
        }) { (finish) in
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.lf_chooseImageView.transform = CGAffineTransform.identity
                
            })
        }
    }
    
    override func prepareForReuse() {
        
        lf_imageView.image = nil
        lf_chooseImageView.isHidden = false
        lf_messageView.isHidden = true
        lf_messageLabel.text = nil
        lf_chooseImageView.image = lf_deselectedImage
    }
    
    fileprivate func addAndLayoutSubViews(){
        
        // subviews
        self.contentView.addSubview(lf_imageView)
        self.contentView.addSubview(lf_messageView)
        self.contentView.addSubview(lf_chooseControl)
        lf_chooseControl.addSubview(lf_chooseImageView)
        lf_messageView.addSubview(lf_messageLabel)
        
        //layout
        lf_imageView.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
            
        }
        
        lf_chooseControl.snp.makeConstraints { (make) in
            
            make.width.height.equalTo(45)
            make.right.bottom.equalToSuperview().inset(3)
            
        }
        
        lf_chooseImageView.snp.makeConstraints { (make) in
            
            make.width.height.equalTo(25)
            make.right.bottom.equalToSuperview()
            
        }
        
        
        lf_messageView.snp.makeConstraints {(make) in
            
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
            
        }
        
        lf_messageLabel.snp.makeConstraints { [weak self](make) in
            
            let strongSelf = self
            
            make.left.equalTo(strongSelf!.lf_messageView.snp.left)
            make.right.equalTo(strongSelf!.lf_messageView).inset(3)
            make.bottom.equalTo(strongSelf!.lf_messageView)
            make.height.equalTo(20)
        }
    }
    
}
