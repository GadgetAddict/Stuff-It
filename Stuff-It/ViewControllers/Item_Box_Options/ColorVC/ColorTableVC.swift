//
//  ColorTableVC.swift
//  Inventory17
//
//  Created by Michael King on 2/12/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

enum ColorLoadsFrom:String {
    case box
    case item
    case settings
}

class ColorTableVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var segueId: String!
        var colors = [Color]()
         var colorLoadsFrom: ColorLoadsFrom = .box
        var selectedColor: Color?
        var colorIndexPath: NSIndexPath? = nil
         var REF_COLOR: FIRDatabaseReference!
        
        
        @IBAction func doneButton(sender: UIBarButtonItem) {
            //        self.dismiss(animated: true, completion: nil)
            _ = navigationController?.popViewController(animated: true)
            
        }
        
        @IBAction func addNewColor(sender: AnyObject) {
            
            var alertController:UIAlertController?
            alertController = UIAlertController(title: "New Color",
                                                message: "Enter a new color",
                                                preferredStyle: .alert)
            
            alertController!.addTextField(
                configurationHandler: {(textField: UITextField!) in
                    textField.placeholder = "Enter new Color"
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
        
  
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self

            tableView.tableFooterView = UIView()
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            
            switch colorLoadsFrom {
            case .box:
                print("BOX")
                self.segueId = "unwindToBoxDetailsWithColor"

            case .item:
                self.segueId = "unwind_saveColorToItemDetails"
            case .settings:
                tableView.allowsSelection = false
                
            }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
        loadDataFromFirebase()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        REF_COLOR.removeAllObservers()
    }
    
    func autoGenerateColorList() {
        
//        write code to add a few colors to FB
        
    }
        
        func writeToFb(enteredText: String) {
            print("I'm in postToFirebase")
            
            let newColorTrimmed = enteredText.trimmingCharacters(in: NSCharacterSet.whitespaces)
            
            let color = ["colorName": newColorTrimmed.capitalized]
            
            
            let REF_COLOR = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/colors").childByAutoId()
            
            REF_COLOR.setValue(color)
            
            //                self.dismiss(animated: true, completion: {})
            self.loadDataFromFirebase()
    }
        
        
        
        
        func loadDataFromFirebase() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            self.REF_COLOR = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/colors")
            
            
              self.REF_COLOR.observe(.value, with: { snapshot in
                
                self.colors = []
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshots {
                        print("ColorSnap: \(snap)")
                        
                        if let colorDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let color = Color(colorKey: key, dictionary: colorDict)
                                self.colors.append(color)
                         }
                    }
                }
                
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            })
        }
        
        
    // MARK: - Table view Settings

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    // MARK: - Table view data source

        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            tableView.backgroundView = nil
//                  self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            
            return colors.count
            
    }
    
    
    
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let color = colors[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell") as? ColorCell {
                cell.configureCell(color: color)
                
                
                return cell
            } else {
                return ColorCell()
            }
        }
    
    
    

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "package")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Add colors"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Items and Boxes can be assigned a color.\n Add colors to the list."
        
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
        
        let text = "Automatically Add Colors Now."
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: view.tintColor
            ] as [String : Any]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        autoGenerateColorList()
    }
    
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){
        print("CALLING THE SEGUE CELL")
        self.selectedColor = colors[indexPath.row]
        
        self.performSegue(withIdentifier: self.segueId , sender: self)
    }
    
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        colorIndexPath = indexPath as NSIndexPath?
        let colorsToDelete  = colors[indexPath.row]
        let colorName = colorsToDelete.colorName
        
        
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "\u{1F5d1}\n Delete", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            let alert = UIAlertController(title: "Wait!", message: "Are you sure you want to permanently delete: \(String(describing: colorName!))?", preferredStyle: .actionSheet)
            
            let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: self.handleDeleteItem)
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: self.cancelDeleteItem)
            
            alert.addAction(DeleteAction)
            alert.addAction(CancelAction)
            
            
            self.present(alert, animated: true, completion: nil)
            
        })
        
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction]
    }
    
   

    func cancelDeleteItem(alertAction: UIAlertAction!) {
        self.tableView.isEditing = false
        colorIndexPath = nil
    }
   
     func handleDeleteItem(alertAction: UIAlertAction!) -> Void {
            if let indexPath = colorIndexPath {
                
                 let color  = colors[indexPath.row]
                let colorKey = color.colorKey
                print("Color Key is \(String(describing: colorKey))")
                self.REF_COLOR.child(colorKey!).removeValue()
                colorIndexPath = nil
                tableView.reloadData()
                
            }
        }

    
        func showErrorAlert(title: String, msg: String) {
            let alertView = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertView, animated: true, completion: nil)
            
        }
        
//        
//        func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//            if segue.identifier == "unwind_saveColorToItemDetails" {
//                print("unwind_saveColorToItemDetails" )
//                if let cell = sender as? UITableViewCell {
//                    let indexPath = tableView.indexPath(for: cell)
//                    if let index = indexPath?.row {
//                        print("Color  IF LET CELL" )
//
//                        let color = colors[index]
//                        self.selectedColor  = color.colorName
//                    }
//                }
//            }
//        }
//        
    var curPage = "ColorTable"

}  //End Class

