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
    
    var boxKey: String! {
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
    
    var boxLocationName:String? {
        return _boxLocationName
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
 
    func removeItemDetailsFromBox()  {
        print("  removeItemDetailsFromBox")
        _boxRef.child("items").removeValue()

    }
 
    
    func AddItemDetailsToBox(item:Item) {
        
        _boxRef.child("items/\(item.itemKey)").setValue([
            item.itemName
            ])

    }
    

    
    
} // class
 
