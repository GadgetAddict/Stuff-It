//
//  Box.swift
//  Inventory
//
//  Created by Michael King on 4/1/16.
//  Copyright © 2016 Michael King. All rights reserved.
//

import Foundation
import Firebase

class Box  {
    private var _boxKey: String!
    private var _boxNumber: Int!
    private var _boxQR: String?
    private var _boxFragile: Bool!
    private var _boxStackable: Bool!
    private var _boxCategory: String!
    private var _boxName: String?
    private var _boxLocationName: String?
    private var _boxLocationDetail: String?
    private var _boxLocationArea: String?
    private var _boxStatus: String?
    private var _boxColor: String?
    private var _boxRef: FIRDatabaseReference!
  
    var boxItemCount: Int?
    
    var boxKey: String {
        return _boxKey
    }
    
    var boxQR: String? {
        return _boxQR
    }
    var boxNumber:Int! {
        return _boxNumber
    }
    
    var boxFragile:Bool {
        return _boxFragile
    }
    
    var boxStackable:Bool {
        return _boxStackable
    }
    
    var boxCategory:String? {
        return _boxCategory
    }

    var boxName:String? {
        return _boxName
    }
    
   
    var boxLocationDetail:String? {
        return _boxLocationDetail
    }
    
    var boxLocationArea:String? {
        return _boxLocationArea
    }
    
    var boxStatus:String? {
        return _boxStatus
    }
    
    var boxColor:String? {
        return _boxColor
    }
 
 

    //    MARK: Getters and Setters
    
    var boxLocationName:String? {
        get {
            return _boxLocationName
        }
        set {
            _boxLocationName = newValue
        }
    }
    

    
    
    
    init(location: String!, area: String?, detail: String?) {
   
        self._boxLocationName = location
        
        if let locArea = area {
            self._boxLocationArea = locArea
        }
        if let locDetail = detail {
            self._boxLocationDetail = locDetail
        }
        
    }
 
    
    
    
  /*  init(number: String, fragile: Bool, stackable: Bool,  category: String,  description: String, located : String, locDetail: String, locArea : String) {
        self._boxNumber = boxNumber
        self._boxFragile = fragile
        self._boxStackable = stackable
        self._boxCategory = category
        self._boxName = description
        self._boxLocationName = located
        self._boxLocationDetail = locDetail
        self._boxLocationArea = locArea
    }
    */
    
    init() {
        
    }
    
    
    init (boxKey: String){
        self._boxKey = boxKey
         _boxRef = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes/\(boxKey)")
    }
    
    
    init (boxKey: String, dictionary: Dictionary <String, AnyObject>) {
        self._boxKey = boxKey
        
        if let fragile = dictionary["fragile"] as? Bool {
            self._boxFragile = fragile
        }
        
        if let stackable = dictionary["stackable"] as? Bool {
            self._boxStackable = stackable
        }
        
        if let category = dictionary["boxCategory"] as? String {
            self._boxCategory  =  category
        }
        
        if let name = dictionary["name"] as? String {
            self._boxName  =  name
        }
        
        if let boxNumber = dictionary["boxNum"] as? Int {
             self._boxNumber = boxNumber
        }
        
        if let boxQR = dictionary["boxQR"] as? String {
            self._boxQR = boxQR
        }
        
        if let located = dictionary["location"] as? String {
            self._boxLocationName = located
        }
        
        if let locDetail = dictionary["location_detail"] as? String {
              self._boxLocationDetail = locDetail
        }
        
        if let locArea = dictionary["location_area"] as? String {
              self._boxLocationArea = locArea
        }
        
        if let status = dictionary["status"] as? String {
            self._boxStatus = status
        }
        
        if let color = dictionary["color"] as? String {
            self._boxColor = color
        }
        
        _boxRef = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes/\(boxKey)")
        
     }
 
    func removeItemDetailsFromBox(itemKey: String)  {
         _boxRef.child("items/\(itemKey)").removeValue()
 
    }
 
    
    func addItemDetailsToBox(itemDict:Dictionary<String, AnyObject>) {
  
            if let itemKey = itemDict["itemKey"], let itemName = itemDict["itemName"], let boxKey =  itemDict["itemBoxKey"] {

        _boxRef = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes/\(boxKey)/items/\(itemKey)")

        _boxRef.setValue([
            "itemName" :  itemName
            ])
 
        } else {
            print("One or more of the optionals don’t contain a value")
        }

    }
    
    
    func saveBoxToFirebase(boxKey: String, boxDict:Dictionary<String, AnyObject>, completion: () -> ()) {
        
        let ref = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes/\(boxKey)")
        
        //        let updatedItemData = ["\(itemKey)": itemDict]  as [String : Any]
        
        
        ref.updateChildValues(boxDict, withCompletionBlock: { (error, ref) -> Void in
            if ((error) != nil) {
                print("Error updating data: \(String(describing: error?.localizedDescription))")
                
            }
        })
        
        completion()
    }

    
    
} // class
 
