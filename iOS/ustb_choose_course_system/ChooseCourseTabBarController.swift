//
//  ChooseCourseTabBarController.swift
//  ustb_choose_course_system
//
//  Created by kalen blue on 15-8-12.
//  Copyright (c) 2015年 kalen blue. All rights reserved.
//

import UIKit

class ChooseCourseTabBarController: UITabBarController {

    var cookieData:String = ""
    //已修公选课
    var learnedPublicClasses:[kalen.app.ClassBean] = []
    
    //已选课
    var selectedClasses:[kalen.app.ClassBean] = []
    
    //未满的公选课
    var notFullPublicClasses:[kalen.app.ClassBean] = []
    
    //所有的公选课
    //var publicClasses:[kalen.app.ClassBean] = []
    
    //专业选修课列表
    var specifiedClasses:[kalen.app.ClassBean] = []
    
    //必修课列表
    var prerequisiteClasses:[kalen.app.ClassBean] = []
    
    //上课类型
    var chooseCourseType = kalen.app.ConstVal.AfterChooseCourse
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateNotFullPublicSelectiveCourses(_delegate:ChooseCourseDelegate){
        MBProgressHUD.showMessage("加载中")
        var url:String = ""
        if self.chooseCourseType == kalen.app.ConstVal.AfterChooseCourse{
            url = kalen.app.ConstVal.SEARCH_NOT_FULL_PUBLIC_COURSE_URL
        }else{
            url = kalen.app.ConstVal.SEARCH_PRE_PUBLIC_SELECTIVE_COURSE_URL
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let data = kalen.app.HttpUtil.get(url, cookieStr: self.cookieData)
            dispatch_async(dispatch_get_main_queue(), {
                MBProgressHUD.hideHUD()
                if data != nil{
                    let parser = kalen.app.JsonParser(jsonStr: data! as String)
                    self.notFullPublicClasses = parser.getAlternativeCourses()
                    self.selectedClasses = parser.getSelectedCourses()
                    self.learnedPublicClasses = parser.getLearnedPublicCourses()
                }else{
                    self.notFullPublicClasses = []
                    self.selectedClasses = []
                    self.learnedPublicClasses = []
                    MBProgressHUD.showError("网络连接错误")
                }
                
                _delegate.afterParseDatas()
            })
            
        })
        
        
    }
    
    func updatePrerequisiteCourses(_delegate: ChooseCourseDelegate){
        //var data
        MBProgressHUD.showMessage("加载中")
        var urlPrerequisite:String = ""
        var urlPublic:String = ""
        if self.chooseCourseType == kalen.app.ConstVal.AfterChooseCourse{
            urlPrerequisite = kalen.app.ConstVal.SEARCH_PREREQUISITE_COURSE_URL
            urlPublic = kalen.app.ConstVal.SEARCH_NOT_FULL_PUBLIC_COURSE_URL
        }else{
            urlPrerequisite = kalen.app.ConstVal.SEARCH_PRE_PREREQUISITE_COURSE_URL
            urlPublic = kalen.app.ConstVal.SEARCH_PRE_PUBLIC_SELECTIVE_COURSE_URL
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let dataForSelectedCoureses = kalen.app.HttpUtil.get(urlPublic, cookieStr: self.cookieData)
            let dataForPrerequisiteCourses = kalen.app.HttpUtil.get(urlPrerequisite, cookieStr: self.cookieData)
            
            dispatch_async(dispatch_get_main_queue(), {
                MBProgressHUD.hideHUD()
                if (dataForPrerequisiteCourses != nil) && (dataForSelectedCoureses != nil){
                    //必修课如果已经选择了的话，再向服务器post数据，服务器会抛出异常
                    var parser = kalen.app.JsonParser(jsonStr: dataForSelectedCoureses! as String)
                    self.selectedClasses = parser.getSelectedCourses()
                    
                    //添加必修课列表
                    //parser = nil
                    parser = kalen.app.JsonParser(jsonStr: dataForPrerequisiteCourses! as String)
                    self.prerequisiteClasses = parser.getTechingCourses()
                    
                }else{
                    self.prerequisiteClasses = []
                    self.selectedClasses = []
                    MBProgressHUD.showError("网络连接错误")
                }
                _delegate.afterParseDatas()
                
            })
        })
        

    }
    
    func updateSpecifiedCourses(_delegate: ChooseCourseDelegate){
        //var data
        MBProgressHUD.showMessage("加载中")
        var url:String = ""
        if self.chooseCourseType == kalen.app.ConstVal.AfterChooseCourse{
            url = kalen.app.ConstVal.SEARCH_SPECIFIED_COURSE_URL
        }else{
            url = kalen.app.ConstVal.SEARCH_PRE_SPECIFIED_COURSE_URL
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        
            let data = kalen.app.HttpUtil.get(url, cookieStr: self.cookieData)
            dispatch_async(dispatch_get_main_queue(), {
                MBProgressHUD.hideHUD()
                if data != nil{
                    let parser = kalen.app.JsonParser(jsonStr: data! as String)
                    self.specifiedClasses = parser.getTechingCourses()
                    
                }else{
                    self.specifiedClasses = []
                    MBProgressHUD.showError("网络连接错误")
                }
                
                _delegate.afterParseDatas()
            })
        })
        
    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! ClassTableViewController
        vc.cookieData = cookieData
    }


}
