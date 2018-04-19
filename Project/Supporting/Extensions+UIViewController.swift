//
//  Extensions+UIViewController.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/19/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import Foundation

extension UIViewController{
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel){_ in
            self.dismiss(animated: true, completion: nil)
        })
        
        present(alert, animated: true, completion: nil)
    }
}
