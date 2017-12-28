//
//  LFPhotoGroupViewController.swift
//  LFPhotoImageChoose
//
//  Created by ios开发 on 2017/12/27.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import Photos

let cellIdentifier = "LFPhotoGroupCell"

class LFPhotoGroupViewController: UITableViewController {

    
    var viewModel:LFPhotoGroupViewModel = LFPhotoGroupViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化tableView 的相关属性
        tableView.tableFooterView = UIView()
        tableView.register(LFPhotoGroupCell.self, forCellReuseIdentifier: cellIdentifier)
        
        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: viewModel, action: #selector(viewModel.dismiss))
        bindViewModel()
        
        //开始获取照片
        viewModel.fetchDefaultGroups()
    }

    
    fileprivate func bindViewModel() {
        viewModel.dismissClosure = { [weak self] in
            let strongSelf = self
            strongSelf?.dismiss(animated: true, completion: nil)
        }
        
        viewModel.fetchGroupsCompletion = { [weak self] (groups:id) in
            let strongSelf = self
            strongSelf?.tableView.reloadData()
            //跳入第一个
            strongSelf?.lf_tableView((strongSelf?.tableView)!, didSelectRowAt: IndexPath(row: 0, section: 1), animated: false)
        }
        
        
        viewModel.selectedCompletion = { [weak self] (collection,indexPath,animated) in
            let strongSelf = self
            
            //跳转viewController
            let viewController = LFPhotosViewController()
            
            //viewController的viewModel
            let viewModel = viewController.viewModel
            
            //设置标题
            viewModel.navigationTitle = (collection as! PHAssetCollection).localizedTitle!
            viewModel.assetCollection = (collection as! PHAssetCollection)
            
            strongSelf?.navigationController?.pushViewController(viewController, animated: animated)
        }
        
    }
    
    
    
    
    //跳转 触发viewModel.selectedCompletion
    fileprivate func lf_tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath, animated:Bool) {
        viewModel.groupViewModel(lf_didSelectRowAt: indexPath, animated: animated)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return viewModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.tableView(section)
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(viewModel.tableViewModel(heightForCellRowAt: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LFPhotoGroupCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LFPhotoGroupCell
        viewModel.loadGroupMessage(At: indexPath) { (title, image, realTime, count) in
            cell.lf_titleLabel?.text = (realTime as! String)
            cell.lf_imageView?.image = (image as! UIImage)
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //消除痕迹
        tableView.deselectRow(at: indexPath, animated: false)
        lf_tableView(tableView, didSelectRowAt: indexPath, animated: true)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
