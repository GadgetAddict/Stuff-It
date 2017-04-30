//
//  RoundView.swift
//  Stuff-It
//
//  Created by Michael King on 4/27/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

class RoundView: UIView {
    
    override func awakeFromNib() {

    layer.cornerRadius = self.frame.width / 2
    clipsToBounds = true
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
