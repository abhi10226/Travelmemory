//
//  ViewController.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 08/12/22.
//

import UIKit
import MapKit
import AVKit
import AVFoundation
import GoogleMaps
import Alamofire
import Toaster
import CoreData
var arrayVideoDetail: [VideoDetail] = []
class ViewController: CommonViewController,CLLocationManagerDelegate, GMSMapViewDelegate {
    //MARK: - IBOutlet
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var mapKitView: MKMapView!
    var locationManager = CLLocationManager()
    
    //MARK: - Instance Method
    var isFromWidget: Bool = false
    var arrData: [TravelMemory] = []
    var arrVideoDetail: [VideoDetail] = []
    var playerviewcontroller = AVPlayerViewController()
    var playerview = AVPlayer ()
    var latitude:CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    //Application Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if isFromWidget {
            VideoService.instance.launchVideoRecorder(in: self, completion: nil)
            VideoService.instance.delegate = self
        }
        //        determineMyCurrentLocation()
        
        //MARK: GOOGLEMAP
        self.googleMapView.isMyLocationEnabled = true
        self.googleMapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 1000
        self.locationManager.startUpdatingLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }
    
    func updateUI() {
        arrData = []
        arrVideoDetail = []
        googleMapView.clear()
        if !NewReachability().isConnectedToNetwork() {
            fetchCoreData()
        }else {
            if let _ = LoginModel.getUserDetailFromUserDefault() {
                self.getAllVideoFromServer {
                    self.fetchCoreData()
                }
            }else{
                self.fetchCoreData()
            }
        }
        self.tabBarController?.tabBar.isHidden = false
    }
    //MARK: GOOGLEMAP METHOD
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 20)
        self.googleMapView.animate(to: camera)
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }
    
}
//MARK: - Action Method
extension ViewController {
    @IBAction func btnSystemTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SystemVC") as! SystemVC
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func btnRecTapped(_ sender : UIButton) {
        VideoService.instance.isComeFromHomeView = true
        VideoService.instance.launchVideoRecorder(in: self, completion: nil)
        VideoService.instance.handler {
            if _userDefault.bool(forKey: userDefaultIsUploadedToCloud) {
                _appDelegator.uploadSingleVideo()
            }
        }
        
    }
}
//MARK: - Application Mehod
extension ViewController {
    
