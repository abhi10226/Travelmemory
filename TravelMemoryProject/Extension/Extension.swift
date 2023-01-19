//
//  Extension.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 10/01/23.
//

import Foundation
import UIKit
extension LoginModel {
    func setUserDetailToUserDefault(){
        do{
            let userDetail = try JSONEncoder().encode(self)
            
            _userDefault.setValue(userDetail, forKey: user_Detail)
            _userDefault.synchronize()
        }catch{
            DispatchQueue.main.async {
                
            }
        }
    }
    static func getUserDetailFromUserDefault() -> LoginModel? {
        if let userDetail = UserDefaults.standard.value(forKey: user_Detail) as? Data{
            do {
                let user:LoginModel = try JSONDecoder().decode(LoginModel.self, from: userDetail)
                return user
            }catch{
                DispatchQueue.main.async {
                    
                }
                return nil
            }
        }
        DispatchQueue.main.async {
            //ShowToast.show(toatMessage: kCommonError)
        }
        return nil
    }
}

extension UIViewController {
    func showAlert(alertText : String, alertMessage : String) {
        let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    //Add more actions as you see fit
    self.present(alert, animated: true, completion: nil)
      }
    
    func updateUserInterface() {
        switch Network.reachability.status {
        case .unreachable:
//            view.backgroundColor = .red
            showAlert(alertText: "", alertMessage: "Your internet connectivity lost.")
        case .wwan:
            showAlert(alertText: "", alertMessage: "Your are back in internet connectivity.")
        case .wifi:
            showAlert(alertText: "", alertMessage: "Your are back in internet connectivity.")
        }
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }

}

class CommonViewController : UIViewController {
    var customHud : CustomHud?
    override func viewDidLoad() {
        super.viewDidLoad()
        /*NotificationCenter.default
         .addObserver(self,
         selector: #selector(statusManager),
         name: .flagsChanged,
         object: nil)*/
        
        // do your common works for all sub-classes
    }
}
extension CommonViewController {
    
    func showCentralSpinner(_ userEnabled: Bool = false,_ tabBarUserEnabled: Bool = true, name: String = "") {
        if let _ = customHud{
            customHud?.hide()
        }
        self.view.isUserInteractionEnabled = userEnabled
        self.tabBarController?.tabBar.isUserInteractionEnabled = tabBarUserEnabled
        customHud = CustomHud.intance()
        if let customHud = customHud{
            self.view?.addSubview(customHud)
            
            let top = NSLayoutConstraint(item: customHud, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let buttom = NSLayoutConstraint(item: customHud, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let trail = NSLayoutConstraint(item:customHud, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
            let lead = NSLayoutConstraint(item: customHud, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
            
            customHud.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([top,buttom,trail,lead])
        }
        customHud?.show(name)
    }
    
    func hideCentralSpinner() {
        customHud?.hide()
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = true
        }
    }
    
}
