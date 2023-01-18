//
//  EnterNamePopupVC.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 18/01/23.
//

import UIKit
import TextFieldEffects

class EnterNamePopupVC: UIViewController {
    @IBOutlet weak var txtEnterName: HoshiTextField!
    var completionHandler : ((String) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func handler(handler: @escaping ((String) -> ())) {
        completionHandler = handler
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
//MARK: - Action Method
extension EnterNamePopupVC {
    
    @IBAction func btnOkTapped(_ sender: UIButton) {
        let result = isValid()
        if result.valid {
            if let text = txtEnterName.text {
                navigationController?.dismiss(animated: true, completion: nil)
                completionHandler?(text)
            }
        }
    }
    
}

//MARK: - Validation
extension EnterNamePopupVC {
    
    func isValid() -> (valid: Bool, error: String) {
        var result = (valid: true, error: "")
        if String.validate(value: txtEnterName.text) {
            result.valid = false
            result.error = "Please enter filename to save in Database."
            return result
        }
        return result
    }
    
}