    func setRegionWhenLatLongGet() {
        if CLLocationManager.locationServicesEnabled() {
           
           // mapKitView.delegate = self
            if let latitude = latitude, let longitude = longitude {
                mapKitView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: 10, longitudinalMeters: 10), animated: true)
            }
//            fetchStadiumsOnMap(arrData)
        } else {
            // Do something to let users know why they need to turn it on.
            
        }
    }
    
    func fetchStadiumsOnMap(_ stadiums: [VideoDetail]) {
        self.onMapChangesArrayChange()
        var markers = [MyGMSMarker]()
        for stadium in stadiums {
            let marker = MyGMSMarker()
            print("id==",stadium.Id)
            // I have taken a pin image which is a custom image
            let serverMarkerImage = UIImage(named: "ic_serverPin")!
            let localMarkerImage = UIImage(named: "ic_localPin")!
            //creating a marker view
            let serverMarkerView = UIImageView(image: serverMarkerImage)
            let localMarkerView = UIImageView(image: localMarkerImage)
            marker.position = CLLocationCoordinate2D(latitude:
                                                        stadium.lat as! CLLocationDegrees, longitude: stadium.long as! CLLocationDegrees)
            marker.iconView = stadium.isUploaded ? serverMarkerView : localMarkerView
            marker.title = "I added this with a long tap"
            marker.snippet = ""
            marker.isDraggable = true
            if let url = URL(string: stadium.video) {
                marker.identifier = url
            }
            markers.append(marker)
            marker.map = googleMapView
        }

        
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        onMapChangesArrayChange()
    }
    
    func onMapChangesArrayChange() {
        let region = googleMapView.projection.visibleRegion()
        print(region)
        arrayVideoDetail = []
        let bound = GMSCoordinateBounds(region: region)
        for value in arrVideoDetail {
            print(value.Id)
           // region.contains(CLLocationCoordinate2D(latitude: VideoDetail.lat, longitude: VideoDetail.long))
            if bound.contains(CLLocationCoordinate2D(latitude: value.lat, longitude: value.long)) {
                arrayVideoDetail.append(value)
            }
        }
        print(arrayVideoDetail.count)
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        if let marker = marker as? MyGMSMarker {
            if let string = marker.identifier {
                for (i,val) in arrVideoDetail.enumerated() {
                    if val.video == "\(string)" {
                        if val.isUploaded {
                            arrVideoDetail[i].lat = marker.position.latitude
                            arrVideoDetail[i].long = marker.position.longitude
                            print("Integrate Edit menu api")
                            callUpdateApi(updateDetail: arrVideoDetail[i], CompletionHandler: nil)
                            CoreDataManager.sharedManager.updateLotLong(updateDetail: arrVideoDetail[i])
                        }else{
                            arrVideoDetail[i].lat = marker.position.latitude
                            arrVideoDetail[i].long = marker.position.longitude
                            CoreDataManager.sharedManager.updateLotLong(updateDetail: arrVideoDetail[i])
                        }
                    }
                }
            }
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let marker = marker as? MyGMSMarker {
            if let string = marker.identifier {
                
               /* let data = marker.VideoNSData
                let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("yourvidename.mp4")

                do {
                    try data?.write(to: cacheURL, options: .atomicWrite)
                } catch let err {
                    print("Failed with error:", err)
                }*/

                
               /* print(string)
                let fileURL = NSURL(fileURLWithPath:"\(string)")
                print(fileURL)
                playerview = AVPlayer(url: string)
                playerviewcontroller.player = playerview
                self.present(playerviewcontroller, animated: true){
                    self.playerviewcontroller.player?.play()
                }*/
                let videoDetailFilterArr = arrayVideoDetail.filter{$0.video ==  "\(string)"}
                if let videoDetailModel = videoDetailFilterArr.first,let index = arrayVideoDetail.firstIndex(of: videoDetailModel) {
                    movePlayerController(indexNumber: index) { result in
                        self.updateUI()
                    }
                }
                
            }
        }
        return true
    }
   
    func fetchCoreData() {
        if let arrdata  = CoreDataManager.sharedManager.fetchAllPersons() {
            for data in arrdata {
                var param : [String:Any] = [:]
                param["Id"] = "ComingFromLocalDatabase"
                if let name = data.fileName {
                    param["name"] = name
                }
                if let data = data.videoUrl {
                    param["video"] = "\(data)"
                }
                param["lat"] = data.latitude
                param["long"] = data.longitude
                param["videoData"] = data.video
                param["isUploaded"] = data.isSync
                if !data.isSync,let _ = LoginModel.getUserDetailFromUserDefault() {
                    self.arrVideoDetail.append(VideoDetail(param))
                } else {
                    if let _ = LoginModel.getUserDetailFromUserDefault() {
                        
                    }else {
                        self.arrVideoDetail.append(VideoDetail(param))
                    }
                }
            }
            if let userDetail = LoginModel.getUserDetailFromUserDefault() {
                print(userDetail.data.name)
                self.fetchStadiumsOnMap(self.arrVideoDetail)
            }else {
                self.fetchStadiumsOnMap(self.arrVideoDetail)
            }
        }
        
    }
    
    
    func createDirectoryPath() {
        let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let DirPath = DocumentDirectory.appendingPathComponent("FOLDER_NAME")
        let fileManager = FileManager.default
        let filePath = DirPath!.path
        if !fileManager.fileExists(atPath: filePath){
            do
            {
                try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
                UserDefaults.standard.set(DirPath!.path, forKey: "DirectoryPath")
            }
            catch let error as NSError
            {
                print("Unable to create directory \(error.debugDescription)")
            }
        }else{
            print("Folder Available....")
        }
        print("Dir Path = \(DirPath!)")
    }
    
}

