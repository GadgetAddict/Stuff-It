//
//  BoxFeedVC.swift
//  Inventory17
//
//  Created by Michael King on 2/7/17.
//  Copyright © 2017 Microideas. All rights reserved.
//


import UIKit
import Firebase
import DZNEmptyDataSet
import Kingfisher


class ItemFeedVC: UITableViewController ,UINavigationControllerDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SegueHandlerType{

    
    enum SegueIdentifier: String {
        case New
        case BoxFeed
        case BoxDetails
        case Existing
        case ScanQR
    }
    
 
     let searchController = UISearchController(searchResultsController: nil)
    var filteredItems = [Item]()
    var items = [Item]()
    var item: Item!
    var box: Box!
    var itemIsBoxed: Bool!
  
    lazy var itemIndexPath: NSIndexPath? = nil
    let REF_ITEMS =  DataService.ds.REF_INVENTORY.child("items")
    
    
    
    @IBAction func addNewButton(_ sender: UIBarButtonItem) {
        performSegueWithIdentifier(segueIdentifier: .New, sender: self)
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("Item Feed - View WIll Appear ")
      
            DataService.ds.getItems(parameter: "items", boxKey: nil, onCompletion: {(items, retString)-> Void in
//               print("I'm out of the closure")
//                
//                
//                print("I have return string \(retString)")
                self.items = items
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            })
 
            }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.REF_ITEMS.removeAllObservers()
    }
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Item FEed View Did Load ")
         
        //        KingfisherManager.shared.cache.clearMemoryCache()
        //        KingfisherManager.shared.cache.clearDiskCache()
        
        
