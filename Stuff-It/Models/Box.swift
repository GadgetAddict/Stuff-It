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
 
    
 
    
    init() {}
        
    
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
        
        _boxRef = DataService.ds.REF_INVENTORY.child("boxes/\(boxKey)")
        
     }
 
    func removeItemDetailsFromBox(itemKey: String)  {
        print("Box Model: removeItemDetailsFromBox")
         _boxRef.child("items/\(itemKey)").removeValue()
 
    }
 
    

    
    func addItemDetailsToBox(itemKey: String) {
        print("Box Model: addItemDetailsToBox")

        _boxRef = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes/\(boxKey)/items")

        _boxRef.setValue([
            itemKey :  true
            ])
  
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
    
//    generate next box number
  func getBoxNumber() {
    print("Box Model: getBoxNumber")
    let REF_BOXES = DataService.ds.REF_INVENTORY.child("boxes")
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
 
//    MARK: When In Box, and adding new items, if none match the category, show the overlyay.
//    Count Total Items and Then Count Items that are not stored in THIS Specific Box
//    if there are more items not boxed, even though they dont match the same box category, show the button to view those items
    func countItemsNotInBox( completion: @escaping (Bool) -> ()) {
        print("Box Model: countItemsNotInBox")

            let REF = DataService.ds.REF_INVENTORY.child("items")
       
        var itemCount: Int!
        REF.observeSingleEvent(of: .value, with:{ (snapshot: FIRDataSnapshot!) in
              itemCount = Int(snapshot.childrenCount)
            print("FIRST itemCount is \(itemCount)")
       
         
//            let dataRef = REF.child("box")
            let queryRef1 = REF.queryOrdered(byChild: "box/itemBoxKey")
            let queryRef2 = queryRef1.queryEqual(toValue: self._boxKey)
            queryRef2.observeSingleEvent(of: .value, with: { snapshot in
//                print(snapshot.childrenCount)
                let itemsInThisBox = Int(snapshot.childrenCount)
                 completion(itemsInThisBox < itemCount)
            })
  
           
        
        })
 }
    
//    func getBox(){
//        _boxRef.observe(.value, with: { snapshot in
//            if let boxSnapshotDict = snapshot.value as? Dictionary<String, AnyObject> {
//                let box = Box(boxKey: self.boxKey, dictionary: boxSnapshotDict)
//                
//                
//                }
//            })
        

} // class

