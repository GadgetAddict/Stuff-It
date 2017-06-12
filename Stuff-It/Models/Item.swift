//
//  Item.swift
//  Inventory17
//
//  Created by Michael King on 1/20/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import Foundation
import Firebase

 

class Item  {
 
    
     private var _itemKey: String!
    private var _itemImgUrl: String?
//    private var _imageType: itemImageType!
    private var _itemName:String!
    private var _itemNotes: String?
    private var _itemCategory: String?
    private var _itemSubcategory: String?
    private var _itemBoxNum: String?
    private var _itemBoxKey: String?
    private var _itemBoxLocationName: String?
    private var _itemBoxLocationArea: String?
    private var _itemBoxLocationDetail: String?

    private var _itemIsBoxed: Bool?
    private var _itemQty: String?
    private var _itemFragile: Bool!
    private var _tags: [String]?
    private var _itemQR: [String]?
    private var _itemRef: FIRDatabaseReference!
    
    
    var itemKey: String {
        return _itemKey
    }
    
    
    var itemName: String {
        return _itemName
    }
    

    var itemImgUrl: String? {
        return _itemImgUrl
    }
    
    var itemNotes: String? {
        return _itemNotes
    }
  
    
    var itemCategory: String? {
         get {
            return _itemCategory
        }
        set {
            _itemCategory = newValue
        }
    }
    
    
    var itemSubcategory: String? {
        get {
            return _itemSubcategory
    }
        set{
             _itemSubcategory = newValue
        }
    }
    
    

    var itemIsBoxed: Bool?  {
        get {
            return _itemIsBoxed
        }
        set {
            _itemIsBoxed = newValue
        }
    }

    var itemBoxNum: String? {
        
        get {
            return _itemBoxNum
        }
        set {
            _itemBoxNum = newValue
        }
    }
    
    var itemBoxKey: String? {
        
        get {
            return _itemBoxKey
        }
        set {
            _itemBoxKey = newValue
        }
    }
    
    var itemBoxLocationName: String? {
        
        get {
            return _itemBoxLocationName
        }
        set {
            _itemBoxLocationName = newValue
        }
    }
    
    var itemBoxLocationArea: String? {
        
        get {
            return _itemBoxLocationArea
        }
        set {
            _itemBoxLocationArea = newValue
        }
    }
    
    var itemBoxLocationDetail: String? {
        
        get {
            return _itemBoxLocationDetail
        }
        set {
            _itemBoxLocationDetail = newValue
        }
    }
    
    
    
    var itemQty: String! {
        return _itemQty
    }
    
    var itemFragile: Bool {
        return _itemFragile
    }
    
    var tags: [String]? {
        return _tags
    }
    
    var itemQR: [String]? {
        return _itemQR
    }
 
    
    init(itemName: String, itemCat: String, itemSubcat: String) {
        
        self._itemName = itemName
        self._itemCategory = itemCat
        self._itemSubcategory = itemSubcat
        
     
    }

