//
//  ViewController.swift
//
//
//  Created by Aaqib Hussain on 03/08/2015.
//  Copyright (c) 2015 Kode Snippets. All rights reserved.
//

import UIKit

class BoxDetailsMaster: UIViewController {
   
    var box: Box!
    
    var container: ContainerViewController!
    
    @IBOutlet var sendTextField: UITextField!
    
    var modelController: ModelController!
    
    @IBOutlet weak var segmentedControl: TabySegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        segmentedControl.initUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func segmentControl(_ sender: TabySegmentedControl) {
        

        if sender.selectedSegmentIndex == 0{

          
            container!.segueIdentifierReceivedFromParent("Summary")
            
        }
        else{
            
        container!.segueIdentifierReceivedFromParent("Edit")
        
        }
    
    }
   
    @IBAction func getText(_ sender: UIButton) {
        
        
        if let getFirstVCObject = self.container.currentViewController as? FirstViewController{
        let getText = getFirstVCObject.firstVCTextfield.text!
        print(getText)
        }
        
    }
    
    
    @IBAction func sendData(_ sender: Any) {
        
        if container.currentViewController.isKind(of:BoxDetails_EditVC.self){
        
        if let getEditBoxVCObject = self.container.currentViewController as? BoxDetails_EditVC
        {
            let boxNumberInBoxIcon = "22"
//            let getText = self.sendTextField.text
            getEditBoxVCObject.boxNumberInBoxIcon.text = boxNumberInBoxIcon
        
        
        }
        }
        else if container.currentViewController.isKind(of: BoxDetails_SummaryVC.self){
        
            if let getSummaryVCObject = self.container.currentViewController as? BoxDetails_SummaryVC
            {
                let getText = "Boxes Are Great"
                
//                getSummaryVCObject.box =  self.box // = getText!
                getSummaryVCObject.passedText = getText
                
                
            }
        
        
        
        
        }
        
    }

 
 


    @IBAction func doneButton(_ sender: Any) {
        print("done button pressed")
        _ = navigationController?.popViewController(animated: true)

    }
    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "container"{

        container = segue.destination as! ContainerViewController
      
        
        }
    }



}

