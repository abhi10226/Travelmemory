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

class LocationList: UIViewController {
    
    @IBOutlet weak var locationTblView: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    var arrData: [TravelMemory] = []
    var playerviewcontroller = AVPlayerViewController()
    var playerview = AVPlayer ()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("------->FetchData() \(FetchData())")
        
        print("------->FirstUnSyncRow() \(FirstUnSyncRow())")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationTblView.delegate = self
        self.locationTblView.dataSource = self
        fetchCoreData()
    }
    func fetchCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext{
            if let Coredata = try? context.fetch(TravelMemory.fetchRequest()) as! [TravelMemory]{
                arrData = Coredata
                print(arrData.count)
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
extension LocationList {
    @IBAction func btnBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
extension LocationList: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        lblNoData.text = arrData.count == 0 ? "No Avaliable Data" : ""
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! locationCell
        let fileName = URL(fileURLWithPath: "\(arrData[indexPath.row].videoUrl)").deletingPathExtension().lastPathComponent

        Swift.print(fileName)
        cell.lblVideoURL.text = fileName
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("---------------------------")
        if let filevideoUrl = arrData[indexPath.row].videoUrl {
            playerview = AVPlayer(url: filevideoUrl)
            playerviewcontroller.player = playerview
            self.present(playerviewcontroller, animated: true){
                self.playerviewcontroller.player?.play()
            }
        }
    }
    
}

extension UIViewController {
    func FetchData() -> [TravelMemory] {
        
        guard let travelData = CoreDataManager.sharedManager.fetchAllPersons() else { return [TravelMemory]() }
        
        return travelData
    }
    
    func FirstUnSyncRow() -> (TravelMemory, Int) {
        let travelData = FetchData()
        
        if travelData.count > 0 {
            
            let isSyncTrueArray = travelData.filter{ $0.isSync == false }
            
            return (isSyncTrueArray.count == 0 ? travelData.first! : isSyncTrueArray.first!, isSyncTrueArray.count)
        }
        return (TravelMemory(), 0)
    }
    
    func uploadSingleVideo(FirstNonSyncRecord nonSyncRecord : (TravelMemory, Int)) -> Void {
        
        if nonSyncRecord.1 <= 0 {
            return
        }
        
        let nonSyncRecord = nonSyncRecord.0
        
        var FileName = "file_\(Date().timeIntervalSince1970).mp4"
        let Originalurl = URL(string: "https://ar_game.project-demo.info/travel_memories/public/api/video")
        let header : HTTPHeaders = ["Authorization": "Bearer 24|UXmFNdzQWIgP9yajVX7B8P7C8vrQRUBfqoMl7bpJ"]
        let parameter : [String: Any] = ["name" : "\(FileName)", "lat" : "\(nonSyncRecord.latitude)", "long" : "\(nonSyncRecord.longitude)"]
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameter{
                multipartFormData.append(((value as Any) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            let diceRoll = Int(arc4random_uniform(UInt32(100000)))
            do {
//                guard let URL = nonSyncRecord.videoUrl as? URL else { return  }
                guard let videoData = nonSyncRecord.video else { return }//try Data(contentsOf: URL)
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
                fetchRequest.predicate = NSPredicate(format: "fileName = %@", nonSyncRecord.fileName!)
                
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
                
                print("--------VIDEO UPLOADED--------")
            }
        })
        
    }
    
}
