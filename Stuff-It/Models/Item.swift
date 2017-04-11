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
    private var _itemBoxNum: Int?
    private var _itemBoxKey: String?
    private var _itemIsBoxed: Bool!
    private var _itemQty: String?
    private var _itemFragile: Bool!
    private var _itemColor: String?
    private var _tags: [String]?
    private var _qrCode: [String]?
    private var _itemRef: FIRDatabaseReference!
    
    
    var itemKey: String {
        return _itemKey
    }
    
    var itemColor: String? {
        return _itemColor
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
        return _itemCategory
    }
    
    var itemSubcategory: String? {
        return _itemSubcategory
    }
    
    var itemIsBoxed: Bool! {
        get {
            return _itemIsBoxed
        }
        set {
            _itemIsBoxed = newValue
        }
    }

    var itemBoxNum: Int? {
        
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
    
    
    var itemQty: String! {
        return _itemQty
    }
    
    var itemFragile: Bool {
        return _itemFragile
    }
    
    var tags: [String]? {
        return _tags
    }
    
    var qrCode: [String]? {
        return _qrCode
    }
 
    
    init(itemName: String, itemCat: String, itemSubcat: String, itemColor: String?) {
        
        self._itemName = itemName
        self._itemCategory = itemCat
        self._itemSubcategory = itemSubcat
        
        if let color = itemColor {
            self._itemColor = color
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
        if let itemIsBoxed = dictionary["itemIsBoxed"] as? Bool {
            self._itemIsBoxed = itemIsBoxed
        }
        if let itemBoxNum = dictionary["itemBoxNumber"] as? Int {
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
        if let color = dictionary["itemColor"] as? String {
            self._itemColor = color
        }
        if let tags = dictionary["tags"] as? [String] {
            self._tags = tags
        }
        if let qrCode = dictionary["qrCode"] as? [String] {
            self._qrCode = qrCode
        }
        
        _itemRef = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items/\(itemKey)")

    }
    
    
//    func saveNewItem(item:Item)  {
//        
//        let itemDict: Dictionary<String, AnyObject> = [
//            "itemName" :  item.itemName as AnyObject,
//            "imageUrl": imgUrl as AnyObject,
//            "itemCategory" : item.itemCategory as AnyObject,
//            "itemSubcategory" : item.itemSubcategory as AnyObject,
//            "itemQty" : item as AnyObject ,
//            "itemFragile" : item as AnyObject,
//            "itemColor": item.itemColor as AnyObject,
//            "itemIsBoxed" : false as AnyObject
//        ]
//        
//    }

    
    
    
    func removeBoxDetailsFromItem()  {
        print("  removeItemDetailsFromBox")
        _itemRef.child("items").removeValue()
        
    }


    func AddBoxDetailsToItem(box: Box) {
    
    _itemRef.child("box/").setValue([
        "itemBoxKey" : box.boxKey,
        "itemBoxNumber" : box.boxNumber,
        "itemIsBoxed" : true
        ])
        
    
    }




    

    
    
}



