//
//  ItemImageView.swift
//  Stuff-It
//
//  Created by Michael King on 4/21/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

class ItemImageView: UIImageView {

    override func layoutSubviews() {
            layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
            layer.shadowOpacity = 0.8
            layer.shadowRadius = 5.0
            layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
//        layer.cornerRadius = self.frame.width / 2
//        clipsToBounds = true
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
//    layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
//    layer.shadowOpacity = 0.8
//    layer.shadowRadius = 5.0
//    layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
//    
    
}
