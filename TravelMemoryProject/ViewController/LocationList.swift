//
//  LocationList.swift
//  TravelMemoryProject
//
//  Created by IPS-161 on 12/12/22.
//

import UIKit
import AVFoundation
import AVKit
import Alamofire
import CoreData

class LocationList: CommonViewController {
    
    @IBOutlet weak var locationTblView: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    var arrData: [TravelMemory] = []
    var playerviewcontroller = AVPlayerViewController()
    var playerview = AVPlayer ()
    var arrVideoDetail: [VideoDetail] = []
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.locationTblView.delegate = self
        self.locationTblView.dataSource = self
        arrVideoDetail = []
        fetchCoreData()
        if NewReachability().isConnectedToNetwork() , let _ = LoginModel.getUserDetailFromUserDefault() {
            self.getAllVideoFromServer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    func fetchCoreData() {
        if let arrdata  = CoreDataManager.sharedManager.fetchAllPersons() {
            for data in arrdata {
                var param : [String:Any] = [:]
                param["Id"] = "ComingFromLocalDatabase"
                if let fileName = data.fileName {
                    param["name"] = fileName
                }
                if let videoUrl = data.videoUrl {
                    param["video"] = "\(videoUrl)"
                }
                param["lat"] = data.latitude
                param["long"] = data.longitude
                if let videoData = data.video {
                    param["videoData"] = videoData
                }
                if !data.isSync {
                    self.arrVideoDetail.append(VideoDetail(param))
                }else {
                    if let _ = LoginModel.getUserDetailFromUserDefault() {
                        
                    }else {
                        self.arrVideoDetail.append(VideoDetail(param))
                    }
                }
            }
            if let userDetail = LoginModel.getUserDetailFromUserDefault() {
                print("\(userDetail.data.name)")
            }else{
                self.locationTblView.reloadData()
            }
        }
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 15, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
}
//MARK: - Action Method
extension LocationList {
    @IBAction func btnBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
extension LocationList: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        lblNoData.text = arrVideoDetail.count == 0 ? "No Avaliable Data" : ""
        return arrVideoDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! locationCell
        let fileName = URL(fileURLWithPath: "\(arrVideoDetail[indexPath.row].video)").deletingPathExtension().lastPathComponent

        Swift.print(fileName)
        cell.lblVideoURL.text = arrVideoDetail[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("---------------------------")
        let data = arrVideoDetail[indexPath.row].video
           /* let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("yourvidename.mp4")

            do {
                try data.write(to: cacheURL, options: .atomicWrite)
            } catch let err {
                print("Failed with error:", err)
            }*/
        if let url = URL(string: data) {
            playerview = AVPlayer(url: url)
            playerviewcontroller.player = playerview
            self.present(playerviewcontroller, animated: true){
                self.playerviewcontroller.player?.play()
            }
        }
           
        
    }
    
}

extension AppDelegate {
    
    func uploadSingleVideo()  {
            guard let userDeatil = LoginModel.getUserDetailFromUserDefault() else {return}
            guard let fetchProduct = CoreDataManager.sharedManager.fetchAllPersons() else { return  }
            for product in fetchProduct {
                if !product.isSync {
                    let FileName = "file_\(Date().timeIntervalSince1970).mp4"
                    var fileName: String = ""
                    if let name = product.fileName {
                        fileName = name
                    }
                    let Originalurl = URL(string: "https://ar_game.project-demo.info/travel_memories/public/api/video")
                    let header : HTTPHeaders = ["Authorization": "Bearer \(userDeatil.data.token)"]
                    let parameter : [String: Any] = ["name" : "\(fileName)", "lat" : "\(product.latitude)", "long" : "\(product.longitude)"]
                    AF.upload(multipartFormData: { (multipartFormData) in
                        for (key, value) in parameter{
                            multipartFormData.append(((value as Any) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                        }
                        let diceRoll = Int(arc4random_uniform(UInt32(100000)))
                        do {
            //                guard let URL = nonSyncRecord.videoUrl as? URL else { return  }
                            guard let videoData = product.video else { return }//try Data(contentsOf: URL)
                            print("",videoData)
                            multipartFormData.append(videoData, withName: "file", fileName: "\(FileName)", mimeType: "mp4")
                        } catch {
                            debugPrint("Couldn't get Data from URL")
                        }
                    }, to: Originalurl!, method: .post, headers: header ).responseJSON(completionHandler: { (res) in
                        print("This is the result", res.result)
                        switch res.result {
                        case .failure(let err):
                            if let code = err.responseCode{
                                print("unable to upload the image and create a post ",code)
                                break
                            }
                        case .success(let sucess):

                            let manageContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
                            
                            let fetchRequest : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "TravelMemory")
                            fetchRequest.predicate = NSPredicate(format: "fileName = %@", product.fileName!)
                            
                            do {
                                let test = try manageContext!.fetch(fetchRequest)
                                
                                let objectUpdate = test[0] as! NSManagedObject

                                objectUpdate.setValue(true , forKey: "isSync")
                                
                                do {
                                    try manageContext?.save()
                                    
                                    
                                } catch  {
                                    print(error)
                                }
                                
                            } catch  {
                                print(error)
                            }
                            if _userDefault.bool(forKey: userDefaultRemoveFromDevice) {
                                CoreDataManager.sharedManager.deleteSingleData(fileName: product.fileName!)
                            }
                            print("--------VIDEO UPLOADED--------")
                        }
                    })
                }
            }
        }
    
}
extension LocationList {
    func getAllVideoFromServer() {
        guard let userDetail = LoginModel.getUserDetailFromUserDefault() else {return}
        
        let header : HTTPHeaders = ["Authorization": "Bearer \(userDetail.data.token)"]
        let urlString = "https://ar_game.project-demo.info/travel_memories/public/api/video"
        print(userDetail.data.token)
        AF.request(urlString,method: .get, headers: header)
            .responseJSON { response in
                switch response.result {
                case .success( let value):
                    if let videodata = value as? [String : Any] {
                        if let videoDetailData = videodata["data"] as? [String:Any] {
                            if let videoDetailArr = RawdataConverter.array(videoDetailData["videos"]) as? [[String:Any]] {
                                for videoDetail in videoDetailArr {
                                    self.arrVideoDetail.append(VideoDetail(videoDetail))
                                }
                                print(self.arrVideoDetail[0].video)
                                self.locationTblView.reloadData()
                            }
                        }
                    }
                    
                case .failure( let value):
                    print(value)
                }
                
            }
    }
}
