//
//  OptionsPopup.swift
//  Stuff-It
//
//  Created by Michael King on 6/3/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import DLRadioButton

class OptionsPopup: UIViewController {

    var category: String!
    @IBOutlet weak var ByCategory: DLRadioButton!
    @IBOutlet weak var AnyCategory: DLRadioButton!

    override func viewDidLoad() {
        super.viewDidLoad()
print("the OptionsPopOver got your string: \(category)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func categoryPressed(_ sender: Any) {
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
