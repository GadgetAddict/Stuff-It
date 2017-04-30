//
//  loadDataFireBase.swift
//  Stuff-It
//
//  Created by Michael King on 4/19/17.
//  Copyright © 2017 Microideas. All rights reserved.
//


import Firebase
import Foundation


class Helper_SaveToFB {
    
 
    
    
    
}


class Helper_DeleteFromFB {
    
    
    
    
    
}



extension Status  {
 
     func statusExtensionDoSomething() -> [Status] {
        var stats = [Status]()
        
        let stat1 = Status(statusKey: "StatKey123", statusName: "Tired Status Name")

        stats.append(stat1)
        
        return stats
    }
    
    func loadDataFromFirebase() -> [Status]  {
        var stats = [Status]()

        let REF_STATUS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/status")
        
        REF_STATUS.observe(.value, with: { snapshot in
//        )
//        REF_STATUS.observeSingleEvent(of: .value, with: { snapshot in
           stats = []

            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("StatusSnap: \(snap)")
                    
                    if let statusDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let status = Status(statusKey: key, dictionary: statusDict)
                        stats.append(status)
                    }
                }
            }
            
            
        })
        
         return stats
    }
    
    
    
}
    
//    func closureReturn( withCompletionHandler:([Item]) -> Void) {
//        let wk1 = Item(itemName: "Tree", itemCat: "Christmas", itemSubcat: "Decorations", itemColor: "blue")
//        //        items2.append(wk1)
//
//        withCompletionHandler([wk1])
//        
//    }
//
//    closureReturn() { (newBoxNumber) -> Void in
//    let counting = newBoxNumber.count
//    print("people: \(counting)")
//    }
//
//    
    
 
 
