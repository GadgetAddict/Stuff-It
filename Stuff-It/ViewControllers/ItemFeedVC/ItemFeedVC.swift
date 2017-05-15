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
import MessageUI



class ItemFeedVC: UITableViewController ,UINavigationControllerDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MFMailComposeViewControllerDelegate, SegueHandlerType, qrDelegate {
    
    
    
    enum SegueIdentifier: String {
        case New
        case BoxFeed
        case BoxDetails
        case Existing
        case ScanQR
    }
    
    var qrMode: qrScanTypes = .ItemSearch
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredItems = [Item]()
    var items = [Item]()
    var itemToPass: Item?
    var boxToPass: Box?
    var itemIsBoxed: Bool!
    lazy var itemIndexPath: NSIndexPath? = nil
    
    let REF_ITEMS =  DataService.ds.REF_INVENTORY.child("items")
    
    
    
    @IBAction func addNewButton(_ sender: UIBarButtonItem) {
        performSegueWithIdentifier(segueIdentifier: .New, sender: self)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Item Feed - View WIll Appear ")
        loadDataFromFirebase()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.REF_ITEMS.removeAllObservers()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Item FEed View Did Load ")
        createUIBarButtons()
        
        //        KingfisherManager.shared.cache.clearMemoryCache()
        //        KingfisherManager.shared.cache.clearDiskCache()
        
        
        
        
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
    
    
    func qrScan() {
        qrMode = .ItemSearch
        DispatchQueue.main.async {
            self.performSegueWithIdentifier(segueIdentifier: .ScanQR, sender: self)
        }
    }
    
    
    
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
                            
                            
                            item.itemBoxKey = itemBoxKey as! String?
                            item.itemBoxNum = itemBoxNumber as! String?
                            item.itemIsBoxed = itemIsBoxed as! Bool
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
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Name") {
        
        filteredItems = items.filter({( item : Item) -> Bool in
            var searchedItem: String!
            var categoryMatch: Bool!
            switch scope {
            case "Name":
                categoryMatch = (scope == "Name") || (item.itemName == scope)
                searchedItem = item.itemName
            case "Category":
                categoryMatch = (scope == "Category") || (item.itemCategory == scope)
                searchedItem = item.itemCategory
                
            default:
                categoryMatch = (scope == "Name") || (item.itemName == scope)
                searchedItem = item.itemName
                
            }
            
            
            let result = categoryMatch && searchedItem.lowercased().contains(searchText.lowercased())
            return result
        })
        tableView.reloadData()
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        itemIndexPath = indexPath as NSIndexPath?
        let itemToModify  = items[indexPath.row]
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
            let PickAction = UIAlertAction(title: "Choose from List", style: .default, handler: self.pickForBox)
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
            //             tableView.beginUpdates()
            let itemObject  = items[indexPath.row]
            //            print("From: \(self.curPage) ->  get itemobjec: \(itemObject.itemName)   boxKey: \(itemObject.itemBoxKey) ")
            
            let box = Box(boxKey: itemObject.itemBoxKey!, boxNumber: nil)
            box.removeItemDetailsFromBox(itemKey: itemObject.itemKey)
            let itemKey = itemObject.itemKey
            self.REF_ITEMS.child(itemKey).removeValue()
            itemIndexPath = nil
            tableView.reloadData()
            
        }
    }
    
    
    
    
    func cancelDeleteItem(alertAction: UIAlertAction!) {
        itemIndexPath = nil
        self.tableView.isEditing = false
        
    }
    
    
    
    
    func scanForBox(alertAction: UIAlertAction!) -> Void {
        if let indexPath = itemIndexPath {
            self.itemToPass = items[indexPath.row]
            
            qrMode = .ItemFeedBoxSelect
            performSegueWithIdentifier(segueIdentifier: .ScanQR, sender: self)
            
        }
    }
    
    func pickForBox(alertAction: UIAlertAction) -> Void {
        if let indexPath = itemIndexPath {
            self.itemToPass = items[indexPath.row]
        }
        performSegueWithIdentifier(segueIdentifier: .BoxFeed, sender: self)
    }
    
    
    
    
    
    @IBAction func unwindToItemFeed_Cancel(_ segue:UIStoryboardSegue) {
        
    }
    
    
    @IBAction func unwindToItemFeedFromQRsearch(_ segue:UIStoryboardSegue) {
        print("1 unwindToItemFeedFromQRsearch")
        
        if let qrScannerViewController = segue.source as? qrScannerVC {
            if let scannedString =  qrScannerViewController.qrData {
                print("2 if let scannedString \(scannedString) ")
                
                getDataFromFirebase(qrScan: scannedString, callback: {(key, objectTypeReturned)-> Void in
                    print("7 got a \(objectTypeReturned) key  -> \(String(describing: key)) ")
                    
                    switch self.qrMode {
                    case .ItemSearch:
                        if objectTypeReturned == .BoxSearch {
                            self.qrMode = .BoxSearch
                        }
                        
                    case .ItemFeedBoxSelect:
                        if objectTypeReturned == .ItemSearch {
                            self.showQRAlertView(errorType: .objIsItemMstBeBox)
                        }
                    default:
                        print("default")
                    }
                    
                    
                    if objectTypeReturned == .Error {
                        self.showQRAlertView(errorType: .noResults)
                        
                    } else {
                        
                        if let keyReturned = key {
                            print("438 - if let KeyReturnd \(key)")
                            self.prepareObjectKeyToPass(objectKey: keyReturned )
                            
                        }
                    }
                })
                print("4 out of call back I think ")
                
                
            }
        }
        print("5 out of ScannerVC segue Func () ")
        
    }
    
    func prepareObjectKeyToPass(objectKey: String)  {
        print("prepareObjectKeyToPass-objectkey: \(objectKey)")
        
        
        switch qrMode {
        case .ItemSearch, .ItemDetailsQrAssign:
            print("perform segue to ItemDetails")
            self.itemToPass = Item(itemKey: objectKey, itemBoxed: nil, itemCategory: nil)
            self.performSegueWithIdentifier(segueIdentifier: .Existing, sender: self)
            
            
            
        case .BoxSearch:
            print("save BoxSearch")
            
            self.boxToPass = Box(boxKey: objectKey, boxNumber: nil)
            
            self.performSegueWithIdentifier(segueIdentifier: .BoxDetails, sender: self)
            
            
            
        case .ItemFeedBoxSelect:
            print("save item/box assignment")
            let box = Box(boxKey: objectKey, boxNumber: nil)
            
            assignBox(selectedBox:box, itemToBox: self.itemToPass!)
            
        case .Error:
            print("ERRRRROORRRRR")
            
            showQRAlertView(errorType: .iFailed)
            
        default:
            print("default")
        }
    }
    
    
    //    MARK: SCLAlertView
    func showQRAlertView(errorType: ErrorMessages)  {
        print("showQRAlertView")
        
        //        ALERT: Finish implementing enums for error messages
        
        let title = "Unable To Locate"
        let subtitle = "Items or Boxes with this QR code does not exist.\nCreate something new using this QR Code?"
        
        // Create custom Appearance Configuration
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: SFDRegular, size: 20)!,
            kTextFont: UIFont(name: SFTLight, size: 19)!,
            kButtonFont: UIFont(name: SFTRegular, size: 14)!,
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
            
        }
        DispatchQueue.main.async {
            
            _ = alert.showQRerror(title, subTitle: subtitle)
            
        }
        
    }
    
    
    //    MARK: Unwind Box Select
    @IBAction func unwindToItemFeed_FromBoxSel(_ segue:UIStoryboardSegue) {
        //        test - did we save the itemTopass in ItemFeedVC
        print("this is your itemTopass that i saved \(self.itemToPass?.itemName)")
        
        if let boxFeedViewController = segue.source as? BoxFeedVC {
            let selectedBox = boxFeedViewController.boxToPass!
            //            let itemToBox = boxFeedViewController.itemPassed!
            
            assignBox(selectedBox: selectedBox, itemToBox: self.itemToPass!)
        }
    }
    
    func assignBox(selectedBox:Box, itemToBox: Item)  {
        
        if let oldBoxKey = itemToBox.itemBoxKey {
            let oldBox = Box(boxKey: oldBoxKey, boxNumber: nil)
            
            //              Remove item from it's old box'
            oldBox.removeItemDetailsFromBox(itemKey: itemToBox.itemKey)
        }
        
        //          Add  Item Details to Box in Firebase
        selectedBox.addItemDetailsToBox(itemKey: itemToBox.itemKey)
        
        //          Add Box to Item in Firebase
        itemToBox.addBoxDetailsToItem(box: selectedBox)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)
            itemIndexPath = indexPath as NSIndexPath?
            //            test if vc can hold this item until we unwind back
            self.itemToPass  = items[itemIndexPath!.row]
            
        }
        
        switch segueIdentifierForSegue(segue: segue) {
            
        case .ScanQR:
            
            if let navVC = segue.destination as? UINavigationController{
                if let qrScannerVC = navVC.viewControllers[0] as? qrScannerVC{
                    qrScannerVC.qrMode = qrMode
                }
            } else {
                let destiny = segue.destination
                print("destination is \(destiny)")
            }
        case .Existing:
            var  itemToPass: Item!
            if let _ = sender as? UITableViewCell {
                itemToPass = items[itemIndexPath!.row]
            } else {
                if let test = self.itemToPass?.itemKey{
                    print("THIS TEST IS GOOD < WTF > \(test)")
                    
                    itemToPass = self.itemToPass
                }
            }
            
            if let destination = segue.destination as? ItemDetailsVC {
                destination.itemKeyPassed = itemToPass.itemKey
                destination.itemType = .existing
            }
            
        case .BoxDetails:
                if let boxDetailsVC = segue.destination as? BoxDetails{
              
                    boxDetailsVC.box = self.boxToPass
                      boxDetailsVC.boxSegueType = .qr
//                    print("perform segue to BoxDetails with boxKey = \(self.boxToPass?.boxKey)")

            }
            
            
        case .BoxFeed:
            //            when you want to assign item to Box from iTemFeedVC -u must pass the item and set the segueID on Box feed, so it knows to come back
            
            let itemObject  = items[itemIndexPath!.row]
            
            if let destination = segue.destination as? BoxFeedVC {
                destination.segueIdentifier = .ItemFeed
                destination.itemPassed = itemObject
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
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension ItemFeedVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}


extension ItemFeedVC {
    
    func createUIBarButtons() {
        let qrBtn = UIButton(frame: CGRect(x: -6, y: 0, width: 60, height: 60))
        qrBtn.setImage(UIImage(named: "qr_small"), for: UIControlState.normal)
        let qrAction = "qrScan"
        qrBtn.addTarget(self, action: Selector(qrAction), for:  UIControlEvents.touchUpInside)
        let leftItem = UIBarButtonItem(customView: qrBtn)
        leftItem.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftItem
    }
}










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
