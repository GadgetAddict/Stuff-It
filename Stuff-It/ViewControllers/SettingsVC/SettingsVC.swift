//
//  mainMenuVC.swift
//  Inventory
//
//  Created by Michael King on 4/15/16.
//  Copyright © 2016 Michael King. All rights reserved.
//


import UIKit
import Firebase

class SettingsVC: UITableViewController, SegueHandlerType {

    
    enum SegueIdentifier: String {
        case Color
        case Location
        case Status
        case Category
        case QR
        case Logout
        case playTable
        case playItemsFeed2
    }
    
        override func viewDidLoad() {
        super.viewDidLoad()
                    

     }//end ViewDidLoad
    
//    Add this to make the table cell separator fill entire width of table
      func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }

    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
}
    

    @IBAction func unwindCancelToSettings(_ segue:UIStoryboardSegue) {
    }
    
    
    @IBAction func unwindLocationsToSettings(_ segue:UIStoryboardSegue) {
    
    
    }
    
    @IBAction func resetWalkThrough(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "hasViewedWalkThrough")
        print("UserDefaults.standard reset")

    }
    
    @IBAction func signOut_Tapped(_ sender: UIBarButtonItem) {
            COLLECTION_ID = nil
            print("LOGOUT Gesture Tapped")
//        let defaults = UserDefaults.standard
        
        
//        if (defaults.object(forKey: "CollectionIdRef") != nil) {
//            if let collectionId = defaults.string(forKey: "CollectionIdRef") {
//                 print("Collection ID is \(collectionId)")
//            } else {
//            print("Collection ID is nil")
//            }
//            
//        }
//
//        
//        if (defaults.object(forKey: "CollectionName") != nil) {
//            if let CollectionName = defaults.string(forKey: "CollectionName") {
//                print("CollectionName ID is \(CollectionName)")
//            } else {
//                print("CollectionName ID is nil")
//            }
//            
//        }

        

            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                
                COLLECTION_ID = nil
                
//                defaults.set(nil, forKey: "CollectionIdRef")
//                defaults.set(nil, forKey: "CollectionName")
                COLLECTION_ID = nil
                performSegueWithIdentifier(segueIdentifier: .Logout, sender: self)
                
            } catch let signOutError as NSError {
                print ("Error signing out: \(signOutError.localizedDescription)")
            }
 
    
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
             
            switch segueIdentifierForSegue(segue: segue) {
            case .Category:
                if let categoryDetails = segue.destination as? CategoryDetailsVC {
                    categoryDetails.categorySelectionOption = .settings
                }
            case .Color:
                if let colorsVC = segue.destination as? ColorTableVC {
                    colorsVC.colorLoadsFrom = .settings
                }
            case .Location:
                if let locationsVC = segue.destination as? LocationDetailsVC {
                    locationsVC.locationSelection = .settings
                }
            case .Status:
                  print("")
            default:
                print("")
                
                
            }
        }
        
        
  /*  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepareForSegue FROM SETTINGS")
        
        if let colorsVC = segue.destination as? ColorTableVC {
            colorsVC.colorLoadsFrom = .settings
        } else {
        
            if segue.identifier == "locationSettings" {
                print("Going to locationSettings ")
                
                if let locationsVC = segue.destination as? LocationDetailsVC {
                        locationsVC.locationSelection = .settings
                 }
            } else {
        
         if segue.identifier == "categorySettings" {
            print("segue.identifier to cats from settings")
        if let categoryDetails = segue.destination as? CategoryDetailsVC {
                print("going to cats from settings")

                    categoryDetails.categorySelectionOption = .settings
            }
                }
        }
        }
     */
    
    
    
        var curPage = "SettingsVC"

    
    

}

