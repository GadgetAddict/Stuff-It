//
//  AddItemsToBoxVC.swift
//  Inventory17
//
//  Created by Michael King on 2/24/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import Firebase
import UIKit
import DZNEmptyDataSet

protocol UpdateOverlayNib {
    func showMixedContentButton(otherItemsAvailable: Bool)
    func updateTitle(category: String)
    
}
class AddItemsToBoxVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SegueHandlerType,UIPopoverPresentationControllerDelegate {
    
 



    enum SegueIdentifier: String {
        case Unwind
        case NewItem
        case Cancel
        case PopOver
        case Test
    }
    
       
    var items = [Item]()
    var boxsCurrentItems = [Item]()
    var selectedItems = [Item]()
    var box: Box!
    var collectionID: String!
    var REF_ITEMS = DataService.ds.REF_INVENTORY.child("items")
    var REF_BOX: FIRDatabaseReference!
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
              loadDataFromFirebase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let xib : UINib = UINib (nibName: "_itemFeedCell", bundle: nil)
        self.tableView.register(xib, forCellReuseIdentifier: "_itemFeedCell")
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }   // End ViewDidLoad
    
    
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        
        //  MARK: Save Data To FireBase
        for item in selectedItems {
            
            //            func addTonewBoxDict() -> Dictionary<String, AnyObject> {
            //                return ["itemBoxKey": self.box.boxKey as AnyObject , "itemName": item.itemName as AnyObject, "itemKey" : item.itemKey as AnyObject]
            //            }
            
            self.box.addItemDetailsToBox(itemKey: item.itemKey )
            item.addBoxDetailsToItem(box: self.box)
        }
        popViewController()
    }
    
    
    @IBAction func cancelAddBtn(_ sender: Any) {
        popViewController()
    }
    
    func popViewController(){
        performSegueWithIdentifier(segueIdentifier: .Cancel, sender: self)
    }
    
    func loadDataFromFirebase() {
        print("AddItemsToBox: loadDataFromFirebase")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var REF: FIRDatabaseQuery
        
     
            
            REF = self.REF_ITEMS.queryOrdered(byChild: "itemCategory").queryEqual(toValue: self.box.boxCategory!)
     
        
        REF.observe(.value, with: { snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
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
                            item.itemIsBoxed = (itemIsBoxed as? Bool)
                        }
//                        Dont show items in this box
                        if item.itemBoxKey != self.box.boxKey {
                            if !item.itemIsBoxed! {
                        self.items.append(item)
                            }
                            
//                            NEED TO ADD OPTION TO SHOW MIXED UNCATEGORIZED ITEMS
                        }
                    }
                }
            }
           
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        })
    }

    
//    MARK: DZNEMPTY DATA 
    
    //    MARK: DNZ Empty Table View    DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
    
 /*
 func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "package")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No Matching Items Found"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "There are no items with the \(String(describing: self.box.boxCategory!)) Category."
        
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
     
     let text = "Show All Items Anyway"
     let attribs = [
     NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
     NSForegroundColorAttributeName: view.tintColor
     ] as [String : Any]
     
     return NSAttributedString(string: text, attributes: attribs)
     }
     
     
     func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
     print("something tappped")
     }

     
     */
    
    lazy var overlayView: OverlayView = {
        let overlayView = OverlayView()
        overlayView.delegate = self
        return overlayView
    }()
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
      overlayView.boxCategory = "SHIT"
//        are there other items available ? if not- set false
 
            
        self.box.countItemsNotInBox(completion: {
            otherItemsAvailable -> Void in
            print("IN THE OverLay DNZ CLLOSURE")
           self.overlayView.showMixedContentButton(otherItemsAvailable: otherItemsAvailable)

            //            if isSuccessful {
//                print("You've downloaded")
//            } else {
//                print("Unexpected error encountered")
//            }
        })
        
        
                return self.overlayView

        
    }
    
     func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -50
    }
    
    func getCount() -> Bool {
        
        self.REF_ITEMS.observe(.value, with: { (snapshot: FIRDataSnapshot!) in
            print(snapshot.childrenCount)
            var itemCount = snapshot.childrenCount
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    let key = snap.key
                    if key == self.box.boxKey {
                        itemCount -= 1
                    }
                }
            }
        })
        return true
    }
    
    
        //MARK: - UITableViewDataSource
    
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "_itemFeedCell", for: indexPath) as? _itemFeedCell {
            
            let item = items[indexPath.row]
            
            
            cell.configureCell(item: item)
            
            
            return cell
        } else {
            return _itemFeedCell()
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifierForSegue(segue: segue) {
        case .NewItem:
            if let destination = segue.destination as? ItemDetailsVC {
                    destination.itemType = .newFromBoxItems
                    destination.itemKeyPassed = self.box.boxCategory
                }
        case .PopOver:
            let popoverViewController = segue.destination as? OptionsPopup
            popoverViewController?.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController?.popoverPresentationController!.delegate = self
            popoverViewController?.category = "FUnky Cats"
        case .Test:
            let popoverViewController = segue.destination
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self

            
         default:
            break
        }
        }
     
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    
    
    
                var curPage = "AddItemsToBox" 
}

extension AddItemsToBoxVC: OverlayDelegate{
    func createNewItem(){
        //goto newItem and prefill category
        
    }
    
    
    func addMixedContent() {
        print("called delegate to allowMixedContent")
        
        self.loadDataFromFirebase()
    }

}





