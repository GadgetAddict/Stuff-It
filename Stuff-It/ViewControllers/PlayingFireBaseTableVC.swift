//
//  PlayingFireBaseTableVC.swift
//  Stuff-It
//
//  Created by Michael King on 4/13/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Firebase

//if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
//    self.productsValue = snapshots.flatMap { $0.value as? [String:AnyObject] }
//    self.productsTable.reloadData()
//}

class PlayingFireBaseTableVC: UITableViewController {

    
     var items = [Item]()
    
    var REF_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items")

    
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.tableFooterView = UIView()
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            
            
//            tableView.delegate = self
//            tableView.dataSource = self
            
            
            
                     loadDataFromFirebase()
            
           }   // End ViewDidLoad
            
       
        
        
        
//        
//        func writeToFb(enteredText: String) {
//            print("I'm in postToFirebase")
//            
//            let newColorTrimmed = enteredText.trimmingCharacters(in: NSCharacterSet.whitespaces)
//            
//            let color = ["colorName": newColorTrimmed.capitalized]
//            
//            
//            let REF_COLOR = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/colors").childByAutoId()
//            
//            REF_COLOR.setValue(color)
//            
//            //                self.dismiss(animated: true, completion: {})
//            
//        }
//        
 
        func loadDataFromFirebase() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.items = [] // THIS IS THE NEW LINE

            
             self.REF_ITEMS.observe(.value, with: { snapshot in
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshots {
                        print("PlayGround: \(snap)")
                        if let itemDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let item = Item(itemKey: key, dictionary: itemDict)
             
                        
                        if let childSnapshotDict = snapshot.childSnapshot(forPath: "\(key)/box").value as? Dictionary<String, AnyObject> { // FIRDataSnapshot{
                             let itemBoxNumber = childSnapshotDict["itemBoxNumber"]
                            print("childSnapshot itemBoxNumber: \(String(describing: itemBoxNumber))")
                            item.itemBoxKey = itemBoxNumber as! String?
                            item.itemBoxNum = itemBoxNumber as! String?
                            item.itemIsBoxed = true
                                }        
                            self.items.append(item)
                            self.tableView.reloadData()
                        }
                        }
                }
             })
                        
                }
    


        // MARK: - Table view data source
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return self.items.count
            
        }
        
        
        
    
        
    override func tableView(_ tableView: UITableView, cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
       
        let item = items[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PlaygroundTableCell {
            
            cell.configureCell(item: item)
            
            return cell
        } else {
            return ItemCell()
        }
    }
    
        
    
        //
        //        func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //            if segue.identifier == "unwind_saveColorToItemDetails" {
        //                print("unwind_saveColorToItemDetails" )
        //                if let cell = sender as? UITableViewCell {
        //                    let indexPath = tableView.indexPath(for: cell)
        //                    if let index = indexPath?.row {
        //                        print("Color  IF LET CELL" )
        //
        //                        let color = colors[index]
        //                        self.selectedColor  = color.colorName
        //                    }
        //                }
        //            }
        //        }
        //        
        
}  //End Class

