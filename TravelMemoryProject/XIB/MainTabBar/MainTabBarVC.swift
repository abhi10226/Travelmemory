//
//  MainTabBarVC.swift
//  MaanMandir
//
//  Created by MAC OS 13 on 08/12/21.
//  Copyright © 2020 Akshay. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MainTabBarVC: UITabBarController {
    @IBOutlet var btns: [UIButton]!
    @IBOutlet var imgvTabs: [UIImageView]!
    @IBOutlet var lblName: [UILabel]!
    @IBOutlet var vTabBar: UIView!
    fileprivate lazy var defaultTabBarHeight = { tabBar.frame.size.height }()
    var selectedIdx:Int?
//    var objNotification: APPayload?
    
    
   
     let date = Date()
     
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabBar.frame = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 75)
//        viewPlaySong.isHidden = playerController.player.currentItem == nil
//        var newTabBarHeight: CGFloat = .zero
//        if playerController.player.currentItem == nil {
//            newTabBarHeight = defaultTabBarHeight
//        }else{
//            newTabBarHeight = defaultTabBarHeight + 40
//        }
//        var newFrame = tabBar.frame
//        newFrame.size.height = newTabBarHeight
//        newFrame.origin.y = view.frame.size.height - newTabBarHeight
//        tabBar.frame = newFrame
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UI Mthods
extension MainTabBarVC {
    
    func prepareUI() {
        addControllers()
        addCustomTabbar()
        self.selectedIndex = selectedIdx ?? 0
        selectTab(atIndex: selectedIdx ?? 0)
        
    }
        
    func addControllers() {
        let nav1 = UINavigationController()
        let nav2 = UINavigationController()
      
        
        nav1.navigationBar.isHidden = true
        nav2.navigationBar.isHidden = true
        
        
        let vc1 = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let vc2 = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LocationList") as! LocationList
       

        nav1.viewControllers = [vc1]
        nav2.viewControllers = [vc2]
//
        self.viewControllers = [nav1,nav2]
        tabBar.layoutIfNeeded()
    }
    
    func addCustomTabbar() {
        _ = Bundle.main.loadNibNamed("MainTabbarView", owner: self, options: nil)
        vTabBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 75)
        self.tabBar.addSubview(vTabBar)
        tabBar.layoutIfNeeded()

        self.tabBar.isHidden = false
    }
    
    func selectTab(atIndex index: Int) {
        for (idx,imgv) in lblName.enumerated() {
            if idx == index {
                lblName[idx].textColor = .red
            }else{
                lblName[idx].textColor = .white
            }
        }
        self.selectedIndex = index
    }
    
    
    
}


// MARK: - Actions
extension MainTabBarVC {
    
    @IBAction func btnTapAction(_ sender: UIButton) {
       
        if sender.tag == 101 { // Camera Button
            
        }else{
            
            if sender.tag != self.selectedIndex {
                selectTab(atIndex: sender.tag)
            }
//            if let tabNav = self.navigationController {
//                for vc in tabNav.viewControllers {
//                    if let myVC = vc as? MainTabBarVC {
//                        if let firstVc = (myVC.navigationController?.viewControllers[1]) as? UITabBarController, let navigations = firstVc.viewControllers as? [UINavigationController] {
////                            self.popToRootViewController(navigations: navigations)
//                        }
//                    }
//                }
//            }
        }
    }
}
