//
//  ReachabilityHelper.swift
//  RecyQ
//
//  Created by Supervisor on 22-02-17.
//  Copyright © 2017 Jimsalabim. All rights reserved.
//

import UIKit

struct ReachabilityHelper {
    
    private static let reachability = Reachability.init()
    
    static func checkReachability(viewController: UIViewController) {
        
        reachability!.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        reachability!.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                print("Not reachable")
                
                let alert = UIAlertController(title: "Oeps!", message: "Please connect to the internet to use the RecyQ app.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Ok", style: .default) { (action: UIAlertAction) -> Void in
                }
                alert.addAction(okayAction)
                viewController.present(alert, animated: true, completion: nil)
            }
        }
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}
