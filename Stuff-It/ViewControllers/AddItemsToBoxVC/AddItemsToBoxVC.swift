//
//  AddItemsToBoxVC.swift
//  Inventory17
//
//  Created by Michael King on 2/24/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import Firebase
import UIKit

class AddItemsToBoxVC: UITableViewController {
        
    var items = [Item]()
    var selectedItems = [String]()
    var selectedItemKeys = [String]()
     var box: Box!
     var collectionID: String!
    var REF_ITEMS: FIRDatabaseReference!
    var REF_BOX: FIRDatabaseReference!

        
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
   
        for item in selectedItems {
            for key in selectedItemKeys {
            
                print("SaveFB - item: \(item) key: \(key)")
                saveToFirebase(item: item, key: key)
        }
    
        }
    }
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.tableFooterView = UIView()
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            
            
//            let defaults = UserDefaults.standard
//            
//            if (defaults.object(forKey: "CollectionIdRef") != nil) {
//                print("Getting Defaults")
//                
//                if let collectionId = defaults.string(forKey: "CollectionIdRef") {
//                    self.collectionID = collectionId
//                }
//            }
//            

            loadDataFromFirebase()
            
            
            
        }   // End ViewDidLoad
        
    func saveToFirebase(item: String, key: String) {
        self.REF_BOX = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes/\(self.box.boxKey)/items/\(key)")
        
        self.REF_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items/\(key)/")
        
        let boxNumDict: Dictionary<String, String> =
            ["itemBoxNum" : self.box.boxKey ]
        
        let itemDict: Dictionary<String, String> =
            ["itemName" : item ]
        
         self.REF_BOX.setValue(itemDict)
        self.REF_ITEMS.updateChildValues(boxNumDict)

        
        _ = navigationController?.popViewController(animated: true)

    }
    
    
        
        func loadDataFromFirebase() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
  
            self.REF_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items")
            print("self.box.boxCategory: \(self.box.boxCategory!)")

//            boxesREF = (self.REF_BOXES.child(query.child).queryEqual(toValue: query.value))
            let itemsMatchingCategory_REF = REF_ITEMS.queryOrdered(byChild: "itemCategory").queryEqual(toValue: self.box.boxCategory!)

//            self.REF_BOX.queryEqual(toValue: self.box.boxCategory! ).observe(.value, with: { snapshot in

//            self.REF_BOX.queryEqual(toValue: self.box.boxCategory! ).observe(.value, with: { snapshot in
//            print("REF_BOX: \(self.REF_BOX)")

            itemsMatchingCategory_REF.observe(.value, with: { snapshot in
            
                self.items = []
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshots {
                        print("ItemSnap: \(snap)")
                        
                        if let itemDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let item = Item(itemKey: key, dictionary: itemDict)
                            self.items.append(item)
                        }
                    }
                }
                
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            })
        }
        
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        //MARK: - UITableViewDataSource
        
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let item = items[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "boxItemsCell") as? BoxItemCell {
                cell.configureCell(item: item)
                cell.accessoryType = .none
                return cell
            } else {
                return BoxItemCell()
            }
        }
        
        
        
        
        //
        //        override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //
        //            if let sr = tableView.indexPathsForSelectedRows {
        //                if sr.count == limit {
        //                    let alertController = UIAlertController(title: "Oops", message:
        //                        "You are limited to \(limit) selections", preferredStyle: .alert)
        //                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
        //                    }))
        //                    self.present(alertController, animated: true, completion: nil)
        //
        //                    return nil
        //                }
        //            }
        //
        //            return indexPath
        //        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            print("selected  \(items[indexPath.row].itemName)")
            
            let item = items[indexPath.row].itemName
            let itemKey = items[indexPath.row].itemKey
            
            self.selectedItemKeys.append(itemKey)
            self.selectedItems.append(item)
            
            print("items in ITEMSARRAY selected rows:\(self.selectedItems)")

            
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.isSelected {
                    cell.accessoryType = .checkmark
                }
            }
            
            if let sr = tableView.indexPathsForSelectedRows {
                
                print("didDeselectRowAtIndexPath selected rows:\(sr)")
            }
        }
        
        override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
             print("deselected  \(items[indexPath.row])")
            
            let item = items[indexPath.row].itemName
            let itemKey = items[indexPath.row].itemKey
            
            selectedItems = selectedItems.filter { $0 != item }
            selectedItemKeys = selectedItemKeys.filter { $0 != itemKey }

             print("Item Array \(selectedItems)")
            print("Item Array \(selectedItemKeys)")

            
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
            }
            
            if let sr = tableView.indexPathsForSelectedRows {
                print("didDeselectRowAtIndexPath selected rows:\(sr)")
 
            }
        }
        
}
 
