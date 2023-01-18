//
//  RegisterVC.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 03/01/23.
//

import Foundation
import UIKit
import TextFieldEffects
import Toaster
class RegisterVC : CommonViewController {
    @IBOutlet weak var txtName:HoshiTextField!
    @IBOutlet weak var txtEmail:HoshiTextField!
    @IBOutlet weak var txtPassword: HoshiTextField!
    @IBOutlet weak var txtConfirmPassword: HoshiTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
//MARK: - Action Method
extension RegisterVC {
    @IBAction func btnSignUpTapped(_ sender: UIButton) {
        let result = isValid()
        if result.valid {
            signUpApi()
            return
        }
        Toast(text:result.error).show()
    }
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Api Calling
extension RegisterVC {
    func signUpApi() {
        showCentralSpinner()
        var params:[String:Any] = [:]
        params["name"] = txtName.text
        params["email"] = txtEmail.text
        params["password"] = txtPassword.text
        params["password_confirmation"] = txtConfirmPassword.text
        CatFactApi().SignUp(parameters: params) { result in
            switch result {
            case .success(let value):
                self.hideCentralSpinner()
                Toast(text: "SuccessFully register").show()
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self.hideCentralSpinner()
                switch error{
                case .internalError:
                    Toast(text: "Something went wrong.").show()
                case .serverError:
                    Toast(text: "Server issue.").show()
                case .parsingError:
                    Toast(text: "Something went wrong.").show()
                }
                print("-------\(error.localizedDescription)")
            default:
                print("Default")
            }
        }
    }
}

//MARK: - Validation
extension RegisterVC {
    
    func isValid() -> (valid: Bool, error: String) {
        var result = (valid: true, error: "")
        if String.validate(value: txtName.text) {
            result.valid = false
            result.error = "Please enter zipcode."
            return result
        }else if String.validate(value: txtEmail.text) {
            result.valid = false
            result.error = "Please enter email address."
            return result
        }else if !txtEmail.text!.isEmailAddressValid {
            result.valid = false
            result.error = "Please enter valid email address."
            return result
        }else if String.validate(value: txtPassword.text) {
            result.valid = false
            result.error = "Please enter password name."
            return result
        }else if String.validate(value: txtConfirmPassword.text) {
            result.valid = false
            result.error = "Please enter confirm password name."
            return result
        }else if txtPassword.text != txtConfirmPassword.text{
            result.valid = false
            result.error = "Your password and confirm password does not match."
            return result
        }
        return result
    }
}
