//
//  ItemDetailsVC.swift
//  Inventory17
//
//  Created by Michael King on 1/20/17.
//  Copyright © 2017 Microideas. All rights reserved.
//


import UIKit
import Firebase
import ExpandingMenu

enum ItemType {
    case new
    case existing
    case boxItem
}

enum ImageStatus{
    case noImage  //keep placeholder
    case existingImage   //don't change anything
    case newImage   //upload new image and write URL to Firebase
}

enum BoxChangeType{
    case add
    case update
    case remove
    case none
}



class ItemDetailsVC: UITableViewController,UIImagePickerControllerDelegate , UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    var itemType: ItemType = .new
    var boxChangeType: BoxChangeType = .none
    var item: Item!
    var itemsBox: Box!
    
 
    var REF_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items")
    var collectionId: String!
    
    var imageChanged: ImageStatus = .noImage
    
    var fragileStatus: Bool = false

    @IBOutlet weak var boxDetailsTableCell: UITableViewCell!
    @IBOutlet weak var fragileSwitch: SevenSwitch!
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var itemCategory: UILabel!
    @IBOutlet weak var itemSubCategory: UILabel!
    @IBOutlet weak var itemColor: UILabel!
    @IBOutlet weak var itemQty: UITextField!
    @IBOutlet weak var boxNumberHeaderLabel: UILabel!
    @IBOutlet weak var boxDetails: UILabel!
    @IBOutlet weak var subcategoryHeading: UILabel!
  
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
  
        
        
//        var label = UILabel()
//        let bigBoldFont = UIFont.boldSystemFont(ofSize: 18.0)
//        
//        var attrString = NSMutableAttributedString(string: "This text is bold.")
//        attrString.addAttribute(kCTFontAttributeName as String, value: bigBoldFont, range: NSMakeRange(13, 4))
//        
//        label.attributedText = attrString
        createNumPadToolbar()
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)

 
       
        switch itemType {
            
        case .boxItem:
            loadPassedItem()
updateBoxDetailsView()
            
            boxChangeType = .update
            boxDetailsTableCell.isHidden = false
            boxDetailsTableCell.isUserInteractionEnabled = true
 
        case .existing:

            updateViewWithItem()
//           Because item is in a box - any box changes will be .update, so create box object to hold current box details
           
           if let itemsBoxKey = self.item.itemBoxKey {
            self.itemsBox = Box(boxKey: itemsBoxKey)
            loadItemBoxDetailsFromFireBase()
            boxChangeType = .update
            }
           
            self.downloadImageFromFirebase()


        case .new:
           
            self.item = Item(itemBoxed: false, itemCategory: nil)
            
            boxDetailsTableCell.isHidden = true
            boxDetailsTableCell.isUserInteractionEnabled = false
            
            self.title = "New Item"
         
            
            configureExpandingMenuButton()

         }
     
    
        // Image Picker Setup 
        picker.delegate = self
        myImageView.layer.borderWidth = 2.0
        myImageView.layer.borderColor = UIColor.white.cgColor
        myImageView.layer.cornerRadius = myImageView.frame.height / 2.0
        myImageView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        blurredImage.addSubview(blurEffectView)
        blurredImage.clipsToBounds = true
        
    }   // END VIEW DID LOAD
    
    
    func completionFunction(completion: () -> ()) {
        
        completion()
        
    }
    
    
    func updateSaveButton()  {
        
 
//            Make Save Button BOLD!
 
    }
    
    
    
//    MARK: Fragile
    
    @IBAction func fragileSwitchTapped(_ sender: SevenSwitch) {
        if fragileSwitch.isOn()  {
            fragileStatus = true
        } else {
            fragileStatus = false
        }
    
    }
 
    
    
//    MARK:  Qty
    
    @IBOutlet weak var stepper: UIStepper!
    
    @IBAction func qty_textField_action(_ sender: AnyObject) {
        self.resignFirstResponder()
    }
    
    @IBAction func stepperAction(_ sender: AnyObject) {
        qtyValue = (Int(stepper.value))
        itemQty.text = "\(qtyValue!)"
    }
    
    var qtyValue:Int! {
        didSet {
            if qtyValue != nil {
                self.stepper.value = Double(qtyValue!)
            } else {
                self.stepper.value = 1
            }

        }
    }
    
    @IBAction func textEditingEnded(_ sender: AnyObject) {
        self.qtyValue = Int(itemQty.text!)
    }
    
    
    
