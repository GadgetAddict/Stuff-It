//
//  BoxDetails.swift
//  Inventory17
//
//  Created by Michael King on 2/12/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Firebase

enum SegueType {
    case new
    case existing
    case qr
}


class BoxDetails: UITableViewController,UIImagePickerControllerDelegate, UITextFieldDelegate , UINavigationControllerDelegate, SegueHandlerType {

  
    

    var REF_BOXES = DataService.ds.REF_INVENTORY.child("boxes")
    var box: Box!
    var location: Location!
    
    var boxSegueType: SegueType = .new
    var boxNumber: Int?
    var boxQR:  String?
    
    @IBOutlet weak var detailHeader: UILabel!
    @IBOutlet weak var areaHeader: UILabel!
    @IBOutlet weak var boxTitle: UINavigationItem!
    @IBOutlet weak var boxNameLabel: UITextField!
    @IBOutlet weak var boxCategoryLabel: UILabel!
    @IBOutlet weak var boxStatusLabel: UILabel!
    @IBOutlet weak var boxColorLabel: UILabel!

    @IBOutlet weak var boxLocationLabel: UILabel!
    @IBOutlet weak var boxLocationAreaLabel: UILabel!
    @IBOutlet weak var boxLocationDetailLabel: UILabel!
 
    @IBOutlet weak var BoxContentsCell: UITableViewCell!
    var query = (child: "boxNum", value: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        
      print("box details view did load - box passed \(box.boxKey)")
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        hideLocationLabels()
        
        
        switch boxSegueType {
        case .new:
            let newBoxRef = self.REF_BOXES.childByAutoId()
            self.box = Box(boxKey: newBoxRef.key, boxNumber: nil)
            self.box.getBoxNumber()
            
              boxContentsCellActive(boxIsNew: true)
        case .existing:
            boxContentsCellActive(boxIsNew: false)
            print("Box Details is Existing - ")
            print("Box Details Got Box: \(self.box.boxNumber)- ")

            updateBoxView()
        case .qr:
            boxContentsCellActive(boxIsNew: false)
            loadDataFromFirebase()
        
        }
        
        
        
        
    }

