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
    var completionHandler : ((String) -> Void)?
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
        let singleSummerViewObj = self.summerViewTrigger() as! SummerPlayerView
               singleSummerViewObj.queuePlayer.pause()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EnterNamePopupVC") as! EnterNamePopupVC
        videoIndexNumber = singleSummerViewObj.currentVideoIndex
        vc.videoName = testContents[videoIndexNumber].contentStruct.title
        vc.handler { [weak self] result in
            guard let `self` = self else {return}
            if result == "" {
                singleSummerViewObj.queuePlayer.play()
                return
            }
            self.updateVideoName(result)
            singleSummerViewObj.playerScreenView.headerTitle.text = "\(result)"
            singleSummerViewObj.contents![self.videoIndexNumber].title = "\(result)"
            singleSummerViewObj.queuePlayer.play()
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
    func handler(handler: @escaping ((String) -> ())) {
        completionHandler = handler
    }
    func updateVideoName(_ videoName: String) {
        let isNameAlreadyExit = testContents.filter { videoDetail in
            return videoDetail.name == videoName
        }
        if isNameAlreadyExit.count == 0 {
            testContents[videoIndexNumber].name = videoName
            if testContents[videoIndexNumber].isUploaded {
                callUpdateApi(updateDetail: testContents[videoIndexNumber]) { result in
                    self.completionHandler?(videoName)
                }
                CoreDataManager.sharedManager.updateVideoName(updateDetail: testContents[videoIndexNumber], completionHandler: nil)
            }else {
                CoreDataManager.sharedManager.updateVideoName(updateDetail: testContents[videoIndexNumber]) { result in
                    self.completionHandler?(videoName)
                }
            }
            
        }
    }
    fileprivate func moveViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainVC")
        self.present(controller, animated: true, completion: nil)
    }
    func summerViewTrigger() -> AnyObject {
            let allSubviews = view.allSubViewsOf(type: SummerPlayerView.self)
            for view1 in allSubviews {
                let view11 = view1 as SummerPlayerView
                return view11
            }
            return allSubviews[0]
        }
}
extension UIView {

    /** This is the function to get subViews of a view of a particular type
*/
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }


/* This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
        func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
            var all = [T]()
            func getSubview(view: UIView) {
                if let aView = view as? T{
                all.append(aView)
                }
                guard view.subviews.count>0 else { return }
                view.subviews.forEach{ getSubview(view: $0) }
            }
            getSubview(view: self)
            return all
        }
    }

