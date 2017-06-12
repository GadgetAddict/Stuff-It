//
//  AddItemsToBoxCell.swift
//  Stuff-It
//
//  Created by Michael King on 5/23/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher


class AddItemsToBoxCell: UITableViewCell, UINavigationControllerDelegate  {
    
        
        var item: Item!
        var url: URL?
        
        @IBOutlet weak var nameLbl: UILabel!
        @IBOutlet weak var categoryLbl: UILabel!
        @IBOutlet weak var subCategoryLbl: UILabel!
        @IBOutlet weak var imageThumb: UIImageView!
        @IBOutlet weak var boxNumberLbl: UILabel!
        @IBOutlet weak var imgFragile: UIImageView!
        @IBOutlet weak var qty: UILabel!
        
        override func awakeFromNib() {
            super.awakeFromNib()
            
            
        }//awakeFromNib
        
        
        func configureCell(item: Item) {
            
            
            if let itemUrl = item.itemImgUrl {
                url = URL(string:itemUrl)
            }
            
            imageThumb.kf.indicatorType = .activity
            
            //        let processor = RoundCornerImageProcessor(cornerRadius: imageThumb.frame.height / 2.0)
            //        let processor = OverlayImageProcessor(overlay: .red, fraction: 0.7)
            imageThumb.kf.setImage(with: self.url ,
                                   placeholder: nil,//UIImage(named: "qrBoxLogoV2_stroke"),
                options: [ .transition(ImageTransition.fade(3))] )
            
            
            
            //
            //                                    progressBlock: { receivedSize, totalSize in
            //                                         let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
            //                                         print("downloading progress: \(percentage)%")
            //                                         myIndicator.percentage = percentage
            // },
            //                                    completionHandler: { image, error, cacheType, imageURL in
            //                                        })
            //
            
            
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
            
            //        if let itemIsBoxed = item.itemIsBoxed {
            //            self.boxNumberLbl.isHidden = !itemIsBoxed
            //
            //        } else {
            //            self.boxNumberLbl.isHidden = true
            //        }
            
            self.boxNumberLbl.isHidden = !self.item.itemIsBoxed!
            
            if let boxNumber = item.itemBoxNum {
                self.boxNumberLbl.text = "Box  \(boxNumber)"
                
            }
            
            //        if let URL = item.itemImgUrl {
            //            let ref = FIRStorage.storage().reference(forURL: URL)
            //            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            //                if error != nil {
            //                    print("MK: Unable to download image from Firebase storage")
            //                } else {
            //                    print("MK: Image downloaded from Firebase storage")
            //                    if let imgData = data {
            //
            //    
            //                        if let img = UIImage(data: imgData) {
            //                          DispatchQueue.main.async {
            //                            self.imageThumb.image = img
            //                            itemFeedVC.imageCache.setObject(img, forKey: URL as NSString)
            //                            }
            //                            }
            //                        }
            //                    }
            //                })
            //            }
            
            
        }//ConfigureCell
        
}//ItemCell class









