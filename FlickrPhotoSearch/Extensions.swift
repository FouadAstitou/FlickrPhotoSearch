//
//  Extensions.swift
//  FlickrPhotos
//
//  Created by Supervisor on 22-03-17.
//  Copyright © 2017 Nerdvana. All rights reserved.
//

import UIKit

// Shows an alert with title, message and an ok action.
extension UIViewController {
    func showAlertWith(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
