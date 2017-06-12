//
//  LabelView.swift
//  Stuff-It
//
//  Created by Michael King on 4/30/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

 

class ItemDetailsNameLabel: UITextField {
    override func awakeFromNib() {
        textColor = labelColor
        font = UIFont(name: SFDThin, size: 28)
    }
}


class ItemDetailsHeadersLabel: UILabel {
    override func awakeFromNib() {
        textColor = labelColor
        font = UIFont(name: SFTMedium, size: 13)
    }
}


class ItemDetailsLabel: UILabel {
    override func awakeFromNib() {
        textColor = labelColor
        font = UIFont(name: SFDThin, size: 24)
    }
}


class BoxDetailsNameLabel: UITextField {
    override func awakeFromNib() {
        textColor = labelColor
        font = UIFont(name: SFDThin, size: 28)
    }
}


class BoxDetailsHeadersLabel: UILabel {
    override func awakeFromNib() {
        textColor = UIColor.lightGray
        font = UIFont(name: SFTMedium, size: 13)
    }
}

class BoxDetailsLabel: UILabel {
    override func awakeFromNib() {
        textColor = UIColor.lightGray
        font = UIFont(name: SFDThin, size: 24)
    }
}

class BoxDetailsLocationLabel: UILabel {
    override func awakeFromNib() {
        textColor = UIColor.lightGray
        font = UIFont(name: SFDThin, size: 20)
    }
}
