//
//  TwoTableViewController.swift
//  TwoTableView
//
//  Created by Apple5 on 14/12/25.
//  Copyright (c) 2014年 liuwei.co. All rights reserved.
//

import UIKit

let tableview_tag_left = 1
let tableview_tag_right = 2
var calculatedLastCellHeight:CGFloat = 0 //计算出的最后cell高度

class TwoTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        self.leftTableView.tag = tableview_tag_left
        self.leftTableView.backgroundColor = UIColor.clearColor()
        self.leftTableView.tableHeaderView?.removeFromSuperview()
        self.leftTableView.tableHeaderView = nil
        self.leftTableView.dataSource = self
        self.leftTableView.delegate = self
        self.view.addSubview(self.leftTableView)
        
        self.rightTableView.tag = tableview_tag_right
        self.rightTableView.backgroundColor = UIColor.clearColor()
        self.rightTableView.tableHeaderView?.removeFromSuperview()
        self.rightTableView.tableHeaderView = nil
        self.rightTableView.dataSource = self
        self.rightTableView.delegate = self
        self.view.addSubview(self.rightTableView)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("viewDidAppear:  Lhight:\(leftTableView.contentSize.height) Rhight:\(rightTableView.contentSize.height)")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            println(1)
//            NSThread.sleepForTimeInterval(1)
//            println(2)
            var rightMaxContentOffsetY = self.rightTableView.contentSize.height-self.rightTableView.frame.size.height
            var leftReallMaxContentOffsetY = self.leftTableView.contentSize.height-self.leftTableView.frame.size.height
            var rightMaxIndexPath = self.rightTableView.indexPathForRowAtPoint(CGPointMake(0, rightMaxContentOffsetY)) as NSIndexPath!
            var rightMaxRect = self.rightTableView.rectForRowAtIndexPath(rightMaxIndexPath)
            var rightMaxSumHeight = rightMaxRect.origin.y +  rightMaxRect.height
            var rightMaxOffsetY = rightMaxSumHeight - rightMaxContentOffsetY
            var leftMaxRect = self.leftTableView.rectForRowAtIndexPath(rightMaxIndexPath)
            var leftMaxSumHeight = leftMaxRect.origin.y +  leftMaxRect.height
            var leftMaxOffsetY = leftMaxRect.height * ( rightMaxOffsetY / rightMaxRect.height)
            var leftMaxContentOffsetY = leftMaxSumHeight - leftMaxOffsetY
            println("leftReallMaxContentOffsetY:\(leftReallMaxContentOffsetY) leftMaxContentOffsetY:\(leftMaxContentOffsetY) rightMaxIndexPath.row:\(rightMaxIndexPath?.row)")
            calculatedLastCellHeight = leftMaxContentOffsetY - leftReallMaxContentOffsetY
            
            dispatch_async(dispatch_get_main_queue(), {
                println("刷新")
                self.leftTableView.reloadData()
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row)"
        if tableView.tag == tableview_tag_left
        {
            cell.backgroundColor = UIColor.orangeColor()
        }else if tableView.tag == tableview_tag_right {
            cell.backgroundColor = UIColor.grayColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView.tag == tableview_tag_left
        {
            if indexPath.row ==  39
            {
                var hh = calculatedLastCellHeight == 0 ? 60 : calculatedLastCellHeight + 60
                return   hh //1101 - 632.0 + 60
            }else{
                if indexPath.row % 2 == 0
                {
                    return 60
                }else{
                    return 120
                }
            }
        }else if tableView.tag == tableview_tag_right {
            if indexPath.row % 2 == 0
            {
                return 420
            }else{
                return 300
            }
        }
        return 0
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var sumHeight = scrollView.contentSize.height
        if sumHeight == 0
        {
            return
        }
        
        if scrollView.tag == tableview_tag_left
        {
            var  leftContentOffsetY = leftTableView.contentOffset.y
            if leftContentOffsetY < 0 {
                rightTableView.contentOffset = CGPointMake(rightTableView.contentOffset.x, leftContentOffsetY)
                return
            }
            
            var leftIndexPathArray = leftTableView.indexPathsForVisibleRows() as NSArray!
            if leftIndexPathArray.count <= 0
            {
                return
            }
            var leftFirstVisibleIndexPath = leftIndexPathArray.objectAtIndex(0) as NSIndexPath
            var leftFirstRect = leftTableView.rectForRowAtIndexPath(leftFirstVisibleIndexPath)
            var leftSumHeight = leftFirstRect.origin.y +  leftFirstRect.height
            var leftOffsetY = leftSumHeight - leftContentOffsetY
            println("leftContentOffsetY:\(leftContentOffsetY) Lhight:\(leftTableView.contentSize.height) Rhight:\(rightTableView.contentSize.height)")
            var rightFirstRect = rightTableView.rectForRowAtIndexPath(leftFirstVisibleIndexPath)
            var rightSumHeight = rightFirstRect.origin.y +  rightFirstRect.height
            var rightOffsetY = rightFirstRect.height * ( leftOffsetY / leftFirstRect.height)
            var rightContentOffsetY = rightSumHeight - rightOffsetY
            println("rightContentOffsetY:\(rightContentOffsetY) Lhight:\(leftTableView.contentSize.height) Rhight:\(rightTableView.contentSize.height)")
            rightTableView.contentOffset = CGPointMake(rightTableView.contentOffset.x, rightContentOffsetY)
            
        }else if scrollView.tag == tableview_tag_right
        {
            var  rightContentOffsetY = rightTableView.contentOffset.y
            if rightContentOffsetY < 0
            {
                leftTableView.contentOffset = CGPointMake(leftTableView.contentOffset.x, rightContentOffsetY)
                return
            }
            
            var rightIndexPathArray = rightTableView.indexPathsForVisibleRows() as NSArray!
            if rightIndexPathArray.count <= 0
            {
                return
            }
            var rightFirstVisibleIndexPath = rightIndexPathArray.objectAtIndex(0) as NSIndexPath
            var rightFirstRect = rightTableView.rectForRowAtIndexPath(rightFirstVisibleIndexPath)
            var rightSumHeight = rightFirstRect.origin.y +  rightFirstRect.height
            var rightOffsetY = rightSumHeight - rightContentOffsetY
            var leftFirstRect = leftTableView.rectForRowAtIndexPath(rightFirstVisibleIndexPath)
            var leftSumHeight = leftFirstRect.origin.y +  leftFirstRect.height
            var leftOffsetY = leftFirstRect.height * ( rightOffsetY / rightFirstRect.height)
            var leftContentOffsetY = leftSumHeight - leftOffsetY
            leftTableView.contentOffset = CGPointMake(leftTableView.contentOffset.x, leftContentOffsetY)
        }
    }

}