    init(itemKey: String?, itemBoxed: Bool?, itemCategory: String?) {
       
        if let key = itemKey {
           self._itemKey = key
        _itemRef = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items/\(key)")

        }
        
        if let isBoxed = itemBoxed {
            self._itemIsBoxed = isBoxed
        }
        
        if let category = itemCategory {
            self._itemCategory = category
        }
       
    }
    
    
    init(itemKey: String, dictionary: Dictionary <String, AnyObject> ) {
        self._itemKey = itemKey
 
        
        if let itemImgUrl = dictionary["imageUrl"] as? String {
            self._itemImgUrl = itemImgUrl
        }
        if let itemName = dictionary["itemName"] as? String {
            self._itemName = itemName
        }
        
        if let notes = dictionary["itemDescript"] as? String {
            self._itemNotes = notes
        }
        if let category = dictionary["itemCategory"] as? String {
            self._itemCategory = category
        }
        if let subcategory = dictionary["itemSubcategory"] as? String {
            self._itemSubcategory = subcategory
        }
        if let itemIsBoxed = dictionary["itemIsBoxed"] as?  Bool {
            self._itemIsBoxed = itemIsBoxed
        }
        if let itemBoxNum = dictionary["itemBoxNumber"] as? String {
            self._itemBoxNum = itemBoxNum
        }
        if let itemBoxKey = dictionary["itemBoxKey"] as? String {
            self._itemBoxKey = itemBoxKey
        }
        if let qty = dictionary["itemQty"] as? String {
            self._itemQty = qty
        }
        if let fragile = dictionary["itemFragile"] as? Bool {
            self._itemFragile = fragile
        }
   
        if let tags = dictionary["tags"] as? [String] {
            self._tags = tags
        }
        if let itemQR = dictionary["itemQR"] as? [String] {
            self._itemQR = itemQR
        }
        
        _itemRef = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items/\(itemKey)")
    }

     
    
    
    func removeBoxDetailsFromItem()  {
        print("From: \(self.curPage) ->  REMOVING THE ITEM ")
              _itemRef.child("box").setValue([
                "itemIsBoxed" : false
            ])

        
    }


    func addBoxDetailsToItem(box: Box) {
        print("  AddBoxDetailsToItem in Firebase - The Item REF is : \(_itemRef.child("box"))")

        _itemRef.child("box").setValue([
        "itemBoxKey" : box.boxKey,
        "itemBoxNumber" : String(box.boxNumber),
        "itemIsBoxed" : true
        ])
        print("  Add BoxDetails ToItem MODEL")

        self.itemBoxNum = String(box.boxNumber)
        self.itemIsBoxed = true
        self.itemBoxKey = box.boxKey
        
    
    }

 
    
    func saveItemToFirebase(itemKey: String, itemDict:Dictionary<String, AnyObject>, completion: () -> ()) {
        print("Item Model: saveItemToFirebase FUNC")

        let ref = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items/\(itemKey)")

//        let updatedItemData = ["\(itemKey)": itemDict]  as [String : Any]
    
print("From: \(curPage) -> itemSaving should be \(itemKey)  ")
        ref.updateChildValues(itemDict, withCompletionBlock: { (error, ref) -> Void in
            if ((error) != nil) {
                print("Error updating data: \(String(describing: error?.localizedDescription))")
             
            }
        })
    print("Completion should hpapen next ")
        completion()
    }

    
   
    
    
    
    
    var curPage = "Item Model"
    
}





/*
backup

func saveItemToFirebase(item: Item) {
    print("I'm in saveItemToFirebase")
    
    let itemDict: Dictionary<String, AnyObject> = [
        "itemName" :  item.itemName as AnyObject,
        "imageUrl": item.itemImgUrl as AnyObject,
        "itemCategory" : item.itemCategory as AnyObject,
        "itemSubcategory" : item.itemSubcategory as AnyObject,
        "itemQty" : item.itemQty as AnyObject ,
        "itemFragile" : item.itemFragile as AnyObject,
        "itemColor": item.itemColor as AnyObject
    ]
    
    let itemBoxDict: Dictionary<String, AnyObject> = [
        "itemIsBoxed" :  item.itemIsBoxed as AnyObject,
        "itemBoxNumber" : item.itemBoxNum as AnyObject,
        "itemBoxKey" : item.itemBoxKey as AnyObject
        
    ]
    
    let ref = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items")
    // Generate a new push ID for the new post
    
    let newItemRef = ref.childByAutoId()
    
 
    
    let newItemKey = newItemRef.key
    
    // Create the data we want to update
    
    let updatedItemData = ["\(newItemKey)": itemDict, "\(newItemKey)/box": itemBoxDict] as [String : Any]
    
    // Do a deep-path update
    
    ref.updateChildValues(updatedItemData, withCompletionBlock: { (error, ref) -> Void in
        if ((error) != nil) {
            print("Error updating data: \(error?.localizedDescription)")
        }
    })
    
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
    let _ = EZLoadingActivity.hide(success: true, animated: true)
    
}

*/


