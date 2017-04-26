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

enum BoxLoadType{
    case all
    case query
    case itemFeed_matchCategory
    case itemDetails_matchCategory
    
}


class BoxFeedVC: UITableViewController ,UINavigationControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var selectedBox:String?      
    
    
    var FbHandle: UInt!   // set to remove observer when viewDisappears
    var REF_BOXES: FIRDatabaseReference!
    var boxes = [Box]()
    lazy var itemIndexPath: NSIndexPath? = nil
    var boxLoadType: BoxLoadType = .all
    var boxToPass: Box!
    var itemPassed: Item!
    var boxesREF: FIRDatabaseQuery?
//    var query = (child: "boxNum", value: "")     //haven't set up boxFeed QR search query yet
    
    @IBAction func CreateNewBoxBtn(_ sender: Any) {
     performSegue(withIdentifier: "newBox_SEGUE", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         loadBoxes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.REF_BOXES.removeAllObservers()
    }
    
    func gotoSearchPage()  {
        print("Tapped")
    }
    
    func loadBoxes(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        self.REF_BOXES = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes")
        
        
        switch boxLoadType {
        case .all:
            
            //            MARK: Create UIBarButtonItems
//            let addBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
//            addBtn.setImage(UIImage(named: "Plus 2 Math_60"), for: UIControlState.normal)
//            let newACtion = "newBox"
//            addBtn.addTarget(self, action: Selector(newACtion), for:  UIControlEvents.touchUpInside)
//            let rightItem = UIBarButtonItem(customView: addBtn)
//            self.navigationItem.rightBarButtonItem = rightItem
//            
//            
//            let searchBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
//            searchBtn.setImage(UIImage(named: "Search_50"), for: UIControlState.normal)
//            let searchAction = "searchTapped"
//            searchBtn.addTarget(self, action: Selector(searchAction), for:  UIControlEvents.touchUpInside)
//            let leftItem = UIBarButtonItem(customView: searchBtn)
//            self.navigationItem.leftBarButtonItem = leftItem

            boxesREF = self.REF_BOXES
            
            
        case .query:
            print("Query")
//            boxesREF = (self.REF_BOXES.child(query.child).queryEqual(toValue: query.value))
            
            
        default:
            
//            MARK: on query, get only boxes that do not already have item assigned
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
            
            if let category = self.itemPassed.itemCategory {
                self.title = "\(category.capitalized) Boxes"

                boxesREF = REF_BOXES.queryOrdered(byChild: "boxCategory").queryEqual(toValue: category)
                
            }
            
            if let passedItemCurrBox = self.itemPassed.itemBoxNum {
                print("passed curr box boxNum \(passedItemCurrBox) ")
            }
            
        }
        
        
        boxesREF!.observe(.value, with: {(snapshot)  in
            self.boxes = [] // THIS IS THE NEW LINE
            
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("Box Feed Snap: \(snap)")
                    if let boxDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        if self.selectedBox != key {
                         let countItemsREF = self.REF_BOXES.child(key).child("items")
                        countItemsREF.observe(.value, with: { (itemCountSnapshot) in
                            
                            let theCount = itemCountSnapshot.childrenCount
                            
                            let box = Box(boxKey: key, dictionary: boxDict)
                            box.boxItemCount = Int(theCount)
                          
                          
                            self.boxes.append(box)
                            
                             
                            
                            self.tableView.reloadData()
                        })
                    }
                }
                
            }
        }
        })
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    func newBox()  {
        performSegue(withIdentifier: "newBox_SEGUE", sender: self)
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
        self.performSegue(withIdentifier: "newBox_SEGUE", sender: self)
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
        switch boxLoadType {
        case .all:
            print("You Tapped  \(boxes[indexPath.row].boxCategory!)")
            self.REF_BOXES.removeAllObservers()
            print("BoxFeed: boxLoadType ALL    Did  Select Box -> removeAllObservers")
            
            self.boxToPass = boxes[indexPath.row]
            self.performSegue(withIdentifier: "existingBox_SEGUE", sender: self)
            
        case .itemFeed_matchCategory:
            self.REF_BOXES.removeAllObservers()
            print("BoxFeed: boxLoadType from iTem Feed -match  CATEGORY ")
            self.boxToPass = boxes[indexPath.row]
            print("You Chose Box-key:  \(self.boxToPass.boxKey)")
            
            self.performSegue(withIdentifier: "unwindToItemFeed_FromBoxSel", sender: self)
       
        case .itemDetails_matchCategory:
            self.REF_BOXES.removeAllObservers()
            print("BoxFeed: boxLoadType from iTem DETAILS  -match  CATEGORY ")
            
            self.boxToPass = boxes[indexPath.row]
            print("You Chose Box-key:  \(self.boxToPass.boxKey)")
            
            self.performSegue(withIdentifier: "unwindToItemDetailsFromListBoxSel", sender: self)
    
            
        case .query:
            self.boxToPass = boxes[indexPath.row]
            self.performSegue(withIdentifier: "existingBox_SEGUE", sender: self)
            
        }
    }
    
    //    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    //        print("DESELECT")
    //
    //        if let cell = tableView.cellForRow(at: indexPath) {
    //            if cell.isSelected {
    //                cell.accessoryType = .none
    //            }
    //
    //        }
    //    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var boxLabel: String!
        
        itemIndexPath = indexPath as NSIndexPath?
        let boxToModify  = boxes[indexPath.row]
        let boxNumber = boxToModify.boxNumber
        
        if  let name = boxToModify.boxName {
            boxLabel = name
        } else {
            boxLabel = "Number: \(String(describing: boxNumber))"
        }
        
        //                    let itemKey = itemToModify.itemKey
        
        
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
        print("IN THE DELETE FUNCTION")
        if let indexPath = itemIndexPath {
            
            tableView.beginUpdates()
            let boxObject  = boxes[indexPath.row]
            let boxKey = boxObject.boxKey
            self.REF_BOXES.child(boxKey).removeValue()
            itemIndexPath = nil
            tableView.endUpdates()
            
        }
        
    }
    
    
    func cancelDeleteItem(alertAction: UIAlertAction!) {
        itemIndexPath = nil
    }
    
    
    
    
    
    
    //
    //
    //        @IBAction func unwindFromQR(sender: UIStoryboardSegue) {
    //        if let sourceViewController = sender.source as? qrScannerVC {
    //            if let selectedBox = sourceViewController.qrData  { //passed from PickBox VC
    //            self.boxLoadType = .query
    //            self.query = (child: "boxNum", value: selectedBox)
    //            }
    //                    }
    //        }
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("boxFeed prepareForSegue ")
        

        if let destination = segue.destination as? BoxDetails {
            if segue.identifier == "existingBox_SEGUE" {
                 
                destination.box = self.boxToPass
                destination.boxSegueType = .existing
                //                    print("Item to Pass is \(itemToPass.itemName)")
                
                //                    } else {
                //                        if segue.identifier == "newBox_SEGUE" {
                //                            print("newBox_SEGUE ")
                //                        destination.setStartingBoxNumber = createStartingNumber
                //
                //                }
            }
            
            
        }
    }
    
//    MARK: Change Root View Controller -app delegate
    @IBAction func switchButtonPresed(sender: AnyObject) {
        
        // switch root view controllers in AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.switchViewControllers(storyBoardID: "asdf")
        
    }
    
}//itemFeedVC