//        setTableViewBackgroundGradient(sender: self)
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["Name", "Category"]
        tableView.tableHeaderView = searchController.searchBar
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        
    }
   
    
    func setTableViewBackgroundGradient(sender: UITableViewController) { //, _ topColor:UIColor,_ bottomColor:UIColor) {
        let topColor = UIColor.blue
        let bottomColor = UIColor.cyan
        let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations = [0.0,1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = gradientLocations as [NSNumber]
        
        gradientLayer.frame = sender.tableView.bounds
        let backgroundView = UIView(frame: sender.tableView.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        sender.tableView.backgroundView = backgroundView
    }
    

//not used - dataservice gets data now - try this for other Feeds
    func loadDataFromFirebase() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.REF_ITEMS.observe(.value, with: { snapshot in
            self.items = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let itemDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let item = Item(itemKey: key, dictionary: itemDict)
                        
                        
                        if let childSnapshotDict = snapshot.childSnapshot(forPath: "\(key)/box").value as? Dictionary<String, AnyObject> {                             let itemBoxNumber = childSnapshotDict["itemBoxNumber"]
                            let itemBoxKey = childSnapshotDict["itemBoxKey"]
                            let itemIsBoxed = childSnapshotDict["itemIsBoxed"]
                            
                            

                            if let isBoxed = itemIsBoxed {
                                item.itemIsBoxed = isBoxed as? Bool
                            }
                            
                            if let boxKey = itemBoxKey {
                                item.itemBoxKey = boxKey as? String
                            }
                            
                            item.itemBoxKey = itemBoxKey as! String?
                            item.itemBoxNum = itemBoxNumber as! String?
                        }
                        self.items.append(item)
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    
    func cancelButtonTapped(){
        _ = navigationController?.popViewController(animated: true)
    }
    
//    MARK: DZNEmptyDataSet
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        var image: String!
        if searchController.isActive {
            image = ""
        } else {
            image = "package"
        }
        return UIImage(named: image)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text: String!
        if searchController.isActive {
            text = "No Items Found"
        } else {
            text = "You Have No Items"
        }
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        var text: String!
        
        if searchController.isActive {
            text = "Search by Name or Category to find an item."
            
        } else {
            text = "Add Items By Tapping the + Button"
            
        }
        
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
        
        var text: String!
        
        if searchController.isActive {
            text = ""
            
            
        } else {
            text = "Add Your First Item"
            
        }
        
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: view.tintColor
            ] as [String : Any]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        //         self.performSegue(withIdentifier: "newItem_SEGUE", sender: self)
        performSegueWithIdentifier(segueIdentifier: .New, sender: self)
    }
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredItems.count
        }
        
        return items.count
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // This will cancel all unfinished downloading task when the cell disappearing.
        
        (cell as! ItemCell).imageThumb.kf.cancelDownloadTask()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell {
            let item: Item
            
            if searchController.isActive && searchController.searchBar.text != "" {
                item = filteredItems[indexPath.row]
            } else {
                item = items[indexPath.row]
            }
            
            
            cell.configureCell(item: item)
            
            
            return cell
        } else {
            return ItemCell()
        }
    }
    
    
    //    MARK: Search Function

    func filterSearchText() {
        print("ItemFeed Running filterSearchText")
        
        let searchText = searchController.searchBar.text
        let scope = searchController.searchBar.selectedScopeButtonIndex
        // Filter the array using the filter method
        filteredItems = items.filter({( item : Item) -> Bool in
            
            var fieldToSearch: String!
            switch (scope) {
            case (0):
                fieldToSearch = item.itemName
            case (1):
                fieldToSearch = item.itemCategory
      
            default:
                fieldToSearch = nil
            }
            
            return fieldToSearch.lowercased().range(of: searchText!.lowercased()) != nil
        })
        tableView.reloadData()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        //dismiss the keyboard if the search results are scrolled
        searchController.searchBar.resignFirstResponder()
    }
   
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var itemToModify: Item
        itemIndexPath = indexPath as NSIndexPath?
        
        if searchController.isActive {
             itemToModify  = filteredItems[indexPath.row]
        } else {
             itemToModify  = items[indexPath.row]
        }
        
        let itemName = itemToModify.itemName
        //                    let itemKey = itemToModify.itemKey
        
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "\u{1F5d1}\n Delete", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            let alert = UIAlertController(title: "Wait!", message: "Are you sure you want to permanently delete: \(itemName)?", preferredStyle: .actionSheet)
            
            let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: self.handleDeleteItem)
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteItem)
            
            alert.addAction(DeleteAction)
            alert.addAction(CancelAction)
            
            
            self.present(alert, animated: true, completion: nil)
            
        })
        
        deleteAction.backgroundColor = UIColor.red
        
        
        let addToBoxAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "\u{1f4e6}\n Box", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            let boxMenu = UIAlertController(title: nil, message: "Add Item to Box", preferredStyle: UIAlertControllerStyle.actionSheet)
            let ScanAction = UIAlertAction(title: "Scan QR", style: .default, handler: self.scanForBox)
            let PickAction = UIAlertAction(title: "Choose from List", style: .default, handler: self.pickForBoxFromList)
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteItem)
            boxMenu.addAction(ScanAction)
            boxMenu.addAction(PickAction)
            boxMenu.addAction(CancelAction)
            
            self.present(boxMenu, animated: true, completion: nil)
        })
        addToBoxAction.backgroundColor = UIColor.brown
        
        return [addToBoxAction, deleteAction ]
        
    }
    
    
    
    
    func handleDeleteItem(alertAction: UIAlertAction!) -> Void {
        if let indexPath = itemIndexPath {
            
            var itemObject: Item
            if searchController.isActive {
                itemObject = filteredItems[indexPath.row]
                searchController.isActive = false
            } else {
                itemObject = items[indexPath.row]
            }

            
            if itemObject.itemIsBoxed! {
            //            print("From: \(self.curPage) ->  get itemobjec: \(itemObject.itemName)   boxKey: \(itemObject.itemBoxKey) ")
            
            let box = Box(boxKey: itemObject.itemBoxKey!, boxNumber: nil)
            box.removeItemDetailsFromBox(itemKey: itemObject.itemKey)
            }
            
            let itemKey = itemObject.itemKey
            self.REF_ITEMS.child(itemKey).removeValue()
            itemIndexPath = nil
            tableView.reloadData()
         
            if searchController.isActive {
                print("End of Delete Function")
                filterSearchText()
            }
        }
    }
    
    
    
    
    func cancelDeleteItem(alertAction: UIAlertAction!) {
        itemIndexPath = nil
        self.tableView.isEditing = false
        
    }
    
    
    
    
    func scanForBox(alertAction: UIAlertAction!) -> Void {
        if let indexPath = itemIndexPath {
     
    if searchController.isActive {
                self.item = filteredItems[indexPath.row]
            } else {
                self.item = items[indexPath.row]
            }

           
//            tabBarController?.selectedIndex = 2
//            segue instead to set delegate in prepareForSeg
        self.performSegueWithIdentifier(segueIdentifier: .ScanQR, sender: self)
            
        }
    }
    
    func pickForBoxFromList(alertAction: UIAlertAction) -> Void {
        if let indexPath = itemIndexPath {

        if searchController.isActive {
            self.item = filteredItems[indexPath.row]

        } else {
            self.item = items[indexPath.row]
 
        }
                }
        performSegueWithIdentifier(segueIdentifier: .BoxFeed, sender: self)
    }
    
    
    
    
    
    @IBAction func unwindToItemFeed_Cancel(_ segue:UIStoryboardSegue) {
        
    }
    
 
    @IBAction func unwindToItemFeedFromQRsearch(_ segue:UIStoryboardSegue) {
        print("1 unwindToItemFeedFromQRsearch")
    }
    
    
  
    
    //    MARK: Unwind Box Select
    @IBAction func unwindToItemFeed_FromBoxSel(_ segue:UIStoryboardSegue) {
        
        if let boxFeedViewController = segue.source as? BoxFeedVC {
            self.box = boxFeedViewController.box!
            assignBox()
            
        }
    }
    
   
    func testMatchingCategories( completion: (Bool) -> ()) {

        print("assignBox HAS BEEN CALLED - selectedBox is: \(self.box.boxKey)")
//        check for category match
        var boxChangeApproved = false
        
        if self.item.itemCategory == self.box.boxCategory {
             boxChangeApproved = true
        } else {
              catMismatchAlert()
            }
           completion(boxChangeApproved)
    }
    
    func assignBox() {
        
            
            if let oldBoxKey = self.item.itemBoxKey {
            let oldBox = Box(boxKey: oldBoxKey, boxNumber: nil)
            
            //              Remove item from it's old box'
            oldBox.removeItemDetailsFromBox(itemKey: self.item.itemKey)
        }
        
        //          Add  Item Details to Box in Firebase
        self.box.addItemDetailsToBox(itemKey: self.item.itemKey)
        
        //          Add Box to Item in Firebase
        self.item.addBoxDetailsToItem(box: self.box)
        

        }
 
    
    
    
    func catMismatchAlert( ){
        
//    var override = false
        
            DispatchQueue.main.async {
                let alert = SCLAlertView()
                _ = alert.addButton("Add Anyway") {
                    print("I say ADD ANYWAYS")
                   
                    self.assignBox()
//                    self.box.setMixedContent()
                    
                    // add flag to box to make it mixedContent
                }
                _ = alert.showWarning("Category Mismatch", subTitle: "The Box and Item Category do not match.")
                //                _ = alert.showItemAssignBox(title, subTitle: subtitle, closeButtonTitle: "Cancel", icon: icon!, colorStyle: color )
            }
                }
