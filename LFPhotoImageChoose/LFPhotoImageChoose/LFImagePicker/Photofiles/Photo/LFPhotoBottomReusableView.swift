//
//  LFPhotoBottomReusableView.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/27.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit

class LFPhotoBottomReusableView: UICollectionReusableView {
    /// 资源的数目
    var lf_numberOfAsset = 0 {
        
        willSet{
            
            self.lf_assetLabel.text = "共有\(newValue)张照片"
        }
    }
    
    
    /// 在标签上的自定义文字
    var lf_customText = "" {
        
        willSet{
            
            self.lf_assetLabel.text = newValue
        }
    }
    
    
    /// 显示title的标签
    var lf_assetLabel : UILabel = {
        
        var assetLabel = UILabel()
        
        assetLabel.font = .systemFont(ofSize: 14)
        assetLabel.textAlignment = .center
        //        assetLabel.textColor = .colorValue(with: 0x6F7179)
        assetLabel.textColor = 0x6F7179.lf_color
        
        return assetLabel
    }()
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        layoutOwnSubviews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        layoutOwnSubviews()
    }
    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        lf_customText = ""
    }
    
    
    // MARK: private
    
    fileprivate func layoutOwnSubviews()
    {
        self.addSubview(lf_assetLabel)
        
        //layout
        lf_assetLabel.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
        }
    }
}
