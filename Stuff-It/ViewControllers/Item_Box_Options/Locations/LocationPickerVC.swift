//
//  LocationPickerVC.swift
//  Inventory17
//
//  Created by Michael King on 2/13/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

enum LocationType:String {
        case name
        case area
        case detail
    }


class LocationPickerVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
 
    var passedLocation: Location!

    var selectedLocation: Location!
    var locations = [Location]()
    var locationType = LocationType.name
    var locationIndexPath: NSIndexPath? = nil
    var collectionID: String!
    
    var REF_LOCATION: FIRDatabaseReference!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
      
    
        
        
        
    } // End ViewDidLoad

    override func viewWillAppear(_ animated: Bool) {
            self.REF_LOCATION = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/locations/\(locationType.rawValue)")
        loadDataFromFirebase()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        REF_LOCATION.removeAllObservers()
    }
 
    
    
func editButtonPressed(){
    tableView.setEditing(!tableView.isEditing, animated: true)
    if tableView.isEditing == true{
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LocationPickerVC.editButtonPressed))
    }else{
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LocationPickerVC.editButtonPressed))
    }
}
 
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
         return locations.count
    }
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let location = locations[indexPath.row]
    
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as? LocationPickerCell {
            cell.configureCell(location: location, locationType: locationType)
    
    
            return cell
        } else {
            return LocationPickerCell()
        }
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "package")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You Have No Locations Saved"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Add your first \(locationType.rawValue.capitalized) by tapping the + button."
        
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
        
        let text = "Add First Location"
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: view.tintColor
            ] as [String : Any]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        print("Empty Did Tap Button")
    
    }

    
    
    // MARK: UITableViewDelegate Methods
   
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
    
        locationIndexPath = indexPath as NSIndexPath?
        let locationsToDelete  = locations[indexPath.row]
        let locationName = locationsToDelete.locationName
    
    
    
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "\u{1F5d1}\n Delete", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
    
            let alert = UIAlertController(title: "Wait!", message: "Are you sure you want to permanently delete: \(locationName ?? "this Location")?", preferredStyle: .actionSheet)
    
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
    
    
    // Delete Confirmation and Handling
    func confirmDelete(Item: String) {

        let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to permanently delete '\(Item)' ?", preferredStyle: .actionSheet)
    
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteItem)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteItem)
    
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
    
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDeleteItem(alertAction: UIAlertAction!) -> Void {

        if let indexPath = locationIndexPath {

             let location  = locations[indexPath.row]
            let locationKey = location.locationKey
            self.REF_LOCATION.child(locationKey!).removeValue()
            locationIndexPath = nil
            tableView.reloadData()
    
        }
    }
    
    
    
    func cancelDeleteItem(alertAction: UIAlertAction!) {
        self.tableView.isEditing = false
        locationIndexPath = nil
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    
    func showErrorAlert(title: String, msg: String) {
        let alertView = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addNewLocation(sender: AnyObject) {
 
        var exampleText: String!
        
         switch locationType {
            
        case .name:
            exampleText = "Garage, Attic, Storage"

        case .area:
            exampleText = "File Cabinet, Desk, East Wall"

        case .detail:
            exampleText = "Top Drawer,  Shelf 2, Floor"
            
        }
        
        
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "New Location \(locationType.rawValue.capitalized)",
                                            message: "Enter the new location \(locationType.rawValue)",
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
 
        
        
        print("Location Picker postToFirebase")
        
        let newLocationTrimmed = enteredText.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        let location = [locationType.rawValue : newLocationTrimmed.capitalized]
 
        
        REF_LOCATION.childByAutoId().setValue(location)
        
        
    }
    
    

    func loadDataFromFirebase() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
       
        switch locationType {
        case .area:
            print("area")
            self.REF_LOCATION = self.REF_LOCATION.child(passedLocation.locationName!)

        case .detail:
         print("Detail")
         self.REF_LOCATION = self.REF_LOCATION.child(passedLocation.locationArea!)

        case .name:
            print("name")
//            self.REF_LOCATION = self.REF_LOCATION.child(passedLocation.locationName!)
           
        }
         print("REF_LOCATION: \(REF_LOCATION!)")
        
            self.REF_LOCATION.observe(.value, with: { snapshot in

                self.locations = []
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshots {
                        print("LocationrSnap: \(snap)")
        
                        if let locationDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let location = Location(locationKey: key, dictionary: locationDict)
                            self.locations.append(location)
                        }
                    }
                }
                
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            })
        }

   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepareForSegue ")
        if let cell = sender as? UITableViewCell {
            print("sender as? UITableViewCell ")
           
            let indexPath = tableView.indexPath(for: cell)

             self.selectedLocation = locations[indexPath!.row]
            
            if segue.identifier == "unwindWithSelectedLocation" {
                print("saveLocationDetail SEGUE ")
            }

                }
            }
        
        
        
        var curPage = "LocationPicker"

        }







