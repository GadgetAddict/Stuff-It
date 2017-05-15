//
//  AppDelegate.swift
//  Inventory17
//
//  Created by Michael King on 1/15/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
//        if let loginController = window?.rootViewController as? LoginViewController {
//            print(" we setup the model controller")
//              loginController.modelController = ModelController()
//        }
       
        FIRApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
//        https://firebase.google.com/docs/database/ios/offline-capabilities#section-connection-state
      
//        FIRDatabase.database().persistenceEnabled = true
        
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("Connected")
            } else {
                print("Not connected")
            }
        })
        UISearchBar.appearance().barTintColor = UIColor.candyBlue()
        UISearchBar.appearance().tintColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.candyBlue()
        return true
    }
    
    func switchViewControllers(storyBoardID: String) {
        
        // switch root view controllers
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: storyBoardID)
        
        self.window?.rootViewController = nav
        
    }
    
  
    
}


//extension UIColor {
//    static func candyBlue() -> UIColor {
//        return UIColor(red: 0.0/255.0, green: 190.0/255.0, blue: 255.0/255.0, alpha: 1.0)
// }
//}
