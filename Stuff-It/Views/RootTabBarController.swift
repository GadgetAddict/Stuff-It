//
//  RootTabBarController.swift
//  Stuff-It
//
//  Created by Michael King on 5/16/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController, UITabBarControllerDelegate {

    var passingString: String!
    var passingQR = QR()
 
    var fromQrScanner: Bool = false
    
    override func viewDidLoad() {
        self.delegate = self
    }
    
}