//    func assignBox(selectedBox:Box, itemToBox: Item)  {
//        print("assignBox HAS BEEN CALLED - selectedBox is: \(selectedBox.boxKey)")
//        if let oldBoxKey = itemToBox.itemBoxKey {
//            let oldBox = Box(boxKey: oldBoxKey, boxNumber: nil)
//            
//            //              Remove item from it's old box'
//            oldBox.removeItemDetailsFromBox(itemKey: itemToBox.itemKey)
//        }
//        
//        //          Add  Item Details to Box in Firebase
//        selectedBox.addItemDetailsToBox(itemKey: itemToBox.itemKey)
//        
//        //          Add Box to Item in Firebase
//        itemToBox.addBoxDetailsToItem(box: selectedBox)
//    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("itemFeed prepareForSegue")
        
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)
            itemIndexPath = indexPath as NSIndexPath?
            
            if searchController.isActive {
                 self.item  = filteredItems[itemIndexPath!.row]

            } else {
                self.item  = items[itemIndexPath!.row]
            }
            
        }
        
        switch segueIdentifierForSegue(segue: segue) {
            
        case .ScanQR:
            print("itemFeed ScanQR")

//            if let navVC = segue.destination as? UINavigationController{
//            if let qrScannerVC = navVC.viewControllers[0] as? qrScannerVC{

            if let qrScannerVC = segue.destination as? qrScannerVC{
                    qrScannerVC.qrData = QR()
                    qrScannerVC.qrData.qrScanType = .ItemFeedBoxSelect
                    qrScannerVC.delegate = self 
                
            } else {
                let destiny = segue.destination
                print("destination is \(destiny)")
            }
            
        case .Existing:
            print("itemFeed Existing")

//            MARK: Must pass item Key to perform Firebase Lookup, and pass .Existing
            
            if let destination = segue.destination as? ItemDetailsVC {
                destination.itemKeyPassed = self.item.itemKey
                destination.itemType = .existing
            }
        
        case .BoxFeed:
            print("itemFeed BoxFeed")

            // set segueID on Boxfeed, so it knows to come back. Pass Item to match Category
            
            if let destination = segue.destination as? BoxFeedVC {
                destination.segueIdentifier = .ItemFeed
                destination.itemPassed = self.item
                destination.boxMode = .BoxAssignment
            }
            
        default:
            print("do nothing ")
            
        } //end Switch
    }
    
 
    
   
 
    
    
    var curPage = "ItemFeedVC"
    
}//ItemFeedVC


