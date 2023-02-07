//
//  SystemVC.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 10/01/23.
//

import UIKit
import Toaster

class SystemVC: CommonViewController {

    
    @IBOutlet weak var removeFromDeviceSwitch: UISwitch!
    @IBOutlet weak var autoUpload: UISwitch!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnLogin : UIButton!
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
        self.tabBarController?.tabBar.isHidden = true
        autoUpload.isOn = _userDefault.bool(forKey: userDefaultIsUploadedToCloud) ? true : false
        removeFromDeviceSwitch.isOn = _userDefault.bool(forKey: userDefaultRemoveFromDevice) ? true : false
        if let userDetail = LoginModel.getUserDetailFromUserDefault() {
            self.btnLogin.isHidden = true
            self.btnLogout.isHidden = false
        }else {
            self.btnLogin.isHidden = false
            self.btnLogout.isHidden = true
        }
    }
    func naviToLoginVC() {
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
    
    func naviToNeedToLoginPopupVC() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NeedToLoginPopUpVC") as! NeedToLoginPopUpVC
        vc.handler { [weak self] result in
            guard let `self` = self else {return}
            if result {
                self.naviToLoginVC()
            }else{
                self.updateUI()
            }
        }
        vc.modalPresentationStyle = .overFullScreen
        navigationController?.present(vc, animated: true, completion: nil)
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
            naviToNeedToLoginPopupVC()
        }
        
    }
    
    @IBAction func removeFromDeviceTapped(_ sender: Any) {
        if _userDefault.bool(forKey: userDefaultIsUploadedToCloud) {
            UserDefaults.standard.set(removeFromDeviceSwitch.isOn, forKey: userDefaultRemoveFromDevice)
            if _userDefault.bool(forKey: userDefaultRemoveFromDevice) {
                CoreDataManager.sharedManager.deleteAll()
            }
        }else{
            updateUI()
            Toast(text: "You need to switch on upload to Cloud for removing the video from your device ").show()
        }
    }
    
    @IBAction func btnLogoutTapped(_ sender: Any) {
        _userDefault.removeObject(forKey: user_Detail)
        _userDefault.removeObject(forKey: userDefaultRemoveFromDevice)
        _userDefault.removeObject(forKey: userDefaultIsUploadedToCloud)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        naviToLoginVC()
    }
    
}

