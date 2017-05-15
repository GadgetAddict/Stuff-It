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


class BoxFeedVC: UITableViewController ,UINavigationControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SegueHandlerType, qrDelegate {


    
    enum SegueIdentifier: String {
        case New
        case Existing
        case ItemFeed
        case ItemDetail
        case ScanQR
    }
    
    var qrMode: qrScanTypes = .BoxSearch

    var boxes = [Box]()
    lazy var boxIndexPath: NSIndexPath? = nil
    var segueIdentifier: SegueIdentifier = .Existing
    var boxToPass: Box!
    var itemPassed: Item!
    var REF_BOXES: FIRDatabaseReference!

    var boxesREF: FIRDatabaseQuery!
    
    @IBAction func CreateNewBoxBtn(_ sender: Any) {
        pushToNextVC(Segue: .New)
     }
    
 
    func pushToNextVC(Segue: SegueIdentifier) {
        self.hidesBottomBarWhenPushed = true
        performSegueWithIdentifier(segueIdentifier: Segue, sender: self)
        self.hidesBottomBarWhenPushed = false
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 print("BoxFeed view did load")
        createUIBarButtons()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false

        switch segueIdentifier{
        case .ScanQR:
            pushToNextVC(Segue: .Existing)
        default:
            loadBoxes()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.REF_BOXES.removeAllObservers()
    }
    
  
    
    func qrScan() {
        qrMode = .BoxSearch
//        DispatchQueue.main.async {
            self.performSegueWithIdentifier(segueIdentifier: .ScanQR, sender: self)
//            }
    }
    
    func loadBoxes(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        self.REF_BOXES = DataService.ds.REF_INVENTORY.child("boxes")
        
        switch segueIdentifier {

        case .Existing:
            boxesREF = self.REF_BOXES
        default:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
         
                        if let category = self.itemPassed.itemCategory {
                            self.title = "\(category.capitalized) Boxes"
         
    
            self.boxesREF = REF_BOXES.queryOrdered(byChild: "boxCategory").queryEqual(toValue: category)

               }
 
        }


        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        boxesREF.observe(.value, with: { snapshot in
            self.boxes = [] // THIS IS THE NEW LINE
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("boxFeed Snap: \(snap)")
                    if let boxDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let box = Box(boxKey: key, dictionary: boxDict)
                      
                        box.boxItemsKeys = []
                        
                        let cSnap = snap.childSnapshot(forPath: "items")
                              if let itemSnap = cSnap.children.allObjects as? [FIRDataSnapshot] {
                        print("From: \(self.curPage) ->  itemSnap \(itemSnap) ")
                                let itemsCount = itemSnap.count
                                   box.boxItemCount = Int(itemsCount)

                                 for snap in itemSnap {
                                    let itemKey = snap.key
                                        box.boxItemsKeys?.append(itemKey)
                            }
                        }
                        self.boxes.append(box)
                    }
                }
            }
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    
    
    
    func searchTapped() {
        print("boxQR_SEGUE BUTTON TAPPED ")
//        performSegue(withIdentifier: "boxQR_SEGUE", sender: self)
//        instantiateViewController
        
        //        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "qrScanner_navController") as UIViewController
        //        // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
        //
        //        self.present(viewController, animated: false, completion: nil)
    }
    
    
    func cancelButtonTapped(){
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boxes.count
        
    }
    
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "package")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You Have No Boxes"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Add Boxes By Tapping the + Button."
        
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
        
        
        let text = "Add Your First Box"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: view.tintColor
            ] as [String : Any]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        pushToNextVC(Segue: .New)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell  = tableView.dequeueReusableCell(withIdentifier: "BoxCell") as? BoxCell {
            
         
            
            let box = boxes[indexPath.row]
            cell.configureCell(box: box)
            
            return cell
        } else {
            return BoxCell()
        }
    }
 
    
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.boxToPass = boxes[indexPath.row]
    self.REF_BOXES.removeAllObservers()
     
    switch segueIdentifier{
    
        case .Existing:
    pushToNextVC(Segue: .Existing)
 
    case .ItemFeed:
        pushToNextVC(Segue: .ItemFeed)

        default:
            print("")

        }
    }
    
    
        override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            print("DESELECT")
    
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.isSelected {
                    cell.accessoryType = .none
                }
    
            }
        }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var boxLabel: String!
        
        boxIndexPath = indexPath as NSIndexPath?
        let boxToModify  = boxes[indexPath.row]
        let boxNumber = boxToModify.boxNumber
        
        if  let name = boxToModify.boxName {
            boxLabel = name
        } else {
            boxLabel = "Number: \(String(describing: boxNumber))"
        }
       
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "\u{1F5d1}\n Delete", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in

            let alert = UIAlertController(title: "Delete Box: \(boxLabel!) ?", message: "All contents will be Un-Boxed.", preferredStyle: .actionSheet)
            let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: self.handleDeleteItem)
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteItem)

            alert.addAction(DeleteAction)
            alert.addAction(CancelAction)
            self.present(alert, animated: true, completion: nil)
        })
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
    func handleDeleteItem(alertAction: UIAlertAction!) -> Void {
        if let indexPath = boxIndexPath {
            let boxObject  = boxes[indexPath.row]
            boxIndexPath = nil
            self.tableView.reloadData()
            let boxKey = boxObject.boxKey
            self.removeItemsFromDeletedBox(box: boxObject, completion: {
                self.REF_BOXES.child(boxKey).removeValue()
            })
        }
    }
    
    
    func cancelDeleteItem(alertAction: UIAlertAction!) {
        boxIndexPath = nil
        self.tableView.isEditing = false
    }
    
