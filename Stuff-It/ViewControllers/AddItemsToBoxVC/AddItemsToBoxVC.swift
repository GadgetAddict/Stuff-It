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
    var boxsCurrentItems = [Item]()
    var selectedItems = [Item]()
    var box: Box!
    var collectionID: String!
    var REF_ITEMS: FIRDatabaseReference!
    var REF_BOX: FIRDatabaseReference!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        loadDataFromFirebase()
        
    }   // End ViewDidLoad
    
    
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {

        //  MARK: Save Data To FireBase
        for item in selectedItems {
            
            func addTonewBoxDict() -> Dictionary<String, AnyObject> {
                return ["itemBoxKey": self.box.boxKey as AnyObject , "itemName": item.itemName as AnyObject, "itemKey" : item.itemKey as AnyObject]
            }
            
            self.box.addItemDetailsToBox(itemDict: addTonewBoxDict() )
            item.addBoxDetailsToItem(box: self.box)
      }
            _ = navigationController?.popViewController(animated: true)
    }

    
    @IBAction func cancelAddBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
   
    func loadDataFromFirebase() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        
        self.REF_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items")
        print("self.box.boxCategory: \(self.box.boxCategory!)")
        
        let itemsMatchingCategory_REF = REF_ITEMS.queryOrdered(byChild: "itemCategory").queryEqual(toValue: self.box.boxCategory!)
        
        itemsMatchingCategory_REF.observe(.value, with: { snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("itemFeed Snap: \(snap)")
                    if let itemDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let item = Item(itemKey: key, dictionary: itemDict)
                        
                        if let childSnapshotDict = snapshot.childSnapshot(forPath: "\(key)/box").value as? Dictionary<String, AnyObject> { // FIRDataSnapshot{
                            let itemBoxNumber = childSnapshotDict["itemBoxNumber"]
                            let itemBoxKey = childSnapshotDict["itemBoxKey"]
                            let itemIsBoxed = childSnapshotDict["itemIsBoxed"]
                            
                            //                            print("childSnapshot itemBoxNumber: \(itemBoxNumber)")
                            item.itemBoxKey = itemBoxKey as! String?
                            item.itemBoxNum = itemBoxNumber as! String?
                            item.itemIsBoxed = itemIsBoxed as! Bool
                        }
                        if item.itemBoxKey != self.box.boxKey{
                        self.items.append(item)
                        }
                    }
                }
            }
           
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell {
    
            let  item = items[indexPath.row]
            var img: UIImage?
            
            if let url = item.itemImgUrl {
                img = itemFeedVC.imageCache.object(forKey: url  as NSString)
            }
            cell.configureCell(item: item, img: img)
            
            return cell
        } else {
            return ItemCell()
        }
    }
    
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            let item = items[indexPath.row]
            self.selectedItems.append(item)
            
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.isSelected {
                    cell.accessoryType = .checkmark
                }
            }
//            if let sr = tableView.indexPathsForSelectedRows {
//                }
        }
        
        override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            let item = items[indexPath.row]
            
            let removeThisItem = selectedItems.index{$0 === item} // 0
            self.selectedItems.remove(at: removeThisItem!)
            
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
            }
//            if let sr = tableView.indexPathsForSelectedRows {
//            }
        }
        
}
 
