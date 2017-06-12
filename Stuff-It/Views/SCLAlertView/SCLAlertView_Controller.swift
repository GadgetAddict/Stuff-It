//
//  SCLAlertView_Controller.swift
//  Stuff-It
//
//  Created by Michael King on 6/9/17.
//  Copyright © 2017 Microideas. All rights reserved.
//


enum MessageType: CustomStringConvertible {
    case addToBox, noResults, categoryMisMatch, objIsItemMstBeBox, qrTaken, iFailed
    var description: String {
        switch self {
            
        case .addToBox: return "Choose a method below."
            
            
            //Errors
            
        //nothing found -create new item or box ?
        case .noResults: return "No Item or Box Exists with this QR Code"
            
        //item and box categories dont match- want to allow anyways?mixedContent?
        case .categoryMisMatch: return "Item and Box Category do not match. Add Item to Box anyway?"
            
            
        //cannot store item in an item
        case .objIsItemMstBeBox: return "This is not a Box. Please try again."
            
        //cannot assign new item to existing item- un-assign this item?
        case .qrTaken: return "This QR code is in use."
            
            
        //catch all
        case .iFailed: return "Please try again."
            
            
        }
    }
}
// trying to make all the alerts I would use - but i cannot add the targets here.

// finish later 

/*
class SCLAlertView_Controller {
    
    enum MessageType: CustomStringConvertible {
        case addToBox, noResults, categoryMisMatch, objIsItemMstBeBox, qrTaken, iFailed
        var description: String {
            switch self {
                
            case .addToBox: return "Choose a method below."

                
                //Errors
                
                //nothing found -create new item or box ?
            case .noResults: return "No Item or Box Exists with this QR Code"
          
            //item and box categories dont match- want to allow anyways?mixedContent?
            case .categoryMisMatch: return "Item and Box Category do not match. Add Item to Box anyway?"

                
             //cannot store item in an item
            case .objIsItemMstBeBox: return "This is not a Box. Please try again."
           
            //cannot assign new item to existing item- un-assign this item?
            case .qrTaken: return "This QR code is in use."

            
            //catch all
            case .iFailed: return "Please try again."

                
            }
        }
    }
    
    enum Icon: String {
        case boxSearch = "boxSearch"
        case qrScan
    }
    
     let alertBlueColor: UInt =  0x00A1FF
    var alertTitle: String!
    var alertSubtitle: String!

    func showAssignBoxAlert(alreadyBoxed: Bool){
        if alreadyBoxed{
            
        } else {
            
        }
        
    
    }
    
    
    func showAlert(errorMessage: MessageType)  {
        
        let action: MessageType = .addToBox
        action.description
        
        
     let alert = SCLAlertView()
    _ = alert.addButton("Add Anyway") {
    
    }

    
    DispatchQueue.main.async {
    _ = alert.showItemAssignBox(editBoxAlertTitle, subTitle: editBoxAlertSub, closeButtonTitle: "Cancel", icon: icon!, colorStyle: editBoxColor )
    }

    }

    func showWarning(){
            _ = SCLAlertView().showWarning(kWarningTitle, subTitle: kSubtitle)
        }
    }


}


*/
