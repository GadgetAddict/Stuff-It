//
//  CategoryPickerCell.swift
//  Inventory17
//
//  Created by Michael King on 2/16/17.
//  Copyright © 2017 Microideas. All rights reserved.
//



import Firebase
import UIKit

class CategoryPickerCell: UITableViewCell, UINavigationControllerDelegate {
    
    var category: Category!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }//awakeFromNib
    
    
    func configureCell(category: Category, categoryType:CategoryType) {
        
        switch categoryType {
        case .Category :
            print("configureCell cat ")
            self.categoryLabel.text = category.category
            
        case .Subcategory:
            print("configureCell subcat")
            self.categoryLabel.text = category.subcategory
            
        }
        
        
        
    }//ConfigureCell
    
}


    
