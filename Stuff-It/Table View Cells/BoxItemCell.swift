//
//  BoxItemCell.swift
//  Inventory17
//
//  Created by Michael King on 2/24/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Kingfisher
import SwipeCellKit



class BoxItemCell: UITableViewCell {
    
      @IBOutlet weak var rowLabel: UILabel!
 
    
    
    
    @IBOutlet weak var checkMarkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
 
        
        
        
        var item: Item!
        var url: URL?
        
        @IBOutlet weak var nameLbl: UILabel!
        @IBOutlet weak var categoryLbl: UILabel!
        @IBOutlet weak var subCategoryLbl: UILabel!
        @IBOutlet weak var imageThumb: UIImageView!
        @IBOutlet weak var boxNumberLbl: UILabel!
        @IBOutlet weak var imgFragile: UIImageView!
        @IBOutlet weak var qty: UILabel!
        
    
        
        
        func configureCell(item: Item) {
            
            
            if let itemUrl = item.itemImgUrl {
                url = URL(string:itemUrl)
            }
            
            imageThumb.kf.indicatorType = .activity
            imageThumb.kf.setImage(with: self.url ,
                                   placeholder: nil,
                                   options: [ .transition(ImageTransition.fade(3))] )
            
            
            self.item = item
            
            
            
            if let qty = item.itemQty {
                self.qty.text = "\(qty)"
            } else {
                self.qty.text = "   "
            }
            
            self.nameLbl.text = item.itemName.capitalized
            
            if let category = item.itemCategory {
                self.categoryLbl.text = category.capitalized
            } else {
                self.categoryLbl.text = nil
            }
            
            if let subcategory = item.itemSubcategory {
                self.subCategoryLbl.text = ": \(subcategory.capitalized)"
            } else {
                self.subCategoryLbl.text = nil
            }
            
            
            //check if fragile, show image or don't
            if item.itemFragile == false {
                self.imgFragile.isHidden = true
            }else{
                self.imgFragile.isHidden = false
                
            }
        
            
            self.boxNumberLbl.isHidden = !self.item.itemIsBoxed!
            
            if let boxNumber = item.itemBoxNum {
                self.boxNumberLbl.text = "Box  \(boxNumber)"
                
            }
   
            
        }//ConfigureCell
        
}









