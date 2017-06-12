//
//  Constants.swift
//  Pods
//
//  Created by Michael King on 12/21/16.
//
//

import UIKit
import FirebaseDatabase


 
let SHADOW_COLOR:CGFloat = 157.0 / 255.0
let SHADOW_GRAY: CGFloat = 120.0 / 255.0
 

var COLLECTION_ID: String!

enum tableLoadingStatus {
    case loading
    case finished
}


let labelColor: UIColor = .darkGray

//MARK: Font Names

let SFDLight = "SFUIDisplay-Light"
let SFDThin = "SFUIDisplay-Thin"
let SFDRegular = "SFUIDisplay-Regular"
let SFTLight = "SFUIText-Light"
let SFTMedium = "SFUIText-Medium"
let SFTRegular = "SFUIText-Regular"

extension UIColor {
    static func candyBlue() -> UIColor {
        return UIColor(red: 0.0/255.0, green: 190.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
}
