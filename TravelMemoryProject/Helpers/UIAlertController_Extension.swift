//
//  UIAlert_Extension.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 08/12/22.
//


import UIKit

extension UIAlertController {
    
    static func presentActionSheet(options: [String], in vc: UIViewController, completedAction: @escaping (String) -> ()) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for option in options {
            let action = UIAlertAction(title: option, style: .default) { (action) in
                completedAction(option)
                    completedAction(option)
            }
            alert.addAction(action)
        }
        if Device.isPhone {
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
