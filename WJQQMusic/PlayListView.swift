//
//  PlayListView.swift
//  WJQQMusic
//
//  Created by jh navi on 15/9/16.
//  Copyright (c) 2015年 WJ. All rights reserved.
//

import UIKit

class PlayListView: UIView,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var tableData:NSArray=NSArray()//列表数据
    var viewContorller:ViewController=ViewController()//父控制器


    //显示
    func showPlayListView(){
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        //动画从下向上进入
        var vbFrame:CGRect = self.viewBackground.frame
        vbFrame.origin.y=vbFrame.origin.y+vbFrame.size.height
        self.viewBackground.frame=vbFrame
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            var vbFrame:CGRect = self.viewBackground.frame
            vbFrame.origin.y=vbFrame.origin.y-vbFrame.size.height
            self.viewBackground.frame=vbFrame
            //背景加模糊特效
            let blurEffect=UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blureView=UIVisualEffectView(effect: blurEffect)
            blureView.frame = self.viewBackground.frame;
            self.viewBackground=blureView
        });
    }
    
    //关闭
    @IBAction func closePlayListView(sender: AnyObject) {
        self.removeFromSuperview()
    }
  
    /**
     * UITableViewDelegate
     **/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("tableData = %@", tableData)
        return tableData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //定义cell
        let cell=UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "douban")
        cell.backgroundColor=UIColor.clearColor()
        //当前行数据
        let rowSong:Song=self.tableData[indexPath.row] as! Song
        //行显示内容
        cell.textLabel?.text = rowSong.title as String
        cell.textLabel?.font=UIFont(name: "宋体", size: 14.0)
        if indexPath.row == self.viewContorller.currentIndex {
            cell.textLabel?.textColor = UIColor.greenColor()
        }else{
            cell.textLabel?.textColor=UIColor.whiteColor()
        }
        cell.detailTextLabel?.text=rowSong.artist as String
        cell.detailTextLabel?.font=UIFont(name:"宋体", size: 8.0)
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowSong:Song=self.tableData[indexPath.row] as! Song
        viewContorller.setMyCurrentSong(rowSong)
        self.removeFromSuperview()
    }
}
