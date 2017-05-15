//
//  NavBarView.swift
//  Stuff-It
//
//  Created by Michael King on 5/8/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

class NavBarView: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigation bar tint / background colour
        UINavigationBar.appearance().barTintColor = UIColor.candyBlue()
        
        // Set Navigation bar Title colour
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        // Set navigation bar ItemButton tint colour
        UIBarButtonItem.appearance().tintColor = UIColor.white
        
        // Set Navigation bar background image
//        let navBgImage:UIImage = UIImage(named: “bg_blog_navbar_reduced.jpg”)!
//        UINavigationBar.appearance().setBackgroundImage(navBgImage, forBarMetrics: .Default)
        
        //Set navigation bar Back button tint colour
        UINavigationBar.appearance().tintColor = UIColor.white  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