extension ItemFeedVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
 
        filterSearchText()

    }
}

extension ItemFeedVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
filterSearchText()
 
    }
}

extension ItemFeedVC: QrDelegate{
    func useReturnedFBKey<inventoryObject>(object: inventoryObject, completion: (Bool) -> ()) {
        self.box = object as! Box
        self.testMatchingCategories() { approved in
           
            if approved {
                print("testMatchingCategories approved")

                self.assignBox()
            }
            
            print("finished the assignedbox completion handler")
        }
        completion(true)
    }

}
//extension ItemFeedVC {
//    
//    func createUIBarButtons() {
//        let qrBtn = UIButton(frame: CGRect(x: -6, y: 0, width: 60, height: 60))
//        qrBtn.setImage(UIImage(named: "qr_small"), for: UIControlState.normal)
//        let qrAction = "qrScan"
//        qrBtn.addTarget(self, action: Selector(qrAction), for:  UIControlEvents.touchUpInside)
//        let leftItem = UIBarButtonItem(customView: qrBtn)
//        leftItem.tintColor = UIColor.white
//        self.navigationItem.leftBarButtonItem = leftItem
//    }
//}










/*
 
 
 
 func sendEmail() {
 if MFMailComposeViewController.canSendMail() {
 let mail = MFMailComposeViewController()
 mail.mailComposeDelegate = self
 mail.setToRecipients(["michael.a.king@me.com"])
 mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
 
 present(mail, animated: true)
 } else {
 // show failure alert
 }
 }
 
 func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
 controller.dismiss(animated: true)
 }
 
 
 
 */