////MARK: - MapView Extension
//extension ViewController : MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if let a = view.annotation as? MyPointAnnotation {
//            if let string = a.identifier {
//                print(string)
//                let fileURL = NSURL(fileURLWithPath:"\(string)")
//                print(fileURL)
//                playerview = AVPlayer(url: fileURL as URL)
//                playerviewcontroller.player = playerview
//                self.present(playerviewcontroller, animated: true){
//                    self.playerviewcontroller.player?.play()
//                }
//            }
//        }
//    }
//}



//MARK: - Video Service Protocol Delegate Method
extension ViewController: VideoServiceDelegate {
    func videoDidFinishSaving(error: Error?, url: URL?) {
        let success: Bool = error == nil
        if success {
            
        }
        let title = success ? "Success" : "Error"
        let message = success ? "Video was saved" : "Could not save video"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
/*
 //MARK: - MAP Location Delegate Method
 extension ViewController: CLLocationManagerDelegate {
 func determineMyCurrentLocation() {
 locationManager = CLLocationManager()
 locationManager.delegate = self
 locationManager.desiredAccuracy = kCLLocationAccuracyBest
 
 locationManager.requestAlwaysAuthorization()
 
 if CLLocationManager.locationServicesEnabled() {
 locationManager.startUpdatingLocation()
 //locationManager.startUpdatingHeading()
 
 }
 }
 
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 let userLocation:CLLocation = locations[0] as CLLocation
 
 // Call stopUpdatingLocation() to stop listening for location updates,
 // other wise this function will be called every time when user location changes.
 
 // manager.stopUpdatingLocation()
 
 print("user latitude = \(userLocation.coordinate.latitude)")
 print("user longitude = \(userLocation.coordinate.longitude)")
 latitude = userLocation.coordinate.latitude
 longitude = userLocation.coordinate.longitude
 setRegionWhenLatLongGet()
 //        addAsset(image: UIImage(named: "img")!, location: CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude) )
 }
 
 func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
 {
 print("Error \(error)")
 }
 }*/
class MyGMSMarker: GMSMarker {
    
    var identifier: URL?
    var VideoNSData: Data?
}
//MARK: - API Calling
extension ViewController {
    func getAllVideoFromServer(completionHandler: @escaping (() -> Void)) {
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
                                self.fetchStadiumsOnMap(self.arrVideoDetail)
                            }
                        }
                        completionHandler()
                    }
                    
                case .failure( let value):
                    print(value)
                }
                
            }
    }
    
    
}
extension UIViewController {
    
    func movePlayerController(indexNumber : Int,completionHandler: @escaping ((String)-> Void)) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PlayerVC") as! PlayerViewController
        controller.modalPresentationStyle = .overFullScreen
        controller.videoIndexNumber = indexNumber
        controller.testContents = arrayVideoDetail
        controller.completionHandler = { result in
            print(result)
            completionHandler(result)
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    func callUpdateApi(updateDetail:VideoDetail,CompletionHandler : ((Bool) -> Void)?) {
        guard let userDetail = LoginModel.getUserDetailFromUserDefault() else {return}
        let header : HTTPHeaders = ["Authorization": "Bearer \(userDetail.data.token)"]
        let urlString = "https://ar_game.project-demo.info/travel_memories/public/api/update-video"
        var params: [String:Any] = [:]
        params["id"] = updateDetail.Id
        params["name"] = updateDetail.name
        params["lat"] = updateDetail.lat
        params["long"] = updateDetail.long
        print("id==",updateDetail.Id)
        AF.request(urlString,method: .post,parameters: params, headers: header)
            .responseJSON { response in
                switch response.result {
                case .success( let value):
                    if let videodata = value as? [String : Any] {

                        if let message = videodata["message"] as? String {
                            Toast(text: message).start()
                            CompletionHandler?(true)
                        }
                    }
                    
                case .failure( let value):
                    print(value)
                }
                
            }
    }
}
