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


class BoxFeedVC: UITableViewController ,UINavigationControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SegueHandlerType {     //,UISearchBarDelegate, UISearchDisplayDelegate {

   
    enum SegueIdentifier: String {
        case BoxDetailNew
        case BoxDetailExist
        case ItemFeed
        case ItemDetail
    }
    enum BoxMode{
        case AllBoxes
        case BoxAssignment
    }
 
    var tableStatus: tableLoadingStatus = .loading
    
    var box: Box!
    let searchController = UISearchController(searchResultsController: nil)
    var filteredBoxes = [Box]()
    var itemPassed: Item!
    var boxes = [Box]()
    lazy var boxIndexPath: NSIndexPath? = nil
 
    var segueIdentifier: SegueIdentifier = .BoxDetailExist
    var boxMode: BoxMode = .AllBoxes
    var REF_BOXES: FIRDatabaseReference!
    var boxesREF: FIRDatabaseQuery!
    
    
    @IBAction func CreateNewBoxBtn(_ sender: Any) {
       
        segue(Segue: .BoxDetailNew)
     }
    
    @IBAction func tappedRightBarButton(_ sender: UIBarButtonItem) {
        let startPoint = CGPoint(x: self.view.frame.width - 60, y: 55)
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 180))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.textAlignment = .center
        label.text = "I'am a test label"
        aView.addSubview(label)
        let popover = Popover(options: nil, showHandler: nil, dismissHandler: nil)
        popover.show(aView, point: startPoint)
    }
    
    
    
    func segue(Segue: SegueIdentifier) {
        performSegueWithIdentifier(segueIdentifier: Segue, sender: self)
     }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        print("BoxFeed-WillAppear- boxMode: \(boxMode)")
        self.tabBarController?.tabBar.isHidden = false
                    loadBoxes()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("boXfeed- viewWillDisappear")
        super.viewWillDisappear(animated)
        self.REF_BOXES.removeAllObservers()
    }
 
    
    func loadBoxes(){
        print("BoxFeed view did load")
        
        print("BoxFeed segue:  \(segueIdentifier)   boxMode: \(boxMode)")

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        self.REF_BOXES = DataService.ds.REF_INVENTORY.child("boxes")
        
        switch boxMode {
            
        case .AllBoxes:
            boxesREF = self.REF_BOXES
        case .BoxAssignment:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
            
            
            if let category = self.itemPassed.itemCategory {
                self.title = "\(category.capitalized) Boxes"
                
                
                self.boxesREF = REF_BOXES.queryOrdered(byChild: "boxCategory").queryEqual(toValue: category)
            
                if category != "Un-Categorized" {
                getUncategorizedBoxes()
                }
                            
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
                        print("From: \(self.curPage) ->  itemCountSnap \(itemSnap) ")
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
    
    

    func getUncategorizedBoxes(){
       print("Get mixd content boxes")
        let uncategorizedREF = self.REF_BOXES.queryOrdered(byChild: "allowMixedContent").queryEqual(toValue:true)
        uncategorizedREF.observe(.value, with: { uncatsnapshot in
            
            if let snapshots = uncatsnapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("boxFeed Mixed Snap: \(snap)")
                    if let boxDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let box = Box(boxKey: key, dictionary: boxDict)
                        self.boxes.append(box)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func cancelButtonTapped(){
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {


            return self.filteredBoxes.count
        } else {
            return self.boxes.count
 
        }
        
        
    }
    
    func emptyDataSetShouldFade(in scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        var shouldDisplay = false
        if tableStatus == .finished {
         shouldDisplay = true
        }
        return shouldDisplay
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        print("func emptyDataSetWillAppear")
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
            text = "No Boxes Found"
        } else {
            text = "You Have No Boxes Saved."
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
            text = "Search by Name or Category or Location to find a box."
            
        } else {
             text = "Add Boxes By Tapping the + Button."
            
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
        segue(Segue: .BoxDetailNew)
    }
    
    
    //    MARK: Search Function
    
    func filterSearchText() {
        print("BoxFeed Running filterSearchText")
        
        let searchText = searchController.searchBar.text
        let scope = searchController.searchBar.selectedScopeButtonIndex
        // Filter the array using the filter method
        filteredBoxes = boxes.filter({( box : Box) -> Bool in
            
            var fieldToSearch: String!
            switch (scope) {
            case (0):
                fieldToSearch = box.boxName
            case (1):
                fieldToSearch = box.boxCategory
                
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
    
    
    /*
    func filterContentForSearchText(_ searchText: String, scope: String = "Name") {
     
        filteredBoxes = boxes.filter({( box : Box) -> Bool in
            var searchedBox: String!
            var categoryMatch: Bool!
            switch scope {
            case "Name":
                categoryMatch = (scope == "Name") || (box.boxName == scope)
                searchedBox = box.boxName
            case "Category":
                categoryMatch = (scope == "Category") || (box.boxCategory == scope)
                searchedBox = box.boxCategory
//            case "Location":
//                categoryMatch = (scope == "Location") || (box.boxLocationName == scope)
//                searchedBox = box.boxLocationName
  
            default:
               print()
                
            }
            
            
            let result = categoryMatch && searchedBox.lowercased().contains(searchText.lowercased())
            return result
        })
        tableView.reloadData()
    }
    */
    
    private var isLoadingTableView = true

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
 
        if isLoadingTableView && indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            isLoadingTableView = false
            //do something to table once it's done loading
            
            tableStatus = .finished
            print(" I should be done loading ")
        }

        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
       
        if let cell  = tableView.dequeueReusableCell(withIdentifier: "BoxCell") as? BoxCell {
            let box: Box
            if searchController.isActive && searchController.searchBar.text != "" {
                box = filteredBoxes[indexPath.row]
            } else {
                box = boxes[indexPath.row]
            }
            
           
            cell.configureCell(box: box)
            
            return cell
        } else {
            return BoxCell()
        }
        
    }
 
    
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if searchController.isActive {
    self.box = filteredBoxes[indexPath.row]
    print("box feed - tapped box, box: \(self.box)")
        searchController.isActive = false
    } else {
        self.box = boxes[indexPath.row]

    }
        self.REF_BOXES.removeAllObservers()
    
    switch boxMode {
    case .BoxAssignment:
        print("box feed - seg: BoxAssignment \(String(describing: self.box.boxName))")

            segue(Segue: segueIdentifier)
    case .AllBoxes:
        print("box feed - seg: AllBoxes \(String(describing: self.box.boxName))")

            segue(Segue: .BoxDetailExist)
   
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
        var boxToModify: Box
        
        if searchController.isActive {
            boxToModify  = filteredBoxes[indexPath.row]
        } else {
            boxToModify  = boxes[indexPath.row]
        }
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
            
            var boxObject: Box
            if searchController.isActive {
                boxObject  = filteredBoxes[indexPath.row]
            } else {
                boxObject  = boxes[indexPath.row]
            }
            
       
            let boxKey = boxObject.boxKey
            self.removeItemsFromDeletedBox(box: boxObject, completion: {
                self.REF_BOXES.child(boxKey).removeValue()
            })
            boxIndexPath = nil
            
            self.tableView.reloadData()
            if searchController.isActive {
                print("End of Delete Function")
                filterSearchText()
            }

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
    
    

    
    
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
        if let destination = segue.destination as? BoxDetails { //BoxDetailsMaster {
            print("Box Feed-> destination is BoxDetails - ")

            switch segueIdentifierForSegue(segue: segue) {
                
            case .BoxDetailExist:
                destination.boxSegueType = .existing
                destination.box = self.box
                print("Box Feed-> destination.box is self.box \(self.box.boxNumber) - ")

            case .BoxDetailNew:
                destination.boxSegueType = .new


            default:
                break
            }
        }
        }
 
  
    
    
    //    MARK: ErrorAlert
    func newBoxErrorAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
        
    


        var curPage = "BoxFeed"
    
}//BoxFeedVC


extension BoxFeedVC: QrDelegate{
     func useReturnedFBKey<inventoryObject>(object: inventoryObject, completion: (Bool) -> ()) {

    }
    
}
extension BoxFeedVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        filterSearchText()
        
    }
}

extension BoxFeedVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchText()
        //        let searchBar = searchController.searchBar
        //        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        //        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}


//extension BoxFeedVC {
//    
//    func createUIBarButtons() {
//    let qrBtn = UIButton(frame: CGRect(x: -6, y: 0, width: 60, height: 60))
//    qrBtn.setImage(UIImage(named: "qr_small"), for: UIControlState.normal)
//    let qrAction = "qrScan"
//    qrBtn.addTarget(self, action: Selector(qrAction), for:  UIControlEvents.touchUpInside)
//    let leftItem = UIBarButtonItem(customView: qrBtn)
//    leftItem.tintColor = UIColor.white
//    self.navigationItem.leftBarButtonItem = leftItem
//    }
//}



