//
//  LFPhotoEctension.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/26.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

struct LFPhotosAssociate {
    static let LF_ControlHandleValue = UnsafeRawPointer(bitPattern: "LF_ControlHandleValue".hashValue)
    static let LF_GestureHandleValue = UnsafeRawPointer(bitPattern: "LF_GestureHandleValue".hashValue)
}

extension UIColor {
    //生成图片
    public var lf_image:UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
extension Int {
    //将数据大小变为字符串
    public var lf_dataSize:String {
        guard self > 0 else {
            return ""
        }
        
        let unit = 1024.0
        guard Double(self) < unit * unit else {
            return String(format:"%.1fMB",Double(self) / unit / unit)
        }
        guard Double(self) < unit else {
            
            return String(format:"%.0fKB",Double(self) / unit)
        }
        return "\(self)B"
    }
}

/// 16进制数值获得颜色
public var lf_color : UIColor {
    
    guard self > 0 else {
        
        return UIColor.white
    }
    
    let red = (CGFloat)((self & 0xFF0000) >> 16) / 255.0
    let green = (CGFloat)((self & 0xFF00) >> 8) / 255.0
    let blue = (CGFloat)((self & 0xFF)) / 255.0
    
    
    if #available(iOS 10, *)
    {
        return UIColor(displayP3Red:red , green: green, blue: blue, alpha: 1.0)
    }
    
    guard #available(iOS 10, *) else {
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    return UIColor.black
}

extension TimeInterval {
    
    /// 将时间戳转换为当前的总时间，格式为00:00:00
    public var lf_time : String {
        
        let time : UInt = UInt(self)
        
        guard time < 60 * 60 else {
            
            let hour = String(format: "%.2d",time / 60 / 60)
            let minute = String(format: "%.2d",time % 3600 / 60)
            let second = String(format: "%.2d",time % (3600 * 60))
            
            return "\(hour):\(minute):\(second)"
        }
        
        
        guard time < 60 else {
            
            let minute = String(format:"%.2d",time / 60)
            let second = String(format:"%.2d",time % 60)
            
            return "\(minute):\(second)"
        }
        
        
        return "00:\(String(format:"%.2d",time))"
    }
}


typealias LFControlActionClosure = ((UIControl) -> Void)


extension UIControl {
    
    func action(at state:UIControlEvents,handle:LFControlActionClosure? ) {
        guard let actionHandle = handle else {
            return
        }
        
        objc_setAssociatedObject(self, LFPhotosAssociate.LF_ControlHandleValue, actionHandle, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.addTarget(self, action: #selector(UIControl.lf_actionHandle), for: state)
    }
    
    @objc fileprivate func lf_actionHandle() {
        guard let actionhandle = objc_getAssociatedObject(self, LFPhotosAssociate.LF_ControlHandleValue) else {
            return
        }
        
        (actionhandle as! LFControlActionClosure)(self)
    }

}

typealias LFGestureClosure = ((UIGestureRecognizer) -> Void)

extension UIGestureRecognizer
{
    
    /// 用于替代目标动作回调的方法
    ///
    /// - Parameter handle: 执行的闭包
    func action(_ handle:RITLGestureClosure?)
    {
        guard let handle = handle else {
            
            return
        }
        
        //缓存
        objc_setAssociatedObject(self, LFPhotosAssociate.LF_GestureHandleValue, handle, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        //添加
        self.addTarget(self, action: #selector(UIGestureRecognizer.lf_actionHandle))
    }
    
    
    @objc fileprivate func lf_actionHandle()
    {
        //执行
        (objc_getAssociatedObject(self, LFPhotosAssociate.LF_GestureHandleValue) as! RITLGestureClosure)(self)
        
    }
}


extension UIViewController
{
    
    /// 弹出alert控制器
    ///
    /// - Parameter count: 限制的数目
    func present(alertControllerShow count:UInt)
    {
        let alertController = UIAlertController(title: ("你最多可以选择\(count)张照片"), message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        
        present(alertController, animated: true, completion: nil)
    }
}