//    MARK: Image/Camera
    
   func pickImage() {
        
        //ActionSheet to ask user to scan or choose
        let alertController = UIAlertController(title: "Choose Image for item", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let camera = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction) in
            print("Open the camera ")
            self.shootPhoto()
        })
        
        
        alertController.addAction(camera)
        
        let photoAlbum = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction) in
            print("pick from photos")
            self.photoFromLibrary()
        })
        
        alertController.addAction(photoAlbum)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert :UIAlertAction) in
            print("Cancel button tapped")
        })
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    let picker = UIImagePickerController()
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var blurredImage: UIImageView!
    
    func photoFromLibrary() {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .popover
        present(picker, animated: true, completion: nil)
        //        picker.popoverPresentationController?.barButtonItem = sender
    }
    
    func shootPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        } else {
            noCamera()
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    //MARK: - Image  Delegates
    
    private func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        myImageView.contentMode = .scaleAspectFill //3
        myImageView.image = chosenImage //4
        blurredImage.image = chosenImage //4
        imageChanged = .newImage
        dismiss(animated:true, completion: nil) //5
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //    MARK: Keyboard Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    


func changeFontStyle(labelName: UILabel, isPlaceholder:Bool)  {
    enum fontChangeStyle{
        case noImage  //keep placeholder
        case existingImage   //don't change anything
        case newImage   //upload new image and write URL to Firebase
    }
    
//    switch <#value#> {
//    case <#pattern#>:
//        <#code#>
//    default:
//        <#code#>
//    }
    if isPlaceholder {
        labelName.textColor = UIColor.lightGray
        
    } else {
        labelName.textColor = UIColor.darkGray
        
    }
    
    
}


    func createNumPadToolbar(){
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ItemDetailsVC.doneButtonAction))
        
        //array of BarButtonItems
        var arr = [UIBarButtonItem]()
        arr.append(flexSpace)
        arr.append(doneBtn)
        toolbar.setItems(arr, animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        self.itemQty.inputAccessoryView = toolbar
     }
    
    func doneButtonAction(){
//        Part of custom number pad keyboard 
        self.view.endEditing(true)
    
    }
    
     func loadPassedItem()  {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let ref =  self.REF_ITEMS.child(self.item.itemKey)
        ref.observe(.value, with: { snapshot in
                if let childSnapshotDict = snapshot.value as? Dictionary<String, AnyObject> {
                       let item = Item(itemKey: self.item.itemKey, dictionary: childSnapshotDict)
                    
                    item.itemIsBoxed = true
                    item.itemBoxNum = String(self.itemsBox.boxNumber)
                    
                    self.item = item
                    self.downloadImageFromFirebase()
                    self.title = self.item.itemName
                    print("item: \(self.item.itemKey)")
                    self.updateViewWithItem()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
        })
    }


    func downloadImageFromFirebase(){

        if let itemImageURL = self.item.itemImgUrl {
            
        
                let ref = FIRStorage.storage().reference(forURL: itemImageURL)
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("MK: Unable to download image from Firebase storage")
                    } else {
                        print("MK: Image downloaded from Firebase storage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.myImageView.image = img
                                self.blurredImage.image = img
                                self.imageChanged = .existingImage
                            }
                        }
                    }
                })
            }
    }
    
   
    func updateViewWithItem() {
        print("In the UPATE VIEW   ")
        configureExpandingMenuButton()

        
         if let item = self.item {

            self.title = item.itemName

            itemNameField.text = item.itemName
            
            if let category = item.itemCategory, let subcat = item.itemSubcategory {
                 itemCategory.text = category
                    itemSubCategory.text = subcat
            } else {
                  self.itemCategory.text = "Not Set"
                self.itemSubCategory.text = "Not Set"

                changeFontStyle(labelName: itemSubCategory, isPlaceholder: true)

                changeFontStyle(labelName: itemCategory, isPlaceholder: true)
            }
            
            if let color = item.itemColor {
                itemColor.text = color 

            } else {
                itemColor.text = "Not Set"
                changeFontStyle(labelName: itemColor, isPlaceholder: true)

            }
            
            if let qty = item.itemQty {
                itemQty.text = "\(qty)"
            } else {
                itemQty.text = "?"
            }
            
             fragileStatus = item.itemFragile
                if fragileStatus == true {
                fragileSwitch.setOn(true, animated: true)
                
                 } else {
                    fragileSwitch.setOn(false, animated: true)
                }
            }
        }
   
    
    func loadItemBoxDetailsFromFireBase() {
         let ref = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/boxes/\(self.itemsBox.boxKey)")

        ref.observeSingleEvent(of: FIRDataEventType.value, with: { (itemBoxDetailsSnap) in
        
            
        if let itemBoxDetailsDict = itemBoxDetailsSnap.value as? Dictionary<String, AnyObject> {
            let key = itemBoxDetailsSnap.key
 
//             Do  Box and Item Objects agree on Box Key
            if let itemBoxKey = self.item.itemBoxKey, itemBoxKey == key {
                
                let boxFromFireBase = Box(boxKey: key, dictionary: itemBoxDetailsDict)
                self.itemsBox = boxFromFireBase
                self.updateBoxDetailsView()

            } else {
                
                print("ALERT: ITEM and BOX  have BoxKey Mismatch ")
                self.boxNumberHeaderLabel.text = "BOX NUMBER DOES NOT MATCH"

                    }
            
                }
            }) { (error) in
                print("Firebase error getting iTemDetails:BoxInfo")
                print(error.localizedDescription)
            }
      }
    
 
        func updateBoxDetailsView()  {
             if let boxNumer = self.itemsBox.boxNumber  {
                 boxNumberHeaderLabel.text = "BOX NUMBER \(boxNumer)"
            }
            
            if let location = self.itemsBox.boxLocationName {
                print("Box Location is:  \(location) ")
                  self.boxDetails.text = location
            }
            
            if let locdetails = self.itemsBox.boxLocationDetail {
                print("Box Location locdetails are:  \(locdetails) ")

            }
    }
    
    
    

    @IBAction func saveItemTapped(_ sender: UIBarButtonItem) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
