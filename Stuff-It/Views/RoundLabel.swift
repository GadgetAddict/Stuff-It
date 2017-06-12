//
//  BoxNumberLabel.swift
//  Inventory17
//
//  Created by Michael King on 3/23/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit


@IBDesignable

class RoundLabel: UILabel {
    
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    
    
}

 

//        override func draw(_ rect: CGRect) {

//     layer.cornerRadius = 25
//    layer.borderWidth = 3.0
//   layer.backgroundColor = UIColor.clear.cgColor
//    layer.borderColor = UIColor.brown.cgColor
        
