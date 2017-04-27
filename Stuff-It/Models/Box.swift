//
//  Box.swift
//  Inventory
//
//  Created by Michael King on 4/1/16.
//  Copyright © 2016 Michael King. All rights reserved.
//

import Foundation
import Firebase

class BoxedItems: Item {

    
    
}


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
    var boxItemsKeys: [String]?
    
    
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
    
    var boxKey: String {
     
        get {
            return _boxKey
        }
        set {
            _boxKey = newValue
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
 
    
 
    
    init() {
        
    }
    
    
    init (boxKey: String, boxNumber: Int?){
        
       
            self._boxKey = boxKey
        
        
        if let number = boxNumber {
            self._boxNumber = number
        }
        
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
        print("removeItemDetailsFromBox")
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
        ref.updateChildValues(boxDict, withCompletionBlock: { (error, ref) -> Void in
            if ((error) != nil) {
                print("Error updating data: \(String(describing: error?.localizedDescription))")
            }
        })
        completion()
    }
    
  func getBoxNumber() {
    let REF_BOXES = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes")
    self._boxNumber = 1
        REF_BOXES.queryOrdered(byChild: "boxNum").queryLimited(toLast: 1).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            if let boxSnapshot = snapshot.value as? Dictionary<String, AnyObject> {
                if let boxNum = boxSnapshot["boxNum"] as? Int   {
                    let newBoxNumber = (boxNum + 1)
                    self._boxNumber = newBoxNumber
                }
            }
        })
    }

} // class

