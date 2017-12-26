//
//  LFPhotoGroupCell.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit


class LFPhotoGroupCell: UITableViewCell {

    //显示图片的ImageView
    var lf_imageView: UIImageView?
    
    //分组名称
    var lf_titleLabel:UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        photoGroupCellWillLoad()
    }
    
    
    
    
    fileprivate func photoGroupCellWillLoad() {
        addlf_imageView()
        addlf_titleLable()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoGroupCellWillLoad()
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.lf_imageView?.image = nil
        self.lf_titleLabel?.text = ""
    }
    
    
    func addlf_imageView()
    {
        lf_imageView = UIImageView()
        lf_imageView?.contentMode = .scaleAspectFill
        lf_imageView?.clipsToBounds = true
        
        contentView.addSubview(lf_imageView!)
        
        lf_imageView?.snp.makeConstraints({ (make) in
            
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
            make.width.equalTo((lf_imageView?.snp.height)!)
        })
    }
    
    
    func addlf_titleLable()
    {
        lf_titleLabel = UILabel()
        lf_titleLabel?.font = .systemFont(ofSize: 15)
        
        contentView.addSubview(lf_titleLabel!)
        
        lf_titleLabel?.snp.makeConstraints({ (make) in
            
            make.centerY.equalTo(contentView.snp.centerY)
            make.left.equalTo((lf_imageView?.snp.right)!).offset(10)
            make.right.equalToSuperview().inset(10)
            
        })
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
