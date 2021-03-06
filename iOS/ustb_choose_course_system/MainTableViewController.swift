//
//  MainTableViewController.swift
//  ustb_choose_course_system
//
//  Created by kalen blue on 15-8-11.
//  Copyright (c) 2015年 kalen blue. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController{
    
    @IBOutlet weak var logoutBarItem: UIBarButtonItem!
    private var cookieData:String = ""
    
    private var loginAlertView:UIAlertView!
    
    private let LOGOUT_BTN_INDEX = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.cloudsColor()
        self.navigationController?.navigationBar.configureFlatNavigationBarWithColor(UIColor.midnightBlueColor())
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        logoutBarItem.configureFlatButtonWithColor(UIColor.peterRiverColor(), highlightedColor: UIColor.belizeHoleColor(), cornerRadius: 3)
        logoutBarItem.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: UIControlState.Normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.scrollEnabled = false

        let vc = self.navigationController as! MainNavigationController
        //取出cookie
        cookieData = vc.cookieData
        
    }
    

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0{
            return 15
        }
        if section == 1{
            return 35
        }
        
        return 1000.0;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.section == 0 {
//            //预选课 和 考试安排查询
//            if (indexPath.row == 1) || (indexPath.row == 3){
//                let alert = UIAlertView()
//                alert.title = "提示"
//                alert.message = "此功能会等到选课系统更新后添加"
//                alert.addButtonWithTitle("确定")
//                alert.show()
//                
//            }else
            
            switch indexPath.row {
            case 0:
                kalen.app.UserInfo.getInstance().chooseCourseType = kalen.app.ConstVal.AfterChooseCourse
                print(kalen.app.UserInfo.getInstance().chooseCourseType)
            case 1:
                kalen.app.UserInfo.getInstance().chooseCourseType = kalen.app.ConstVal.PreChooseCourse
                print(kalen.app.UserInfo.getInstance().chooseCourseType)
            case 2:
                performSegueWithIdentifier("classTableSegue", sender: nil)
            default:
                print("default")
            }
            
        }else if indexPath.section == 1 {
            if indexPath.row == 1{
                MBProgressHUD.showMessage("加载中")
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let jsonData = kalen.app.HttpUtil.get(kalen.app.ConstVal.APP_CHECK_UPDATE_URL, cookieStr: "")
                    dispatch_async(dispatch_get_main_queue(), {
                        MBProgressHUD.hideHUD()
                        if jsonData == nil{
                            MBProgressHUD.showError("网络错误")
                            return
                        }
                        let parser = kalen.app.JsonParser(jsonStr: jsonData! as String)
                        let msg = parser.getUpdateMsg()
                        if msg == nil{
                            MBProgressHUD.showError("内部错误")
                            return
                        }
                        var msgStr:String = "当前版本: \(kalen.app.ConstVal.VERSION)\n最新版本: \(msg!.version)\n更新说明: \(msg!.update_note)\n注: 请到“官网”下载二维码进行扫描安装"
                        
                        if (msg!.version - 0.0001) < kalen.app.ConstVal.VERSION{
                            msgStr = "已经是最新版本"
                        }
                        
                        let alert = UIAlertView(title: "提示", message: msgStr, delegate: nil, cancelButtonTitle: "确定")
                        alert.show()
                    })
                })
            }
        }
        
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }
    

    @IBAction func logoutBarItemClicked(sender: AnyObject) {
        let alert = UIAlertController(title: "是否要退出账户", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "classTableSegue"{
            
            let vc = segue.destinationViewController as! ClassTableViewController
            vc.cookieData = cookieData
        }else if segue.identifier == "chooseCourseSegue" { //退补选课
            let vc = segue.destinationViewController as! ChooseCourseTabBarController
            vc.cookieData = cookieData
        }else if segue.identifier == "preChooseCourseSegue"{//预选课
            let vc = segue.destinationViewController as! ChooseCourseTabBarController
            vc.cookieData = cookieData
        }else if segue.identifier == "innovativeCreditSegue"{
            let vc = segue.destinationViewController as! InnovativeCreditController
            vc.cookieData = cookieData
        }else if segue.identifier == "examListSegue"{
            let vc = segue.destinationViewController as! ExamListController
            vc.cookieData = cookieData
        }
    }
}
