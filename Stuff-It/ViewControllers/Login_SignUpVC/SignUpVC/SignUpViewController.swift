//
//  SignUpViewController.swift
//  ClientColorKeeper
//
//  Created by Michael King on 11/13/16.
//  Copyright © 2016 Microideas. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    var user: User!
    let usersRef = FIRDatabase.database().reference(withPath: "users")

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordField2: UITextField!
    @IBOutlet weak var nickNameField: UITextField!

    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let font = UIFont(name: "HelveticaNeue-Thin", size: 19)!
            let attributes = [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName : font]

            self.firstNameField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes:attributes)

            self.emailField.attributedPlaceholder = NSAttributedString(string:"Email Address", attributes:attributes)

            self.passwordField.attributedPlaceholder = NSAttributedString(string:"Choose Password", attributes:attributes)

            self.passwordField2.attributedPlaceholder = NSAttributedString(string:"Re-Enter Password", attributes:attributes)
            
            self.nickNameField.attributedPlaceholder = NSAttributedString(string:"Inventory Nickname  ie: Home", attributes:attributes)
            
            
            // Do any additional setup after loading the view.
        }
        
    
    
        func checkForEmptyFields() {
            
            guard  firstNameField.text != "" else {
                let errMsg = "First name is Required "
                signupErrorAlert(title: "Registration Incomplete", message: errMsg)
                return
            }
            
            guard emailField.text != "" else {
                let errMsg = "Email Address Required"
                signupErrorAlert(title: "Registration Incomplete", message: errMsg)
                return
            }
            
            guard passwordField.text  != "" else {
                let errMsg = "Password is Required"
                signupErrorAlert(title: "Registration Incomplete", message: errMsg)
                return
            }
            
            guard passwordField2.text  == passwordField.text else {
                let errMsg = "Both Passwords must match."
                signupErrorAlert(title: "Registration Incomplete", message: errMsg)
                return
            }
            
            guard nickNameField.text  != "" else {
                let errMsg = "Inventory nickname is required."
                signupErrorAlert(title: "Registration Incomplete", message: errMsg)
                return
            }
   
    }
    
         
    
        
        @IBAction func createAccountTapped(sender: AnyObject) {
            checkForEmptyFields()
            
            FIRAuth.auth()?.createUser(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                if let error = error {
                    self.signupErrorAlert(title: "Oops", message:error.localizedDescription)
                    return
                } else {
                    print("MICHAEL: Successfully authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                }
            })
    }
 

func completeSignIn(id: String, userData: Dictionary<String, String>) {

// 1  Create Salon in Database with PUSH ID

    let inventoryBaseRef = FIRDatabase.database().reference(withPath: "collections")
    let newCollectionRef =   inventoryBaseRef.childByAutoId()
    COLLECTION_ID = newCollectionRef.key
    print("SIGNUP - Saving Collection ID as: \(COLLECTION_ID)")

    newCollectionRef.setValue(["inventoryName" : self.nickNameField.text!])

//  2  Create User in Database and Create Tree/Node for User's Salon using Auth ID and Push ID

    let currentUserRef = self.usersRef.child(id)

//                print("I calling the SET VALUE for USERS")

    currentUserRef.setValue(["name" : self.firstNameField.text!,
                             "email" : self.emailField.text!,
                             "collectionAccess":
                                [  "inventoryName": self.nickNameField.text!,
                                   "collectionId" : newCollectionRef.key]])
    
    createDefaultProperties()
    
    self.performSegue(withIdentifier: "SIGNED_UP", sender:nil)
    }
    
    func createDefaultProperties()  {
        let defaultStatuses = ["Empty", "Packed", "In Use", "Stored"]
        
        for i in defaultStatuses {
            let REF_STATUS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/status").childByAutoId()

            let status = ["statusName": i]
            REF_STATUS.setValue(status)
        }
        let REF_Category = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/categories").childByAutoId()
        
        let cat = ["category": "Un-Categorized"]
        REF_Category.setValue(cat)

        
    }

 





        @IBAction func cancelCreateAccount(sender: AnyObject) {
            self.dismiss(animated: true, completion: {})
        }
        
        func signupErrorAlert(title: String, message: String) {
            
            // Called upon signup error to let the user know signup didn't work.
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    
        
        
}
