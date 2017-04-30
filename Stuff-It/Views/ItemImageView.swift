//
//  ItemImageView.swift
//  Stuff-It
//
//  Created by Michael King on 4/21/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

class ItemImageUIView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
            // shadow
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 3, height: 3)
            layer.shadowOpacity = 0.7
            layer.shadowRadius = 4.0
            layer.cornerRadius = frame.height / 2.0

    }
}

class ItemImageView: UIImageView {
    
    override func awakeFromNib() {
        // border
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
//        Corners
        layer.cornerRadius = frame.height / 2.0
        clipsToBounds = true

    }
}

//   layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: 10).cgPath
//        layer.shouldRasterize = true
//        layer.rasterizationScale = UIScreen.main.scale

