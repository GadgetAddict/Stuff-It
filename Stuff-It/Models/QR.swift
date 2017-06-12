//
//  QR.swift
//  Stuff-It
//
//  Created by Michael King on 5/15/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import Firebase



enum ObjectType {
    case item
    case box
    case none
}


enum qrScanTypes {
    case OpenSearch
    case ItemDetailsBoxSelect
    case ItemFeedBoxSelect
    case ItemDetailsQrAssign
    case BoxDetailsQrAssign
}


class QR {
    
    
    //    var qrString: String!
    var item: Item?
    var box: Box?
    
    var objectTypeReturned = ObjectType.none
    
    var qrScanType: qrScanTypes = .OpenSearch
    
    var objectKeyReturned: String?
    var scannedString: String!
    

    
    
    func getDataFromFirebase(scannedString: String,  callback: @escaping () -> Void) {
        self.scannedString = scannedString
        
        print("QR Model - firebaseGo is ticking")
        
        let REF_QUERY_i = DataService.ds.REF_INVENTORY.child("items").queryOrdered(byChild: "itemQR").queryEqual(toValue: scannedString)
        
        let REF_QUERY_b = DataService.ds.REF_INVENTORY.child("boxes").queryOrdered(byChild: "boxQR").queryEqual(toValue: scannedString)
        
        REF_QUERY_i.observeSingleEvent(of: .value, with: { itemSnapshot in
            
            if itemSnapshot.value is NSNull {
                print("item Snap is NSNull ")
                
            } else {
                
                self.objectTypeReturned = .item
                let child: FIRDataSnapshot = itemSnapshot.children.nextObject() as! FIRDataSnapshot
                self.objectKeyReturned = child.key
                self.item = Item(itemKey: child.key, itemBoxed: nil, itemCategory: nil)
                print("key is a item \(String(describing: self.objectKeyReturned))")
            }
            
            REF_QUERY_b.observeSingleEvent(of: .value, with: { boxSnapshot in
                if boxSnapshot.value is NSNull {
                    print("box Snap is NSNull ")
                } else {
                    print("box Snap is - \(boxSnapshot.value) ")
                    self.objectTypeReturned = .box
                    let child: FIRDataSnapshot = boxSnapshot.children.nextObject() as! FIRDataSnapshot
                    self.objectKeyReturned = child.key
                    
                    DataService.ds.REF_INVENTORY.child("boxes/\(String(describing: child.key))").observe(.value, with: { snapshot in
                        if let boxSnapshotDict = snapshot.value as? Dictionary<String, AnyObject> {
                            self.box = Box(boxKey: child.key, dictionary: boxSnapshotDict)
                            print("key is a Box \(String(describing: self.objectKeyReturned))")
                        }
                        callback()
                    })
                }
            })
        })
    }
    
    
    
    func findScannedStringInFirebase(scannedString: String, completion: @escaping (Bool) -> Void) {
        
        //do something
        
        completion(true)
    }
    
    
    
}
