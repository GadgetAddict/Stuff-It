//
//  RoundCircleButton.swift
//  Stuff-It
//
//  Created by Michael King on 5/5/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

@IBDesignable

class RoundCircleButton: UIButton {
   
    
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
