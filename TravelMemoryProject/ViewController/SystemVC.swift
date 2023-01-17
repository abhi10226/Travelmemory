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
        updateUI()
    }
}

//MARK: - UI Method
extension SystemVC {
    func updateUI() {
        autoUpload.isOn = _userDefault.bool(forKey: userDefaultIsUploadedToCloud) ? true : false
        removeFromDeviceSwitch.isOn = _userDefault.bool(forKey: userDefaultRemoveFromDevice) ? true : false
        if let userDetail = LoginModel.getUserDetailFromUserDefault() {
            lblGuestMode.text = userDetail.data.name
            self.btnLogout.isHidden = false
        }else {
            lblGuestMode.text = "As a Guest"
            self.btnLogout.isHidden = true
        }
    }
}

//MARK: - Button Action Method
extension SystemVC {
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func autoUploadTapped(_ sender: Any) {
        if let userDetail = LoginModel.getUserDetailFromUserDefault() {
            UserDefaults.standard.set(autoUpload.isOn, forKey: userDefaultIsUploadedToCloud)
            if _userDefault.bool(forKey: userDefaultIsUploadedToCloud) {
                _appDelegator.uploadSingleVideo()
            }
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! loginVC
            vc.handler { [weak self] result in
                guard let `self` = self else {return}
                if result {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: userDefaultIsUploadedToCloud)
                        _appDelegator.uploadSingleVideo()
                        self.updateUI()
                    }
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func removeFromDeviceTapped(_ sender: Any) {
        if let userDetail = LoginModel.getUserDetailFromUserDefault() {
            UserDefaults.standard.set(removeFromDeviceSwitch.isOn, forKey: userDefaultRemoveFromDevice)
            if _userDefault.bool(forKey: userDefaultRemoveFromDevice) {
                CoreDataManager.sharedManager.deleteAll()
            }
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! loginVC
            vc.handler { [weak self] result in
                guard let `self` = self else {return}
                if result {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: userDefaultRemoveFromDevice)
                        CoreDataManager.sharedManager.deleteAll()
                        self.updateUI()
                    }
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnLogoutTapped(_ sender: Any) {
        _userDefault.removeObject(forKey: user_Detail)
        _userDefault.removeObject(forKey: userDefaultRemoveFromDevice)
        _userDefault.removeObject(forKey: userDefaultIsUploadedToCloud)
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func btnViewAllVideoTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "LocationList") as? LocationList
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