    func navTitle() {
        let label = UILabel(frame: CGRect(x:0, y:0, width:300, height:50))
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "PingFang SC Light", size: 24)
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        if boxSegueType == .new {
            label.numberOfLines = 2
            label.text = "New Box\nNo. \(self.box.boxNumber!)"
 
        } else {
            label.numberOfLines = 1
            label.text = "Box No. \(self.box.boxNumber!)"

        }
        self.navigationItem.titleView = label
    }
    
    var boxCategory = "Un-Categorized" {
        didSet {
            boxCategoryLabel.text? = boxCategory.capitalized
            }
        }
        
        
    var boxStatus:String = "Empty" {
        didSet {
            boxStatusLabel.text? = boxStatus
 
            } 
        }
    
    var boxColor:String? = nil {
        didSet {
            boxColorLabel.text? = boxColor!
            
        }
    }
    
    var boxLocation:String? = nil {
        didSet {
            boxLocationLabel.text? = boxLocation!
            print("boxLocation was set to  \(boxLocation!)")
            self.location = Location(name: boxLocation, detail: nil, area: nil)
        }
    }
    
    var boxLocationArea:String? = nil {
        didSet {
            areaHeader.isHidden = false
            boxLocationAreaLabel.isHidden = false
            boxLocationAreaLabel.text? = boxLocationArea!
            print("boxLocationArea was set to  \(boxLocationArea!)")
            location.locationArea = boxLocationArea

        }
    }
    
    var boxLocationDetail:String? = nil {
        didSet {
            detailHeader.isHidden = false
            boxLocationDetailLabel.isHidden = false
            boxLocationDetailLabel.text? = boxLocationDetail!
            print("boxLocationLabel was set to  \(boxLocationDetail!)")
            location.locationDetail = boxLocationDetail

        }
    }
    
    
    func hideLocationLabels() {
        areaHeader.isHidden = true
        detailHeader.isHidden = true
        boxLocationDetailLabel.isHidden = true
        boxLocationAreaLabel.isHidden = true


    }

    func boxContentsCellActive(boxIsNew: Bool){
//        Set box contents table to be un-touchable if box is new
        BoxContentsCell.isUserInteractionEnabled = !boxIsNew
        BoxContentsCell.isHidden = boxIsNew
        
    }
    
     @IBAction func nameField_endEditing(_ sender: Any) {
        self.resignFirstResponder()
 }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return true
        
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
         checkForEmptyFields()
        
    }
    
    func loadDataFromFirebase() {
    let ref =  self.REF_BOXES.child(self.box.boxKey)
    
        let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true);
        
        spinnerActivity.label.text = "Loading";
        spinnerActivity.detailsLabel.text = "Please Wait!!";
        spinnerActivity.isUserInteractionEnabled = false;
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let fetchFbQueue = DispatchQueue(label: "fetchFB", qos: .userInitiated) // higher importance
        
        fetchFbQueue.async {
            print("boxDetails - inside ASYNC")

            
    ref.observe(.value, with: { snapshot in
    if let boxSnapshotDict = snapshot.value as? Dictionary<String, AnyObject> {
    let box = Box(boxKey: self.box.boxKey, dictionary: boxSnapshotDict)
        
        self.box = box
     
        DispatchQueue.main.async()  {
            self.updateBoxView()

            spinnerActivity.hide(animated: true);
        }
        
        }
            })
        }
    }
    
     
    
    func updateBoxView(){

        if let boxTitle = box.boxName {
            print("Box Title \(String(describing: box.boxName )) ")
            self.title = boxTitle.capitalized
            boxNameLabel.text = boxTitle.capitalized
        } else {
            print("goto NAVTITLE ")
            navTitle()
//            self.title = "Box \(box.boxNumber)"

        }
        
        
        if let color = box.boxColor {
             self.boxColor = color
        }
        
        if let category = box.boxCategory {
//            boxCategoryLabel.text = category.capitalized
            self.boxCategory = category
        }
        
        if let status = box.boxStatus{
//            boxStatusLabel.text = status.capitalized
            self.boxStatus = status
        }
        
        if let location = box.boxLocationName {
        boxLocation = location.capitalized
        } else {
            boxLocationLabel.text = "Set Location"
        }
        
        if let area = box.boxLocationArea {
            self.boxLocationArea = area.capitalized
        }
        
        if let detail = box.boxLocationDetail {
            self.boxLocationDetail = detail.capitalized
        }
    }
    
    func checkForEmptyFields() {
        print("checkForEmptyFields")

 
        self.createBoxDictionary() { (key, dict) -> Void in
        
        self.box.saveBoxToFirebase(boxKey: key, boxDict: dict, completion: { () -> Void in
            
            
            print("save box to FB and then POP ")
            let _ =  EZLoadingActivity.hide(true, animated: true)
            
            popViewController()
        })
        
        }
    }
    
    
    
    
    func createBoxDictionary(withCompletionHandler:(String, Dictionary<String, AnyObject>) -> Void) {
         print("createBoxDictionary")
       let _ =  EZLoadingActivity.show("Saving", disableUI: true)
 
//        let boxKey = self.box.boxKey
//        let newBoxNumber = self.box.boxNumber
        
                let boxDict: Dictionary<String, AnyObject> = [
                    "name" : boxNameLabel.text?.capitalized as AnyObject,
                    "fragile": false as AnyObject,
                    "stackable" : true as AnyObject,
                    "boxCategory" : boxCategory as AnyObject,
//                    "boxQR" : boxQrString as AnyObject,
                     "boxNum" : self.box.boxNumber as AnyObject,
                    "location" : boxLocation as AnyObject ,
                    "location_area" : boxLocationArea  as AnyObject,
                    "location_detail" : boxLocationDetail as AnyObject,
                    "status": boxStatus as AnyObject,
                    "color": boxColor as AnyObject
                ]
        
    /*    var boxKey: String
        
        switch boxSegueType {
        case .new:
            let newBoxRef = self.REF_BOXES.childByAutoId()
            boxKey = newBoxRef.key
         
            getNextNewBoxNumber() { (newBoxNumber) -> Void in
                print("returned NewBoxNumber is \(newBoxNumber ) ")
            boxDict["boxNum"] = newBoxNumber as AnyObject

            }
      
        default:
             boxKey = self.box.boxKey
        }

      */
        
     withCompletionHandler(self.box.boxKey, boxDict)
 
    }
 
 
   
    
    
    
    func popViewController()  {
 
        switch boxSegueType {
        case .qr:
            
            _ = navigationController?.popToRootViewController(animated: true)
        default:
            _ = navigationController?.popViewController(animated: true)

        }
    }
    
