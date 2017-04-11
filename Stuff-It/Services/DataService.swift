//
//  DataService.swift
//  Inventory
//
//  Created by Michael King on 1/1/17.
//  Copyright © 2017 Michael King. All rights reserved.
//


import Foundation
import Firebase
import FirebaseStorage

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    // DB references
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    
    // Storage references
   private var _REF_ITEM_IMAGES = STORAGE_BASE.child("itemImages")

    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
 
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
     var REF_USER_CURRENT: FIRDatabaseReference {
            let userID = FIRAuth.auth()?.currentUser?.uid
        print("DS: USER ID : \(userID!)")
        
            let userRef = REF_USERS.child(userID!).child("collectionAccess/collectionId")
        print("DS: userREF : \(userRef)")

        return userRef
        }
    

   
    
    var REF_ITEM_IMAGES: FIRStorageReference {
        return _REF_ITEM_IMAGES
    }
 
    func createFirbaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
 
    
}
