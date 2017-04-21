//
//  BoxItemsVC.swift
//  Inventory17
//
//  Created by Michael King on 2/24/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

class BoxItemsVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
  
//    MARK: Refactor 
 
    
    
        var items = [Item]()
        var box: Box!
        var selectedItem: Item!
        var boxItemIndexPath: NSIndexPath? = nil
//        var collectionID: String!
        var REF_BOX_ITEMS: FIRDatabaseReference!
 
    @IBAction func addToBoxBtn(_ sender: UIBarButtonItem) {
//        Take all checked items that are in the array and add their keys to the Box/contents in Firebase
    
    
    
    }
    
    
    
        override func viewDidLoad() {
            super.viewDidLoad()
    
            tableView.tableFooterView = UIView()
            tableView.tableFooterView = UIView(frame: CGRect.zero)
    
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            
            
//            let defaults = UserDefaults.standard
//    
//            if (defaults.object(forKey: "CollectionIdRef") != nil) {
//                print("Getting Defaults")
//    
//                if let collectionId = defaults.string(forKey: "CollectionIdRef") {
//                    COLLECTION_ID = collectionId
//                }
//            }
    
            loadDataFromFirebase()
    
    
    
        }   // End ViewDidLoad
    
    
    
        func loadDataFromFirebase() {
            print("loadDataFromFirebase")

            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            self.REF_BOX_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes/\(self.box.boxKey)/items")
//                  print("REFERENCE: \(myRef)")
       
            //         REF_STATUS.queryOrdered(byChild: "statusName").observe(.value, with: { snapshot in
    
            self.REF_BOX_ITEMS.observe(.value, with: { snapshot in
    
                self.items = []
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshots {
                        print("Box-Contents-Snap: \(snap)")
    
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
    
   
 
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                tableView.backgroundView = nil
        
                if items.count > 0 {
        
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    return items.count
                } else {
        
                    let emptyStateLabel = UILabel(frame: CGRect(x: 0, y: 40, width: 270, height: 32))
                    emptyStateLabel.font = emptyStateLabel.font.withSize(14)
                    emptyStateLabel.text = "Tap 'Add Items' to fill this box"
                    emptyStateLabel.textAlignment = .center;
                    tableView.backgroundView = emptyStateLabel
        
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
                }
                
                return 0
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
   
    
    
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        boxItemIndexPath = indexPath as NSIndexPath?
        let boxItemToModify  = items[indexPath.row]
        let itemName = boxItemToModify.itemName
        //                    let itemKey = itemToModify.itemKey
        
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            let alert = UIAlertController(title: "Wait!", message: "Are you sure you want to remove \(itemName) from this box?", preferredStyle: .actionSheet)
            
            let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: self.handleDeleteItem)
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteItem)
            
            alert.addAction(DeleteAction)
            alert.addAction(CancelAction)
            
            
            self.present(alert, animated: true, completion: nil)
            
        })
        
        deleteAction.backgroundColor = UIColor.red
        
        
        return [deleteAction ]
        
    }
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("boxItems: didSelectRowAt ->Call segue")
        self.selectedItem = items[indexPath.row]
        
        self.performSegue(withIdentifier: "itemDetails_SEGUE" , sender: self)
    }
   
    
    
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "package")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "This Box is Empty"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Add Items By Tapping the + Button."
        
        let para = NSMutableParagraphStyle()
        para.lineBreakMode = NSLineBreakMode.byWordWrapping
        para.alignment = NSTextAlignment.center
        
        let attribs = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSParagraphStyleAttributeName: para
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        
        
        let text = "Add Your First Item"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: view.tintColor
            ] as [String : Any]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        self.performSegue(withIdentifier: "addToBox", sender: self)
    }

    
    
    func handleDeleteItem(alertAction: UIAlertAction!) -> Void {
        print("IN THE DELETE FUNCTION")
        
        
        if let indexPath = boxItemIndexPath {
            
            tableView.beginUpdates()
            let itemObject  = items[indexPath.row]
            let itemKey = itemObject.itemKey
            let REF_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items/\(itemKey)")

     

            
//            let itemBoxDetails: Dictionary<String, AnyObject> = [
//                "itemBoxKey" :  "\(self.box.boxKey)" as AnyObject,
//                "itemBoxNumber" : "\(self.box.boxNumber)" as AnyObject,
//                "itemIsBoxed" : true as AnyObject]
            
//            REF_ITEMS.setValue(nil)
//REF_ITEMS.removeValue()
            
            
            
//            remove item from box
            self.REF_BOX_ITEMS.child(itemKey).removeValue()
            
//            remove box details from Item
            
            
            REF_ITEMS.child(self.box.boxKey).removeValue()

            boxItemIndexPath = nil
            tableView.endUpdates()
            
        }
    }
    
    
    
    func cancelDeleteItem(alertAction: UIAlertAction!) {
        boxItemIndexPath = nil
    }
    



        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            print("BoxItems: prepareForSegue ")
            
            if segue.identifier == "addToBox" {
                print("Box to addToBox ")
              
                    
            if let addItemsVC = segue.destination as? AddItemsToBoxVC {
                addItemsVC.box = self.box
                }
                
            } else {
            
                if let itemDetailsVC = segue.destination as? ItemDetailsVC {
                    print("boxItems: itemDetailsVC is destination  ")

                  itemDetailsVC.itemType = .boxItem
                    itemDetailsVC.itemsBox = self.box
                    print("passingTo ItemDetails from Box - Boxx Object \(self.box.boxNumber ) ")

                    itemDetailsVC.item = selectedItem

                }
            }
        }
//                    if segue.identifier == "itemDetails_SEGUE" {
//                        print("Box to itemDetails_SEGUE ")
            
//                        if let listItemsVC = segue.destination as? AddItemsToBoxVC {
//
//                            listItemsVC.box = self.box
                        
                            //                            addItem.box = self.box
//                            addItem.boxItemKey = itemToPass.itemKey
//                            itemDetailVC.itemType = .boxItem
//                            print("Item to Pass is \(itemToPass.itemName)")
//                            print("Item to Pass is \(itemToPass.itemKey)")
 
    
    
}  //end of class

//  delete item and storage
//// Remove the post from the DB
//ref.child("posts").child(selectedPost.postID).removeValue { error in
//    if error != nil {
//        print("error \(error)")
//    }
//}
//// Remove the image from storage
//let imageRef = storage.child("posts").child(uid).child("\(selectedPost.postID).jpg")
//imageRef.delete { error in
//    if let error = error {
//        // Uh-oh, an error occurred!
//    } else {
//        // File deleted successfully
//    }
//}
//}
