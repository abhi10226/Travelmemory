//
//  SystemVC.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 10/01/23.
//

import UIKit

class SystemVC: CommonViewController {

    
    @IBOutlet weak var removeFromDeviceSwitch: UISwitch!
    @IBOutlet weak var autoUpload: UISwitch!
    @IBOutlet weak var lblGuestMode: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        autoUpload.isOn = _userDefault.bool(forKey: userDefaultIsUploadedToCloud) ? true : false
        removeFromDeviceSwitch.isOn = _userDefault.bool(forKey: userDefaultRemoveFromDevice) ? true : false
        if let userDetail = LoginModel.getUserDetailFromUserDefault() {
            lblGuestMode.text = userDetail.data.name
        }else {
            lblGuestMode.text = "As a Guest"
            self.autoUpload.isEnabled = false
            self.removeFromDeviceSwitch.isEnabled = false
            self.btnLogout.isEnabled = false
        }
    }

}
//MARK: - Button Action Method
extension SystemVC {
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func autoUploadTapped(_ sender: Any) {
        UserDefaults.standard.set(autoUpload.isOn, forKey: userDefaultIsUploadedToCloud)
        if _userDefault.bool(forKey: userDefaultIsUploadedToCloud) {
            _appDelegator.uploadSingleVideo()
        }
    }
    
    @IBAction func removeFromDeviceTapped(_ sender: Any) {
        UserDefaults.standard.set(removeFromDeviceSwitch.isOn, forKey: userDefaultRemoveFromDevice)
        if _userDefault.bool(forKey: userDefaultRemoveFromDevice) {
            CoreDataManager.sharedManager.deleteAll()
        }
    }
    
    @IBAction func btnLogoutTapped(_ sender: Any) {
        _userDefault.removeObject(forKey: user_Detail)
        _appDelegator.prepareToLogout()
    }
    @IBAction func btnViewAllVideoTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "LocationList") as? LocationList
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

