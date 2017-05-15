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


//
//  BoxItemsVC.swift
//  Inventory17
//
//  Created by Michael King on 2/24/17.
//  Copyright © 2017 Microideas. All rights reserved.
//


class BoxItemsVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SegueHandlerType {
    
    var selectedItem: Item!
    var items = [Item]()
    var box: Box!
    var boxItemIndexPath: NSIndexPath? = nil
    var REF_BOX_ITEMS: FIRDatabaseReference!
    
    enum SegueIdentifier: String {
        case ItemDetail
        case AddItems
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
 
        loadDataFromFirebase()
        
    }   // End ViewDidLoad
    
    
    
    func loadDataFromFirebase() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
//        self.REF_BOX_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes/\(self.box.boxKey)/items")
        
          self.REF_BOX_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items/")
        
           REF_BOX_ITEMS.queryOrdered(byChild: "box/itemBoxKey").queryEqual(toValue: box.boxKey).observe(.value, with: { snapshot in
        
//        self.REF_BOX_ITEMS.observe(.value, with: { snapshot in
            
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
    
    
    //    MARK: DZNEmptyDataSet Empty Table Data
    
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
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
         self.selectedItem = items[indexPath.row]
            performSegueWithIdentifier(segueIdentifier: .ItemDetail, sender: self)
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
    
    func handleDeleteItem(alertAction: UIAlertAction!) -> Void {
        print("IN THE DELETE FUNCTION")
        
        
        if let indexPath = boxItemIndexPath {
            
            tableView.beginUpdates()
            let itemObject  = items[indexPath.row]
            let itemKey = itemObject.itemKey
            let REF_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items/\(itemKey)")
            
            
            
            let itemBoxDetails: Dictionary<String, AnyObject> = [
                "itemBoxKey" :  "\(self.box.boxKey)" as AnyObject,
                "itemBoxNumber" : "\(self.box.boxNumber)" as AnyObject,
                "itemIsBoxed" : true as AnyObject]
            
            REF_ITEMS.updateChildValues(itemBoxDetails)
            
            
            
            
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

        if let addItemsVC = segue.destination as? AddItemsToBoxVC {
            addItemsVC.box = self.box
            addItemsVC.boxsCurrentItems = self.items

        } else {

            if let itemDetailsVC = segue.destination as? ItemDetailsVC {
                itemDetailsVC.itemType = .boxItem
                itemDetailsVC.itemKeyPassed = selectedItem.itemKey

            }
        }
    }
    
    
}  //end of class



/*
class BoxItemsVC: UITableView, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
 
        var items = [Item]()
        var box: Box!
        var selectedItem: Item!
        var boxItemIndexPath: NSIndexPath? = nil
        var REF_BOX_ITEMS: FIRDatabaseReference!
 

   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.REF_BOX_ITEMS.removeAllObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        loadDataFromFirebase()
    }
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
    
            tableView.tableFooterView = UIView()
            tableView.tableFooterView = UIView(frame: CGRect.zero)
    
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self

        }   // End ViewDidLoad
    
    
        func loadDataFromFirebase() {
            print("loadDataFromFirebase")
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            self.REF_BOX_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes/\(self.box.boxKey)/items")

            self.REF_BOX_ITEMS.observeSingleEvent(of: .value, with: { snapshot in
    
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
print("From: \(curPage) ->  HandleDelte  ")
        
        if let indexPath = boxItemIndexPath {
            let itemToDelete  = items[indexPath.row]
            print("From: \(curPage) ->  itemToDelete :\(itemToDelete.itemKey)")
            
//            remove item from box
            self.box.removeItemDetailsFromBox(itemKey: itemToDelete.itemKey)

//            remove box details from Item
            itemToDelete.removeBoxDetailsFromItem()
 
        }
        boxItemIndexPath = nil

        self.loadDataFromFirebase()

    }
    
    
    func cancelDeleteItem(alertAction: UIAlertAction!) {
        boxItemIndexPath = nil
    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            print("BoxItems: prepareForSegue ")
            
            if segue.identifier == "addToBox" {
                print("Box to addToBox ")
              
                    
            if let addItemsVC = segue.destination as? AddItemsToBoxVC {
//                addItemsVC.box = self.box
//                addItemsVC.boxsCurrentItems = self.items
                }
                
            } else {
            
                if let itemDetailsVC = segue.destination as? ItemDetailsVC {
                    print("boxItems: itemDetailsVC is destination  ")

                  itemDetailsVC.itemType = .boxItem
                    print("passingTo ItemDetails from Box - Boxx Object \(self.box.boxNumber! ) ")

                    itemDetailsVC.itemKeyPassed = selectedItem.itemKey

                }
            }
        }
    
    var curPage = "BoxItems"

}
*/
