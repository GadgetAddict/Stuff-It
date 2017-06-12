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
    
    var REF_INVENTORY: FIRDatabaseReference {
        return REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory")
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
    
    
    func getItems(parameter: String, boxKey: String?,  onCompletion: @escaping ([Item], String) -> Void) {
        
        let REF = DataService.ds.REF_INVENTORY.child(parameter)
//        print("DataService- Get Items  ")

        //        REF.queryOrdered(byChild: "box/itemBoxKey").queryEqual(toValue: boxKey).observe(.value, with: { snapshot in
        
//        print("Item Feed - REF \(REF)")

        
        REF.observe(.value, with: { snapshot in
            var items = [Item]()
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let itemDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
//                        print("DS.SnapKey \(key)")
                        let item = Item(itemKey: key, dictionary: itemDict)
                        
                        
                        if let childSnapshotDict = snapshot.childSnapshot(forPath: "\(key)/box").value as? Dictionary<String, AnyObject> {
                            let itemBoxNumber = childSnapshotDict["itemBoxNumber"]
                            let itemBoxKey = childSnapshotDict["itemBoxKey"]
                            let itemIsBoxed = childSnapshotDict["itemIsBoxed"]
                            
                            
                            item.itemBoxKey = itemBoxKey as! String?
                            item.itemBoxNum = itemBoxNumber as! String?
                            item.itemIsBoxed = itemIsBoxed as! Bool
                        }
                        items.append(item)
                    }
                }
            }
            let retString = "Told you so"
            onCompletion(items, retString)
        })
    }

func qrSearch(qrString: String) -> String {

    var objectKey: String?
    
    enum childSwitch  {
        case item
        case box
        
        mutating func toggle() {
            switch self {
            case .item:
                self = .box
            case .box:
                self = .item
            }
        }
    }
    var fbChild = childSwitch.box
    
    
    let REF_QUERY =  REF_INVENTORY.child("box")
        .queryOrdered(byChild: "boxQR").queryEqual(toValue: qrString)
 
    REF_QUERY.observe(.value, with:{ (snapshot: FIRDataSnapshot) in
                        
                        
                        let itemExists = snapshot.exists()
                        print("Snapshot exists? \(itemExists)")
                        
                        if itemExists {
                            for snap in snapshot.children {
                                objectKey = (snap as! FIRDataSnapshot).key
                            }
                        } else {
                            fbChild.toggle()

 
                        }
             })
 
    return objectKey!

    }

    
}

/*
func processQR()  {
    self.searchAttempts = 0
    switch qrMode {
        
    case .ItemSearch:
        self.searchItem()
    case .BoxSearch:
        self.searchBox()
        
    default:
        print("")
 
 

func searchBox(){
    print("searching Box for \(self.qrData)")
    self.searchAttempts += 1
    
    self.REF_QUERY =  REF_BOXES.queryOrdered(byChild: "boxQR").queryEqual(toValue: self.qrData)
    //        self.qrMode = .BoxSearch
    searchFB()
    
}

func searchItem(){
    print("searching Items for \(self.qrData)")
    self.searchAttempts += 1
    
    self.REF_QUERY =  REF_ITEMS.queryOrdered(byChild: "itemQR").queryEqual(toValue: self.qrData)
    //        self.qrMode = .ItemSearch
    searchFB()
}




func searchFB() {
    print("       perform test query")
    
    
    
    
    self.REF_QUERY.observe(.value, with:{ (snapshot: FIRDataSnapshot) in
        let itemExists = snapshot.exists()
        print("Snapshot exists? \(itemExists)")
        
        if itemExists {
            for snap in snapshot.children {
                //                    print((snap as! FIRDataSnapshot).key)
                
                switch self.qrMode {
                case .ItemSearch:
                    self.objectKeyToPass = (snap as! FIRDataSnapshot).key
                    print(".ItemSearch \(self.objectKeyToPass)")
                    self.segue(segue: .ItemSearch)
                case .BoxSearch:
                    self.objectKeyToPass = (snap as! FIRDataSnapshot).key
                    print(".BoxSearch \(self.objectKeyToPass)")
                    self.segue(segue: .BoxSearch)
                case .ItemDetailsQrAssign:
                    print(".ItemQR Assign \(self.qrData)")
                //                        self.segue(segue: .ItemDetailsQrAssign)
                case .BoxDetailsQrAssign:
                    print(".BoxDeatils QR Assign \(self.qrData)")
                //                        self.segue(segue: .BoxDetailsQrAssign)
                default:
                    print("")
                }
            }
        } else {
            print("do sometihng")
            
            if self.searchAttempts < 2 {
                print("searchattempts less than 2 -> then run opposite search")
                
                switch self.qrMode {
                case .ItemSearch:
                    self.searchBox()
                case .BoxSearch:
                    self.searchItem()
                default:
                    print("")
                }
            } else {
                //    MARK: SCLAlertView
                print("SHOW THE ERROR MESSAGE")
                
                self.showBoxChangeAlertView()
            }
        }
    })
}

//    MARK: SCLAlertView
func showBoxChangeAlertView()  {
    print("showBoxChangeAlertView")
    let title = "No Matches"
    let subtitle = "No Items or Boxes were located.\nWould you like to create a new Item or Box using this QR Code?"
    
    // Create custom Appearance Configuration
    let fontName = "HelveticaNeue-Boldz
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "PingFang SC-Bold", size: 20)!,
        kTextFont: UIFont(name: "PingFang SC-Light", size: 19)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
        showCloseButton: false,
        dynamicAnimatorActive: true
    )
    
    
    let alert = SCLAlertView(appearance: appearance)
    _ = alert.addButton("New Box") {
        print("Create a new BOX")
        
        
    }
    _ = alert.addButton("New Item") {
        print("Create a new Item")
        
        
    }
    
    _ = alert.addButton("Cancel") {
        self.cancelToItemFeed()
    }
    DispatchQueue.main.async {
        
        _ = alert.showQRerror(title, subTitle: subtitle)
        
    }
    
}
  */