//    let questionsRef = Firebase(url:"https://baseurl/questions")
//    questionsRef.queryOrderedByChild("categories/Oceania").queryEqualToValue(true)
//    .observeEventType(.ChildAdded, withBlock: { snapshot in
//    print(snapshot)
//    })
//    
    /*
 
    func getNextNewBoxNumber( withCompletionHandler:(Int) -> Void) {
        var newBoxNumber = 1
        print("getNextNewBoxNumber")
                self.REF_BOXES.queryOrdered(byChild: "boxNum").queryLimited(toLast: 1).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                    print("observeSingleEvent")
                        if let boxSnapshot = snapshot.value as? Dictionary<String, AnyObject> {
                            print(" if let boxSnapshot = snapshot.value")
                                if let boxNum = boxSnapshot["boxNum"] as? Int   {
                                    newBoxNumber = (boxNum + 1)
                                        print("if let boxNum = boxSnapshot \(newBoxNumber)")

            }

                    }
        })
    
    }
    */
    
    func newBoxErrorAlert(_ title: String, message: String) {
        
        // Called upon signup error to let the user know signup didn't work.
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
 
    
    
    
//
//    MARK:  UNWIND AND NAVIGATIOn
    
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
 
        popViewController()
    }
    
    @IBAction func unwindToBoxDetailsCancel(_ segue:UIStoryboardSegue) {
        }
    

    @IBAction func unwindToBoxDetailsWithCategory(_ segue:UIStoryboardSegue) {
        if let categoryPicker = segue.source as? CategoryPicker {
            self.boxCategory = categoryPicker.selectedCategory.category
            print("Unwind Category that came back is \(self.boxCategory)")
        }
    }
    
    
//    will never unwind from here, right  ?
//    @IBAction func unwindToBoxFromQRsearch(_ segue:UIStoryboardSegue) {
//        if let qrScannerViewController = segue.source as? qrScannerVC {
//            if let scannedString =  qrScannerViewController.objectKeyToPass {
//                print("Scanned STring: \(scannedString)")
//            }
//        }
//    }
    
    
    @IBAction func unwindToBoxFromQR_editingQR(_ segue:UIStoryboardSegue) {
        if let qrScannerViewController = segue.source as? qrScannerVC {
            if let scannedString =  qrScannerViewController.qrData {
                print("Scanned STring: \(scannedString)")
             }
        }
    }

    
    
    @IBAction func unwindToBoxDetailsWithLocation(_ segue:UIStoryboardSegue) {
        print("Unwind Locations that came back is .....")

        
        if let locationDetails = segue.source as? LocationDetailsVC {
            if let location = locationDetails.location {
//                print(" Locations name... \(location.locationName!)")

                if let boxLoc = location.locationName {
                    boxLocation = boxLoc
                }
                if let boxArea = location.locationArea {
                    boxLocationArea = boxArea
                }
                if let boxDet = location.locationDetail {
                    boxLocationDetail = boxDet
                }
              }
            
            
        }
    }
    
    
    @IBAction func unwindToBoxDetailsWithStatus(_ segue:UIStoryboardSegue) {
        if let statusVC = segue.source as? BoxStatusTableVC {
            self.boxStatus = (statusVC.selecteStatus?.statusName)!
            print("STATUS that came back is \(self.boxStatus)")
        }
    }
    
    @IBAction func unwindToBoxDetailsWithColor(_ segue:UIStoryboardSegue) {
        if let colorVC = segue.source as? ColorTableVC {
            self.boxColor = (colorVC.selectedColor?.colorName)!
            print("Color that came back is \(self.boxColor ?? "none")")
        }
    }
    
//    @IBAction func unwindToBoxDetailswithQRBOX(_ segue:UIStoryboardSegue) {
//        print("Back to box from QR ")
//        if let QrVC = segue.source as? qrScannerVC {
//             if let selectedBox = QrVC.scannedBox  { //passed from QRVC
//             self.box = selectedBox
////                boxesREF = (self.REF_BOXES.child(query.child).queryEqual(toValue: query.value))
////                self.query = (child: "boxNum", value: selectedBox)
//
//                self.boxIsNew = false
//             }
//         }
//    }
    
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
            switch segueIdentifierForSegue(segue: segue) {
            case .Category:
                if let boxCategoryVC = segue.destination as? CategoryPicker {
                    boxCategoryVC.categorySelection = .box
                    boxCategoryVC.categoryType = .Category
                
                }
            case .Location:
               print("")
            case .Items:
                if let boxItemsVC = segue.destination as? BoxItemsVC {
                    boxItemsVC.box = self.box
                }
            default:
                print("")
        }
    }
    
        enum SegueIdentifier: String {
            case Category
            case Color
            case Items
            case Location
            case Status
         
        }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//    
//        if segue.identifier == "BoxCategorySegue" {
//            print("BoxCategorySegue")
//           if let boxCategoryVC = segue.destination as? CategoryPicker {
//                 boxCategoryVC.categorySelection = .box
//               boxCategoryVC.categoryType = .category
//        }
//        } else if let boxItemsVC = segue.destination as?  BoxItemsVC{
//                    print("destination as? boxItemsVC")
//                    boxItemsVC.box = self.box
//                 
//        } else {
//            if self.boxSegueType == .existing {
//              if let boxLocations = segue.destination as?  LocationDetailsVC {
//                boxLocations.passedALocation = true
//                boxLocations.location = self.location
//                }
//            }
//        }
//        
//    }

        var curPage = "BoxDetails"
}
 
