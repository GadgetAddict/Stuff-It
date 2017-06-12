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
import SwipeCellKit


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
        
        let xib : UINib = UINib (nibName: "_itemFeedCell", bundle: nil)
        self.tableView.register(xib, forCellReuseIdentifier: "_itemFeedCell")

        
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
        
            self.items = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("ItemSnap: \(snap)")
                    
                           if var itemDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        itemDict["itemIsBoxed"] = true as AnyObject
                        itemDict["itemBoxNumber"] = self.box.boxNumber as AnyObject
                        itemDict["itemBoxKey"] = self.box.boxKey as AnyObject

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
                self.performSegueWithIdentifier(segueIdentifier: .AddItems, sender: self)
    }
    
    
    
    //MARK: - UITableViewDataSource
    
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                    return items.count
    }
    
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "_itemFeedCell") as? _itemFeedCell {
           cell.delegate = self
            
            cell.configureCell(item: item)
            cell.accessoryType = .none
            return cell
        } else {
            return _itemFeedCell()
        }
    }
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
         self.selectedItem = items[indexPath.row]
            performSegueWithIdentifier(segueIdentifier: .ItemDetail, sender: self)
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
        if let navVC = segue.destination as? UINavigationController{
            if let addItemsVC = navVC.viewControllers[0] as? AddItemsToBoxVC{
 
            addItemsVC.box = self.box
            addItemsVC.boxsCurrentItems = self.items

        }
        }else {

            if let itemDetailsVC = segue.destination as? ItemDetailsVC {
                itemDetailsVC.itemType = .boxItem
                itemDetailsVC.itemKeyPassed = selectedItem.itemKey

            }
        }
    }
    
    
}  //end of class


extension BoxItemsVC: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        boxItemIndexPath = indexPath as NSIndexPath?
        let boxItemToModify  = items[indexPath.row]
        let itemName = boxItemToModify.itemName
        
        
        guard orientation == .right else { return nil }
       
        let removeAction = SwipeAction(style: .default, title: "Remove") { action, indexPath in
            print("Chose to Remove")
                tableView.beginUpdates()
            self.selectedItem  = self.items[indexPath.row]

            self.box.removeItemDetailsFromBox(itemKey: self.selectedItem.itemKey)
            
            self.selectedItem.removeBoxDetailsFromItem()
          

            self.boxItemIndexPath = nil
            tableView.endUpdates()
            

        }
            
//            let alert = UIAlertController(title: "Wait!", message: "Are you sure you want to permanently delete: \(itemName)?", preferredStyle: .actionSheet)
//            
//            let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: self.handleDeleteItem)
//            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteItem)
//            
//            alert.addAction(DeleteAction)
//            alert.addAction(CancelAction)
//            
//            
//            self.present(alert, animated: true, completion: nil)
            
        
        
        let deleteAction = SwipeAction(style: .default, title: "Delete") { action, indexPath in
            let alert = UIAlertController(title: "Wait!", message: "Are you sure you want to permanently delete: \(itemName)?", preferredStyle: .actionSheet)
            
            let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: self.handleDeleteItem)
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteItem)
            
            alert.addAction(DeleteAction)
            alert.addAction(CancelAction)
            
            
            self.present(alert, animated: true, completion: nil)
            
        }
    
        
        // customize the action appearance
        removeAction.image = UIImage(named: "orange-circle-remove")
        deleteAction.image = UIImage(named: "trash-circle")
        
        return [deleteAction, removeAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .fill
        options.buttonSpacing = 4
        options.backgroundColor = UIColor.clear
        options.transitionStyle = .reveal
        return options
    }

}