//    If a Box is deleting, un-assign all items from that box
    func removeItemsFromDeletedBox(box: Box, completion: () -> ()) {
        if let itemKeys = box.boxItemsKeys {
            print("From: \(self.curPage) ->  IF LET ITEMKEYS  ")
             for key in itemKeys {
                print("From: \(self.curPage) ->  LOOP - \(key) ")
                 let item = Item(itemKey: key, itemBoxed: nil, itemCategory: nil)
                item.removeBoxDetailsFromItem()
            }
        }
       
        completion()
    }
    
    @IBAction func unwindToBoxFeedFromQRsearch(_ segue:UIStoryboardSegue) {
            print("1 unwindToItemFeedFromQRsearch")
            
            if let qrScannerViewController = segue.source as? qrScannerVC {
                if let scannedString =  qrScannerViewController.qrData {
                    print("2 if let scannedString \(scannedString) ")
                    
                    getDataFromFirebase(qrScan: scannedString, callback: {(key, qrMode)-> Void in
                        print("7 got a key  ->  ")
                        if qrMode == .Error {
                            self.showQRAlertView()
                        } else {
                            if let keyReturned = key {
                                self.prepareObjectKeyToPass(objectKey: keyReturned)
                            } else {
                                self.showQRAlertView()
                                
                            }
                        }
                    })
                    print("4 out of call back I think ")
                    
                    
                }
            }
            print("5 out of ScannerVC segue Func () ")
            
        }
        
        
        
    func prepareObjectKeyToPass(objectKey: String)  {
        
        
        switch qrMode {
        case .ItemSearch, .ItemDetailsQrAssign:
            print("perform segue to ItemDetails")
            self.performSegueWithIdentifier(segueIdentifier: .ItemFeed, sender: self)
        case .BoxSearch, .BoxDetailsQrAssign:
            print("perform segue to BoxDetails")
            self.performSegueWithIdentifier(segueIdentifier: .Existing, sender: self)
        case .ItemFeedBoxSelect:
            print("save item/box assignment")
        case .Error:
            print("ERRRRROORRRRR")
            showQRAlertView()
        default:
            print("default")
        }
    }

    //    MARK: SCLAlertView
    func showQRAlertView()  {
        print("showBoxChangeAlertView")
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
        if let destination = segue.destination as? BoxDetails { //BoxDetailsMaster {

        switch segueIdentifierForSegue(segue: segue) {
        case .New:
            print("")

        case .Existing:
            print("BOX FEED SEGUE - using EXISTING")
            destination.boxSegueType = .existing
                          destination.box = self.boxToPass
        
        case .ScanQR:
            print("BOX FEED SEGUE - ScanQR")

            if let navVC = segue.destination as? UINavigationController{
                print(" SEGUE - navVC")

                if let qrScannerVC = navVC.viewControllers[0] as? qrScannerVC{
                    print(" SEGUE - qrScannerVC. Mode is \(qrMode)")

                    qrScannerVC.qrMode = qrMode
                }
            }
        default:
            print("")

        }
        }
    }
    

        
    


        var curPage = "BoxFeed"
    
}//BoxFeedVC


extension BoxFeedVC {
    
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



//old shit

/*
 
 @IBAction func unwindFromQR(sender: UIStoryboardSegue) {
 if let sourceViewController = sender.source as? qrScannerVC {
 if let selectedBox = sourceViewController.qrData  { //passed from PickBox VC
 self.boxLoadType = .query
 self.query = (child: "boxNum", value: selectedBox)
 }
 }
 }
 
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 print("boxFeed prepareForSegue ")
 
 
 if let destination = segue.destination as? BoxDetails_MasterVC {
 if segue.identifier == "existingBox_SEGUE" {
 
 destination.box = self.boxToPass
 destination.boxSegueType = .existing
 print("Item to Pass is \(itemToPass.itemName)")
 
 } else {
 if segue.identifier == "newBox_SEGUE" {
 print("newBox_SEGUE ")
 destination.setStartingBoxNumber = createStartingNumber
 
 }
 }
 
 
 }
 }
 
 //    MARK: Change Root View Controller -app delegate
 @IBAction func switchButtonPresed(sender: AnyObject) {
 
 // switch root view controllers in AppDelegate
 let appDelegate = UIApplication.shared.delegate as! AppDelegate
 appDelegate.switchViewControllers(storyBoardID: "asdf")
 
 }
 */

