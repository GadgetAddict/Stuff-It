//
//  PlayingAroundViewController.swift
//  Inventory17
//
//  Created by Michael King on 4/7/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit



let kSuccessTitle = "Congratulations"
let kErrorTitle = "Connection error"
let kNoticeTitle = "Notice"
let kWarningTitle = "Warning"
let kInfoTitle = "Info"
let kSubtitle = "This cannot be undone."

let kDefaultAnimationDuration = 2.0


class PlayingAroundViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView:UITableView?
    var hidden:[Bool] = [true, true]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hidden[section] {
            return 0
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        cell.textLabel?.text = "A row!"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
}

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "I'm a test label"
        label.tag = section
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PlayingAroundViewController.tapFunction))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        
        return label
}

    func tapFunction(sender:UITapGestureRecognizer) {
        let section = sender.view!.tag
        let indexPaths = (0..<3).map { i in return IndexPath(item: i, section: section)  }
        
        hidden[section] = !hidden[section]
        
        tableView?.beginUpdates()
        if hidden[section] {
            tableView?.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView?.insertRows(at: indexPaths, with: .fade)
        }
        tableView?.endUpdates()
}






}

    /*
            @IBOutlet weak var label: UILabel!
            
            var counter = 0
            
            override func viewDidLoad() {
                super.viewDidLoad()
                // Do any additional setup after loading the view, typically from a nib.
                
                let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: Selector("animate"), userInfo: nil, repeats: true)
                timer.fire()
            }
            
    
            
            func animate() {
                UIView.transition(with: label,
                                          duration: 1.0,
                                          options: [.curveEaseInOut],
                                          animations: { () -> Void in
                                            self.counter += 1
                                            self.label.text = "\(self.counter)"
                }, completion: nil)
                
            }
    }

//            getColor()
            // Do any additional setup after loading the view, typically from a nib.


        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        @IBAction func showSuccess(_ sender: AnyObject) {
            let alert = SCLAlertView()
            _ = alert.addButton("First Button", target:self, selector:#selector(PlayingAroundViewController.firstButton))
            _ = alert.addButton("Second Button") {
                print("Second button tapped")
            }
            _ = alert.showSuccess(kSuccessTitle, subTitle: kSubtitle)
        }
        
        @IBAction func showError(_ sender: AnyObject) {
            _ = SCLAlertView().showError("Hold On...", subTitle:"You have not saved your Submission yet. Please save the Submission before accessing the Responses list. Blah de blah de blah, blah. Blah de blah de blah, blah.Blah de blah de blah, blah.Blah de blah de blah, blah.Blah de blah de blah, blah.Blah de blah de blah, blah.", closeButtonTitle:"OK")
            //        SCLAlertView().showError(self, title: kErrorTitle, subTitle: kSubtitle)
        }
        
        @IBAction func showNotice(_ sender: AnyObject) {
            let appearance = SCLAlertView.SCLAppearance(dynamicAnimatorActive: true)
            _ = SCLAlertView(appearance: appearance).showNotice(kNoticeTitle, subTitle: kSubtitle)
        }
        
        @IBAction func showWarning(_ sender: AnyObject) {
            _ = SCLAlertView().showWarning(kWarningTitle, subTitle: kSubtitle)
        }
    
    @IBAction func showWait( _sender: AnyObject) {
         _ = SCLAlertView().showWait("WAIT", subTitle: "Hold On")
        
    }
    
 
        
        @IBAction func showEdit(_ sender: AnyObject) {
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: true)
            let alert = SCLAlertView(appearance: appearance)
            let txt = alert.addTextField("Enter your name")
            _ = alert.addButton("Show Name") {
                print("Text value: \(String(describing: txt.text))")
            }
            _ = alert.showEdit(kInfoTitle, subTitle:kSubtitle)
        }
        
        
        @IBAction func showCustomSubview(_ sender: AnyObject) {
            // Create custom Appearance Configuration
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: false,
                dynamicAnimatorActive: true
            )
            
            // Initialize SCLAlertView using custom Appearance
            let alert = SCLAlertView(appearance: appearance)
            
            // Creat the subview
            let subview = UIView(frame: CGRect(x: 0,y: 0,width: 216,height: 70))
            let x = (subview.frame.width - 180) / 2
            
            // Add textfield 1
            let textfield1 = UITextField(frame: CGRect(x: x,y: 10,width: 180,height: 25))
            textfield1.layer.borderColor = UIColor.green.cgColor
            textfield1.layer.borderWidth = 1.5
            textfield1.layer.cornerRadius = 5
            textfield1.placeholder = "Username"
            textfield1.textAlignment = NSTextAlignment.center
            subview.addSubview(textfield1)
            
            // Add textfield 2
            let textfield2 = UITextField(frame: CGRect(x: x,y: textfield1.frame.maxY + 10,width: 180,height: 25))
            textfield2.isSecureTextEntry = true
            textfield2.layer.borderColor = UIColor.blue.cgColor
            textfield2.layer.borderWidth = 1.5
            textfield2.layer.cornerRadius = 5
            textfield1.layer.borderColor = UIColor.blue.cgColor
            textfield2.placeholder = "Password"
            textfield2.textAlignment = NSTextAlignment.center
            subview.addSubview(textfield2)
            
            // Add the subview to the alert's UI property
            alert.customSubview = subview
            _ = alert.addButton("Login") {
                print("Logged in")
            }
            
            // Add Button with Duration Status and custom Colors
            _ = alert.addButton("Duration Button", backgroundColor: UIColor.brown, textColor: UIColor.yellow, showDurationStatus: true) {
                print("Duration Button tapped")
            }
            
            _ = alert.showInfo("Login", subTitle: "", duration: 10)
        }
        
        @IBAction func showCustomAlert(_ sender: AnyObject) {
            
          let alert = SCLAlertView()
            _ = alert.addButton("First Button", target:self, selector:#selector(PlayingAroundViewController.firstButton))
            _ = alert.addButton("Second Button") {
               self.firstButton()
            }
 
            let icon = UIImage(named:"boxSearch")
        let color = UIColor.orange
//            
          _ = alert.showCustom("Custom Color", subTitle: "Custom color", color: color, icon:icon!)

    
    
            
            _ = alert.showTitle("title", subTitle: "subtitle", style: .edit, closeButtonTitle: "Close", duration: .infinity, animationStyle: .bottomToTop)
            //        _ = alert.showCustom("Custom Color", subTitle: "Custom color", color: color, icon: icon!)
            let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                alert.hideView()
            }
    
    }
        
        func firstButton() {
            print("First button tapped")
        }
    
    func getColor() {
        
    let swiftColor = UIColor(red: 0, green: 161/255, blue: 255/255, alpha: 1)
    if let rgb = swiftColor.rgb() {
        print(rgb)
    } else {
    print("conversion failed")
    }
    }
}
    extension UIColor {
        
        func rgb() -> Int? {
            var fRed : CGFloat = 0
            var fGreen : CGFloat = 0
            var fBlue : CGFloat = 0
            var fAlpha: CGFloat = 0
            if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
                let iRed = Int(fRed * 255.0)
                let iGreen = Int(fGreen * 255.0)
                let iBlue = Int(fBlue * 255.0)
                let iAlpha = Int(fAlpha * 255.0)
                
                //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
                let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
                return rgb
            } else {
                // Could not extract RGBA components:
                return nil
            }
        }
    }

 */
