//
//  NeedToLoginPopUpVC.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 18/01/23.
//

import UIKit

class NeedToLoginPopUpVC: UIViewController {
    
    var completionHandler : ((Bool) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}

//MARK: - UI Method
extension NeedToLoginPopUpVC {
    func handler(handler: @escaping ((Bool) -> ())) {
        completionHandler = handler
    }
}

//MARK: - Action Method
extension NeedToLoginPopUpVC {
    
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        completionHandler?(false)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnOkTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        completionHandler?(true)
    }
}
