//
//  CategoryPicker.swift
//  Inventory17
//
//  Created by Michael King on 2/15/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

enum CategoryType:String {
    case Category
    case Subcategory
}


class CategoryPicker: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SegueHandlerType {
    
    enum SegueIdentifier: String {
        case Unwind
        case Cancel
        case BoxCancel
        case Box
    }
    
    var passedCategory: String!
    var selectedCategory: Category!
    var categories = [Category]()
    var categoryType = CategoryType.Category
    var categorySelection: CategorySelection = .item
    var categoryIndexPath: NSIndexPath? = nil
    var REF_CATEGORY: FIRDatabaseReference!
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    
        setupPage()
        
        self.REF_CATEGORY = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/categories/\(categoryType.rawValue.lowercased())")
        
        loadDataFromFirebase()

    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
 
    }// End ViewDidLoad
    
    
    func setupPage() {
        
          self.title =  categoryType.rawValue
        
        switch categorySelection {
        case .item:
         print("This is the ITEMS Category selection")
        case .box:
            print("This is the BOX Category selection")

        case .settings:
            if categoryType == .Subcategory {
                tableView.allowsSelection = false
            }
        }
    }
    
    
    func segue(segue: SegueIdentifier) {
        performSegueWithIdentifier(segueIdentifier: segue , sender: self)
    }
    
   
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        switch categorySelection {
           case .box:
                segue(segue: .BoxCancel)
            default:
                segue(segue: .Cancel)
        }
    }
    
    
//    MARK: DNZ Empty Table View    DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
        
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "package")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You Have No Items"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Add your first item by tapping the + button."
        
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
        print( "Add First Item" )
        
        let text = "Add First Item"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: view.tintColor
            ] as [String : Any]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        print("something tappped")
    }
    
    
    
//    MARK: TableView Setup
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("CALLING THE SEGUE CELL")
        self.selectedCategory = categories[indexPath.row]
        
        
        performSegueWithIdentifier(segueIdentifier: .Unwind, sender: self)

        switch categorySelection {
 
        case .box:
            segue(segue: .Box)
        default:
            segue(segue: .Unwind)
        }
        
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let category = categories[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryPickerCell") as? CategoryPickerCell {
            cell.configureCell(category: category, categoryType: categoryType)
            
            
            return cell
        } else {
            return LocationPickerCell()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        categoryIndexPath = indexPath as NSIndexPath?
        let categoriesToDelete  = categories[indexPath.row]
        let categoryName = categoriesToDelete.category!
        
        
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "\u{1F5d1}\n Delete", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            let alert = UIAlertController(title: "Wait!", message: "Are you sure you want to permanently delete: \(String(describing: categoryName))?", preferredStyle: .actionSheet)
            
            let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: self.handleDeleteItem)
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteItem)
            
            alert.addAction(DeleteAction)
            alert.addAction(CancelAction)
            
            
            self.present(alert, animated: true, completion: nil)
            
        })
        
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    
    
    func handleDeleteItem(alertAction: UIAlertAction!) -> Void {
        if let indexPath = categoryIndexPath {
            
            tableView.beginUpdates()
            let category  = categories[indexPath.row]
            let categoryKey = category.categoryKey
            print("Cat Key is \(String(describing: categoryKey))")
            self.REF_CATEGORY.child(categoryKey!).removeValue()
            categoryIndexPath = nil
            tableView.endUpdates()
            
        }
    }
    
    
    
    
    
    func cancelDeleteItem(alertAction: UIAlertAction!) {
        categoryIndexPath = nil
        self.tableView.isEditing = false

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    
    
    
    func showErrorAlert(title: String, msg: String) {
        let alertView = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
        
    }
    
    
    
    
    
    @IBAction func addNewCategory(sender: AnyObject) {
        
        var exampleText: String!
        
        switch categoryType {
            
        case .Category:
            exampleText = "Holiday, Christmas, Kitchen, Outdoor"
        case .Subcategory:
            exampleText = "Lights, Decorations, Glasses, Camping"
            
        }
        
        
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "New \(categoryType.rawValue.capitalized)",
            message: "Enter a name for this new \(categoryType.rawValue.capitalized)",
            preferredStyle: .alert)
        
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = exampleText
        })
        
        let action = UIAlertAction(title: "Submit",
                                   style: UIAlertActionStyle.default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        let enteredText = theTextFields[0].text
                                        //
                                        
                                        self!.writeToFb(enteredText: enteredText!)
                                        
                                    }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            
        }
        
        alertController?.addAction(action)
        alertController?.addAction(cancel)
        alertController!.view.setNeedsLayout()
        self.present(alertController!,
                     animated: true,
                     completion: nil)
    }
    
    
    
    
    
    func writeToFb(enteredText: String) {
        
        let newCategoryTrimmed = enteredText.trimmingCharacters(in: NSCharacterSet.whitespaces).capitalized
        
        let category = [categoryType.rawValue : newCategoryTrimmed]
        
        REF_CATEGORY.childByAutoId().setValue(category)
        
       loadDataFromFirebase()
        
    }
    
    
    
    func loadDataFromFirebase() {
        
        if categoryType == .Subcategory {
            self.REF_CATEGORY = self.REF_CATEGORY.child(passedCategory!)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.REF_CATEGORY.observe(.value, with: { snapshot in

            self.categories = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("Cat Snap: \(snap)")
                    
                    if let categoryDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let category = Category(categoryKey: key, dictionary: categoryDict)
                        self.categories.append(category)
                    }
                }
            }
            
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        })
    }
    
    
 
    
 
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepareForSegue from Category PIcker ")
        if let cell = sender as? UITableViewCell {
            print("sender as? UITableViewCell ")
            
            let indexPath = tableView.indexPath(for: cell)
            
            self.selectedCategory = categories[indexPath!.row]
         
        }
        
    }
    
    var curPage = "CategoryPicker"
}


