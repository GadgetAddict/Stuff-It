//
//  PlaygroundTableCell.swift
//  Stuff-It
//
//  Created by Michael King on 4/13/17.
//  Copyright © 2017 Microideas. All rights reserved.
//


import UIKit
import Firebase

class PlaygroundTableCell: UITableViewCell, UINavigationControllerDelegate {
    
    
     var item: Item!
    
    @IBOutlet weak var itemLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }//awakeFromNib
    
    
    func configureCell(item: Item) {
        print("Configure Cell: Got the itemName: \(item.itemName)")
        self.item = item
        self.itemLabel.text = item.itemName
        
        
    }//ConfigureCell
    
    
    
//    func configureCell(workout: Workout) {
//        self.workout = workout
//        self.itemLabel.text = workout.title
//        
//        
//    }//ConfigureCell
    
    
    
    
    
}


