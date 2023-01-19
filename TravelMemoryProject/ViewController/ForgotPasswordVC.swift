//
//  ForgotPasswordVC.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 17/01/23.
//

import UIKit
import Alamofire
import TextFieldEffects
import Toaster
class ForgotPasswordVC: CommonViewController {
    @IBOutlet weak var txtEmail: HoshiTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


}
//MARK: - Action Method
extension ForgotPasswordVC {
    @IBAction func btnForgotPassTapped(_ sender: UIButton) {
        let result = isValid()
        if result.valid {
            callForgotPassword()
            return
        }
        Toast(text: "\(result.error)").show()
    }
    @IBAction func btnBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
//MARK: - Api Calling
extension ForgotPasswordVC {
    func callForgotPassword() {
        showCentralSpinner()
        let urlString = "https://ar_game.project-demo.info/travel_memories/public/api/forgot-password"
        var params: [String:Any] = [:]
        params["email"] = txtEmail.text
        AF.request(urlString,method: .post,parameters: params)
            .responseJSON { response in
                switch response.result {
                case .success( let value):
                    self.hideCentralSpinner()
                    if let videodata = value as? [String : Any] {
                        Toast(text: videodata["message"] as? String).show()
                    }
                    self.navigationController?.popViewController(animated: false)
                case .failure( let value):
                    print(value)
                }
                
            }
    }
}
//MARK: - Validation
extension ForgotPasswordVC {
    
    func isValid() -> (valid: Bool, error: String) {
        var result = (valid: true, error: "")
        if String.validate(value: txtEmail.text) {
            result.valid = false
            result.error = "Please enter email address."
            return result
        }else if !txtEmail.text!.isEmailAddressValid {
            result.valid = false
            result.error = "Please enter valid email address."
            return result
        }
        return result
    }
    
}
