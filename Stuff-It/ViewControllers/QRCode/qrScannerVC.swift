//
//  qrScannerVC.swift
//  Inventory17
//
//  Created by Michael King on 3/10/17.
//  Copyright © 2017 Microideas. All rights reserved.
//



import UIKit
import BarcodeScanner

protocol QrDelegate {
     func useReturnedFBKey<inventoryObject>(object: inventoryObject, completion: (Bool) -> ()) 

    
}

class qrScannerVC: UIViewController, SegueHandlerType  {
    
    
    var delegate: QrDelegate?
    var segueID: SegueIdentifier!
    
    enum SegueIdentifier: String {
        case unwind_ItemFeed
        case unwind_ItemDetails
        case unwind_BoxDetails

        case BoxDetails
        case ItemDetails
    }
    
    
    var qrData = QR()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.setTitle("Scan", for: UIControlState())
        button.addTarget(self, action: #selector(startScanner), for: .touchUpInside)
        
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
       
        if self.qrData.qrScanType == .OpenSearch {
            print("qrScanner: ViewDidAppear - .OpenSearch")
            view.addSubview(button)
            
        } else {
            print("qrScanner: ViewDidAppear - Start Scanning")

            startScanner()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BarcodeScanner.Title.text = NSLocalizedString("Scan QR Code", comment: "")
        BarcodeScanner.Info.text = NSLocalizedString(
            "Place the QR Code within the window to scan. The search will start automatically.", comment: "")
        BarcodeScanner.Info.loadingText = NSLocalizedString("Searching for matching items...", comment: "")
        BarcodeScanner.Info.notFoundText = NSLocalizedString("No objects                                                                                            found.", comment: "")
        
        
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        button.frame.size = CGSize(width: 250, height: 80)
        button.center = view.center
    }
    
    func startScanner() {
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        present(controller, animated: true, completion: {
            self.button.removeFromSuperview()
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("qrScanVC= prepareForSeg")

        switch segueIdentifierForSegue(segue: segue) {
            
        case .ItemDetails:
            print(" prepareForSeg ItemDetails")

            if let destination = segue.destination as? ItemDetailsVC {
                destination.itemKeyPassed = qrData.item?.itemKey
                print(" destination.itemKeyPassed \(String(describing: qrData.item?.itemKey))")

                destination.itemType = .existing
            }
            
        case .BoxDetails:
            print(" prepareForSeg BoxDetails")

            if let destination = segue.destination as? BoxDetails {
               destination.box = qrData.box
                destination.boxSegueType = .qr
                
            }
            
        default:
            break
        }
    }
    
    
    var curPage = "QRScanner"
    
  
}

extension qrScannerVC: BarcodeScannerErrorDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
}

extension qrScannerVC: BarcodeScannerDismissalDelegate {
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


extension qrScannerVC: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        print(code)
        print(type)
        
        
        
        let delayTime = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            
            
            self.qrData.getDataFromFirebase(scannedString: code,  callback: {()-> Void in
                //stuff here happens after fb is finished
                print("7 got type \(self.qrData.objectTypeReturned)  ")
                print("8 got key \(String(describing: self.qrData.objectKeyReturned))  ")
                let intentions = self.qrData.qrScanType
                  print("finished FB- scanType is \(intentions)")
             })
            
            
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                
        print("in the asyncAfterDeadline \(String(describing:self.qrData.objectTypeReturned)))")

                print("in the asyncAfterDeadline \(String(describing: self.qrData.item?.itemKey))")
 
                
                switch self.qrData.qrScanType {
                    
                case .OpenSearch:
                    print("OpenSearch")

                    switch self.qrData.objectTypeReturned {
                    case .item:
                             self.performSegueWithIdentifier(segueIdentifier: .ItemDetails, sender: self)
//                             self.tabBarController?.selectedIndex = 0

                    case .box:
                            self.performSegueWithIdentifier(segueIdentifier: .BoxDetails, sender: self)
                            self.tabBarController?.selectedIndex = 1

                    case .none:
                        self.showQRAlertView(errorType: .noResults)
                        break
                    }
                    
                case .ItemDetailsBoxSelect:
                    print("ItemDetailsBoxSelect")
                    
                    switch self.qrData.objectTypeReturned {
                    case .item:
                        self.showQRAlertView(errorType: .objIsItemMstBeBox)
                    case .box:
                        self.delegate?.useReturnedFBKey(object: self.qrData.box) { success in
                        self.performSegueWithIdentifier(segueIdentifier: .unwind_ItemDetails, sender: self)
                        self.tabBarController?.selectedIndex = 0
                        }
                    case .none:
                        self.showQRAlertView(errorType: .noResults)
                        break
                    }
                case .ItemFeedBoxSelect:
                    print("Scan Type is  ItemFeedBoxSelect")
                    
                    switch self.qrData.objectTypeReturned {
                    case .item:
                        print("objType was item, s/b box")
                        
                        self.showQRAlertView(errorType: .objIsItemMstBeBox)
                    case .box:
                        print("objType is box")
                        self.delegate?.useReturnedFBKey(object: self.qrData.box) { success in
                        self.performSegueWithIdentifier(segueIdentifier: .unwind_ItemFeed, sender: self)
                        self.tabBarController?.selectedIndex = 0
                        }
                     case .none:
                        print("objType noResults")
                        self.showQRAlertView(errorType: .noResults)
                    }
            
                case .ItemDetailsQrAssign:
                    print("Scan Type is  ItemDetailsQrAssign")

                    switch self.qrData.objectTypeReturned {
                    case .item:
                        print("objType is item this QR is taken")
                        self.showQRAlertView(errorType: .qrTaken)

                    case .box:
                        print("objType is box")
                        self.showQRAlertView(errorType: .qrTaken)

                    case .none:
                        print("objType noResults")
//                        goood we can use it
                        self.delegate?.useReturnedFBKey(object: self.qrData.scannedString){ success in
                        self.performSegueWithIdentifier(segueIdentifier: .unwind_ItemDetails, sender: self)
                        self.tabBarController?.selectedIndex = 0
                    }
                     }

                case .BoxDetailsQrAssign:
                    
                    switch self.qrData.objectTypeReturned {
                    case .item:
                        print("objType is item this QR is taken")
                        self.showQRAlertView(errorType: .qrTaken)
                        
                    case .box:
                        print("objType is box")
                        self.showQRAlertView(errorType: .qrTaken)
                        
                    case .none:
                        print("objType noResults")
                        //                        goood we can use it
                        self.delegate?.useReturnedFBKey(object: self.qrData.scannedString) { success in
                        self.performSegueWithIdentifier(segueIdentifier: .unwind_BoxDetails, sender: self)
                        self.tabBarController?.selectedIndex = 1
                        }
                    }
                }
               
                    controller.dismiss(animated: true, completion: nil)
                
                
                }
            }
            
        }
    
    
   
}

