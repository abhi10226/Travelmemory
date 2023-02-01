//
//  PlayerViewController.swift
//  SummerPlayerViewDemo
//
//  Created by derrick on 2020/08/18.
//  Copyright © 2020 Derrick. All rights reserved.
//

import UIKit
import AVKit

//import SummerPlayerView

class PlayerViewController: UIViewController  {
    
    let defaultConfig = DefaultConfig()
    var testContents = arrayVideoDetail
    var videoIndexNumber = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let sampleTheme = ThemeMaker.getTheme()
        
        let summerPlayerView = SummerPlayerView(configuration: defaultConfig, theme: sampleTheme,targetView: view)
        
        summerPlayerView.delegate = self
        
//        if let currentItem = testContents.first {
//            summerPlayerView.setupPlayList(currentItem: currentItem, items: testContents)
//        }
        let contentArr = testContents.map{$0.contentStruct}
        summerPlayerView.setupPlayList(currentItem: contentArr[videoIndexNumber], items: contentArr, videoIndex: videoIndexNumber)
        view.addSubview(summerPlayerView)
        
        summerPlayerView.pinEdges(targetView: view)
        
    }
    
}

extension PlayerViewController : SummerPlayerViewDelegate {
    func didFinishVideo() {
        print("didFinishVideo")
        /*if self.defaultConfig.playbackMode == .nextPlay {
            moveViewController()   
        }*/
    }
    
    func didStartVideo() {
        print("didStartVideo")
    }
    
    func didChangeSliderValue(_ seekTime: CMTime) {
        print("didChangeSliderValue")
    }
    func didPressBackButton() {
        print("didPressBackButton")
//        moveViewController()
        self.dismiss(animated: true)
    }
    
    func didPressNextButton() {
        print("didPressNextButton")

    }
    
    func didPressPreviousButton() {
        print("didPressPreviousButton")
    }
    
    func didPressAirPlayButton() {
        print("didPressAirPlayButton")

    }
    
    func didPressHeaderLabel() {
        print("didPressHeaderLabel")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EnterNamePopupVC") as! EnterNamePopupVC
        vc.handler { [weak self] result in
            guard let `self` = self else {return}
            print(result)
        }
        vc.modalPresentationStyle  = .overFullScreen
        UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
    }
    
    func didPressContentsListView(index: Int) {
        print("didPressContentsListView")
    }
    
    func didPressPlayButton(isActive: Bool) {
        print("didPressPlayButton")
    }
    
}

extension PlayerViewController {
    
    fileprivate func moveViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainVC")
        self.present(controller, animated: true, completion: nil)
    }
}