print("Save Item Tapped ")
        checkForEmptyFields()
        
    }
    
    func checkForEmptyFields() {
        print("checkForEmptyFields ")

        let _ = EZLoadingActivity.show("Saving", disableUI: true)

        guard  itemNameField.text != "" else {
            let errMsg = "Item name is Required "
            newItemErrorAlert("Ut oh...", message: errMsg)
            return
        }
        
            self.checkForImage()
        
    }
    
    
    
    func checkForImage() {
        print("MK:checkForImage")

        if let imgData = UIImageJPEGRepresentation(myImageView.image!, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            
            
            DataService.ds.REF_ITEM_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("MK: Unable to upload image to Firebasee storage")
  
                } else {
                    
                    var url: String!
                    
                    switch self.imageChanged {
                        
                    case .existingImage:
                        url = self.item.itemImgUrl

                    case .newImage:
                        url = metadata?.downloadURL()?.absoluteString
                    
                    case .noImage:
                        url = nil
                        print(" noImage")
                    }
                    
                    print("The URL we have to send is \(url) ")
                        self.updateFirebaseData(imgUrl: url)
                           
                    
                }
            }
        }
    }
    
    
    
    func updateFirebaseData(imgUrl: String?) {
        print("updateFirebaseData ")

        var qtyStr: String
        
                if let qty = qtyValue {
                    qtyStr = "\(qty)"
                } else {
                    qtyStr = "1"
                }
        
        
        var itemKey: String
        
        let ref = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items")
        // Generate a new push ID for the new post
    
        switch itemType {
        case .new:
            print("updateFBdata: itemType is New ")
            let newItemRef = ref.childByAutoId()
            itemKey = newItemRef.key
        case .existing:
            print("updateFBdata: itemType is existing  \(self.item.itemKey)")
            itemKey = self.item.itemKey
        default:
            print("updateFBdata: itemType is Default ")
            let newItemRef = ref.childByAutoId()
            itemKey = newItemRef.key
        }
        
        
         var itemDict: Dictionary<String, AnyObject> = [
            "itemName" :  itemNameField.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "itemCategory" : self.item.itemCategory  as AnyObject,
            "itemSubcategory" : self.item.itemSubcategory as AnyObject,
            "itemQty" : qtyStr as AnyObject, //"\(qtyValue)" as AnyObject ,
            "itemFragile" : fragileStatus as AnyObject,
            "itemColor": self.item.itemColor as AnyObject         ]
 	
    
//        MARK:  Write Box Details to ITEM MODEL
//        MARK: get box details from Item Model and add to Dictionary 
         if let Tempitem = self.item {
 
            itemDict["box/itemIsBoxed"] = Tempitem.itemIsBoxed as AnyObject
                
              
            
            if let boxNumber = Tempitem.itemBoxNum{
                itemDict["box/itemBoxNumber"] = String(boxNumber) as AnyObject

            }else {

                itemDict["box/itemBoxNumber"] = nil
            }
            
            
            
            if let boxKey = Tempitem.itemBoxKey{
                itemDict["box/itemBoxKey"] = boxKey as AnyObject
                
            }else {
                itemDict["box/itemBoxKey"] = nil
        }
        
         } else {
            
            print("ItemDetails: updateFirebaseData:   SELF ITEM WAS NOT CREATED ? ? ?  ")
        }
        
        
        
        
      //        MARK: Create Dictionary for Box Model

        func addTonewBoxDict() -> Dictionary<String, AnyObject> {
              return ["itemBoxKey": self.item.itemBoxKey as AnyObject , "itemName": self.item.itemName as AnyObject, "itemKey" : self.item.itemKey as AnyObject]
            }
        
        
        
        
        switch boxChangeType {
        case .add:
            let box = Box(boxKey: self.item.itemBoxKey!)
            box.addItemDetailsToBox(itemDict: addTonewBoxDict() )

        case .remove:
            self.itemsBox.removeItemDetailsFromBox(itemKey: self.item.itemKey)
            self.item.removeBoxDetailsFromItem()
        
        case .update:
            self.itemsBox.removeItemDetailsFromBox(itemKey: self.item.itemKey)
            self.itemsBox.addItemDetailsToBox(itemDict: addTonewBoxDict() )

        case .none:
            print("")
        }
        
        
        item.saveItemToFirebase(itemKey: itemKey, itemDict: itemDict, completion: { () -> Void in
            
            
            print("save item to FB and then POP ")
            popViewController()

        })
 
 
    } //end updateFirebaseData
    
 
    
    func popViewController(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let _ = EZLoadingActivity.hide(success: true, animated: true)

        _ = navigationController?.popViewController(animated: true)

    }
    
  
    
    
    func newItemErrorAlert(_ title: String, message: String) {
        
        // Called upon Save   to let the user know Update to FB didn't work.
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
  }
    
    
    // MARK: - UNWIND Navigation
 
    @IBAction func unwind_CancelToItemDetails(_ segue:UIStoryboardSegue) {

    }
    
    @IBAction func unwind_saveCategoryToItemDetails(_ segue:UIStoryboardSegue) {
        if let categoryDetails = segue.source as? CategoryDetailsVC {
            
            
            if let categorySelections = categoryDetails.category {
            
                if let category = categorySelections.category {
                    changeFontStyle(labelName: itemCategory, isPlaceholder: true)

                self.item.itemCategory = category
                self.itemCategory.text = category
                
                }
            
            
                if let subcat = categorySelections.subcategory {
                    changeFontStyle(labelName: itemSubCategory, isPlaceholder: true)

                    self.item.itemSubcategory = subcat
                    self.itemSubCategory.text = subcat
                } else {
                    
                    self.itemSubCategory.text = ""
                    self.subcategoryHeading.isHidden = true
                }
             
            }
            //            Make Save Button BOLD!
            self.updateSaveButton()
        }
    }
    
    
    @IBAction func unwind_saveColorToItemDetails(_ segue:UIStoryboardSegue) {
        if let colorVC = segue.source as? ColorTableVC {

             if let colorObject = colorVC.selectedColor,  let color = colorObject.colorName {
                self.item.itemColor = color
                self.itemColor.text = color.capitalized
                changeFontStyle(labelName: itemColor, isPlaceholder: true)

//                IDEA: should i write this to item Model too ?

                    self.updateSaveButton()

            }
        }
    }
    
 
    fileprivate func configureExpandingMenuButton() {
        var boxSymbol: String!
        var editBoxAlertTitle: String
        var editBoxAlertSub: String
        var editBoxColor : UInt
        
        if self.item.itemIsBoxed == true  {
            
            
              boxSymbol = "boxRemoveBlue"
            editBoxAlertTitle = "Change Box"
            editBoxAlertSub = "Select An Option Below"
            editBoxColor =  0xFFD110

        } else {
            
             
            boxSymbol = "boxAddBlue"
            editBoxAlertTitle = "Select Box"
            editBoxAlertSub = "How would you like to select a Box?"
            editBoxColor =  0x00A1FF 

        }
        
     
        
    
        
        DispatchQueue.main.async {
            print("main thread dispatch")
        
         let menuButtonSize: CGSize = CGSize(width: 32.0, height: 32.0)

        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), centerImage: UIImage(named: "menuBlue")!, centerHighlightedImage: UIImage(named: "menuBlue")!)
        menuButton.center = CGPoint(x: 30.0, y:  180.0)
        self.view.addSubview(menuButton)
        
        func showAlert(_ title: String) {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
//            Edit Items QR String
        let item1 = ExpandingMenuItem(size: menuButtonSize, title: nil, image: UIImage(named: "qrBlue")!, highlightedImage: UIImage(named: "qrBlue")!, backgroundImage: UIImage(named: "qrBlue"), backgroundHighlightedImage: UIImage(named: "qrBlue")) { () -> Void in
            
            }
        
//            Add/Edit Photo
        let item2 = ExpandingMenuItem(size: menuButtonSize, title: nil, image: UIImage(named: "cameraBlue")!, highlightedImage: UIImage(named: "cameraBlue")!, backgroundImage: UIImage(named: "cameraBlue"), backgroundHighlightedImage: UIImage(named: "cameraBlue")) { () -> Void in
//            showAlert("image")
                self.pickImage()

        }
        
//            Add/Remove iTem to Box
        let item3 = ExpandingMenuItem(size: menuButtonSize, title: nil, image: UIImage(named: boxSymbol)!, highlightedImage: UIImage(named: boxSymbol)!, backgroundImage: UIImage(named: boxSymbol), backgroundHighlightedImage: UIImage(named: boxSymbol)) { () -> Void in
//            showAlert("box")
            self.showBoxChangeAlertView(title: editBoxAlertTitle, subtitle: editBoxAlertSub, color: editBoxColor)
        }
        
        menuButton.addMenuItems([item1, item2, item3]) //
        
                 menuButton.willPresentMenuItems = { (menu) -> Void in
//                    print("did willPresentMenuItems menu")
            }
          
                menuButton.didDismissMenuItems = { (menu) -> Void in
//                    print("did dismiss menu")
            }
        }
    }
    
    
    func showBoxChangeAlertView(title: String, subtitle: String, color: UInt)  {
        
        let icon = UIImage(named:"boxSearch")
        let alert = SCLAlertView()
        _ = alert.addButton("Scan QR") {
            
        }
        
        _ = alert.addButton("View List") {
            self.performSegue(withIdentifier: "showBoxList", sender: self)

        }
 
        if self.item.itemIsBoxed == true {
            
            _ = alert.addButton("Remove Item From Box", backgroundColor: UIColor.red, textColor: UIColor.white) {
                
//                 Change the save button to indicate changes have been made and not saved
                
//                set Enum for box
                self.boxChangeType = .remove
                
                
                
                self.boxDetailsTableCell.isHidden = true
                self.boxDetailsTableCell.isUserInteractionEnabled = false
                self.boxNumberHeaderLabel.text = nil
                self.boxDetails.text = nil
           
                
                
//                 let oldBoxKey =  self.item.itemBoxKey - dont need,this is in box object
                self.item.itemBoxKey = nil
                self.item.itemBoxNum = nil
                self.item.itemIsBoxed = false
                
                
                
             }
        } else {
        print("ALERT: Item was never boxed- you cannot remove it  ")
        }
        

        
        
        DispatchQueue.main.async {
            _ = alert.showItemAssignBox(title, subTitle: subtitle, closeButtonTitle: "Cancel", icon: icon!, colorStyle: color )
        }
        
    }
  
    
    
    @IBAction func unwindToItemsFromQR_editingQR(_ segue:UIStoryboardSegue) {
        if let qrScannerViewController = segue.source as? qrScannerVC {
            if let scannedString =  qrScannerViewController.qrData {
                print("Scanned STring: \(scannedString)")
            }
        }
    }
    
 
    
    //    MARK: Unwind Box Select
    @IBAction func unwindToItemDetailsFromListBoxSel(_ segue:UIStoryboardSegue) {
        
        if let boxFeedViewController = segue.source as? BoxFeedVC {
   
            if let selectedBox = boxFeedViewController.boxToPass {
                
                
//                Add it to the Item Object
                self.item.itemIsBoxed = true
                self.item.itemBoxNum = String(selectedBox.boxNumber)
                self.item.itemBoxKey = selectedBox.boxKey
             
                self.updateSaveButton()
            }
        }
 
    }
 
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("prepareForSegue ")
        
        if let colorVC = segue.destination as? ColorTableVC {
            colorVC.colorLoadsFrom = .item
        }
      
        
        if segue.identifier == "showBoxList" {
            print("identifier ==  showBoxList ")
            
            if itemType != .new {
                if let destination = segue.destination as? BoxFeedVC {
                    destination.boxLoadType = .itemDetails_matchCategory
                    destination.itemPassed = self.item
                    
                    }
            } else {
                newItemErrorAlert("Item Not Saved", message: "Save new item before adding to Box.")

            }
            
            }
        }
    
    

}

