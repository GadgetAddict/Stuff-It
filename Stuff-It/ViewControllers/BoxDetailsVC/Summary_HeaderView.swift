//
//  Summary_HeaderView.swift
//  Stuff-It
//
//  Created by Michael King on 5/2/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

class Summary_HeaderView: UIView {
    
    var modelController: ModelController!
    var box: Box!
    
    @IBOutlet weak var boxNameLabel: UILabel!
    @IBOutlet weak var boxNumberLabel: UILabel!
    @IBOutlet weak var boxLocationLabel: UILabel!
    @IBOutlet weak var boxLocationAreaLabel: UILabel!
    @IBOutlet weak var boxLocationDetailLabel: UILabel!
    @IBOutlet weak var boxCategoryLabel: UILabel!
    @IBOutlet weak var boxStatusLabel: UILabel!
    

    func updateLabels(box: Box)  {
        
    self.box = box
    boxNameLabel.text = self.box.boxName ?? "No Name"
    boxNumberLabel.text = "\(self.box.boxNumber)"
    boxLocationLabel.text = self.box.boxLocationName ?? "No Location"
    boxLocationAreaLabel.text = self.box.boxLocationArea ?? ""
    boxLocationDetailLabel.text = self.box.boxLocationDetail ?? ""
        
    }
    
    
    
}