extension qrScannerVC {
   
}



extension qrScannerVC {
    
    //    MARK: SCLAlertView
    func showQRAlertView(errorType: MessageType)  {
        print("showQRAlertView")
        
        //        ALERT: Finish implementing enums for error messages
        
        let title = "Ut Oh!"
        
//        let title = "Unable To Locate"
//        let subtitle = "Items or Boxes with this QR code does not exist.\nCreate something new using this QR Code?"
        
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
            
            _ = alert.showQRerror(title, subTitle: errorType.description)
            
        }
        
    }
    
}

//backup
/*
func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
    print(code)
    print(type)
    
    var tabIndex: Int!
    var succesful: Bool = false
    
    let delayTime = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
        
        
        self.qrData.getDataFromFirebase(scannedString: code,  callback: {(qrObject)-> Void in
            //stuff here happens after fb is finished
            print("7 got type \(qrObject.objectTypeReturned)  ")
            print("8 got key \(String(describing: qrObject.objectKeyReturned))  ")
            let intentions = self.qrData.qrScanType
            let objType = qrObject.objectTypeReturned
            print("finished FB- scanType is \(intentions)")
        })
        
        
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            print("in the asyncAfterDeadline")
            
            switch self.qrData.qrScanType {
            case .OpenSearch:
                print("OpenSearch")
                
                switch self.qrData.objectTypeReturned {
                case .item:
                    self.segueID = .ItemDetails
                    succesful = true
                    tabIndex = 0
                //                        in prepare for segue, pass itemDetails the item Key
                case .box:
                    self.segueID = .BoxDetails
                    tabIndex = 1
                //                        in prepare for segue, pass itemDetails the item Key
                case .none:
                    self.showQRAlertView(errorType: .noResults)
                    return
                }
            case .ItemDetailsBoxSelect:
                print("ItemDetailsBoxSelect")
                
                //                     if returned Key is a box, assign item to box, unwind to iTemDetails
                tabIndex = 0
                self.segueID = .unwind_ItemDetails
                print("segue to itemDetails")
                //                    if returned object is box, save item to box,
            //                    else error message  (not box: error try again, not found at all: create new empty box or change QR code to this box ?
            case .ItemFeedBoxSelect:
                print("Scan Type is  ItemFeedBoxSelect")
                
                switch self.qrData.objectTypeReturned {
                case .item:
                    print("objType was item, s/b box")
                    
                    self.showQRAlertView(errorType: .objIsItemMstBeBox)
                case .box:
                    print("objType is box")
                    succesful = true
                case .none:
                    self.showQRAlertView(errorType: .noResults)
                }
                tabIndex = 0
                self.segueID = .unwind_ItemFeed
            case .ItemDetailsQrAssign:
                tabIndex = 0
                self.segueID = .unwind_ItemDetails
                print("segue to itemDetails")
            case .BoxDetailsQrAssign:
                tabIndex = 1
                self.segueID = .BoxDetails
                print("segue to BoxDetails")
            }
            if succesful {
                print("in the asyncAfterDeadline")
                self.delegate?.useReturnedFBKey(key: code)
                
                
                controller.dismiss(animated: true, completion: nil)
                self.tabBarController?.selectedIndex = tabIndex
                self.performSegueWithIdentifier(segueIdentifier: self.segueID, sender: self)
                
            } else {
                print("else scan failed ")
                
                controller.resetWithError(message: "")
                
            }
        }
        
    }
}
*/
//enum qrScanTypes {
//    case ItemSearch
//    case BoxSearch
//    case ItemDetailsBoxSelect
//    case ItemFeedBoxSelect
//    case ItemDetailsQrAssign
//    case BoxDetailsQrAssign
//    case Error
//}
