





import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Constants
    let loginToApp = "SIGNED_IN"
    var handle: FIRAuthStateDidChangeListenerHandle?
    var activeUser: FIRUser!
    
    
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Login viewDidAppear.")
        var walkThrough: Bool!
        
        if UserDefaults.standard.bool(forKey: "hasViewedWalkThrough") {
            walkThrough = true
        } else {
        walkThrough = false
        }
        
        switch walkThrough {
        case true:
            
            print("walkthrough already viewed")
            
            handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
                if let user = user {
                    if(self.activeUser != user){
                        self.activeUser = user
                        print("-> LOGGED IN AS \(String(describing: user.email))")
                        let userRef = DataService.ds.REF_USERS.child(user.uid).child("collectionAccess/collectionId")
                        userRef.observeSingleEvent(of: .value, with: { snapshot in
                            if let collectionRefString = snapshot.value as? String {
                                
                                COLLECTION_ID = collectionRefString
                                print("Login VC: PERFORM SEGUE")
                                self.segue()
                                //                                                self.performSegue(withIdentifier: self.loginToApp, sender:nil)
                            }
                        })
                        
                    }
                } else {
                    print("-> NOT LOGGED IN")
                }
            })
        
        
        default:
            print("goto walkThrough ")
            
            if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "WalkThroughController") as? WalkThroughPageController {
                
                present(pageViewController, animated: true, completion: nil)
            }
            
            
        }
        
        }
 
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//       let setDefaultCollectionQueue = DispatchQueue(label: "com.michael.loginSetCollectionID", qos: DispatchQoS.userInteractive)
        

        
 
//            // 1
//            FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
//                // 2
//                if user != nil {
// 
//                    self.performSegue(withIdentifier: "SIGNED_IN", sender:nil)
// 
//            }
//        }
    
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        login()
        return true;
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            textFieldLoginEmail.resignFirstResponder()
            textFieldLoginPassword.resignFirstResponder()
    }
 
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
       login()
    }
    
//    func handleLogin() {  //this is from new messager app
//        guard let email = textFieldLoginEmail.text, let password = textFieldLoginPassword.text else {
//            print("Form is not valid")
//            return
//        }
//        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
//            print("LOGIN: Is this FB COmpletion hanlder?")
//            if error != nil {
//                print(error)
//                print("This is error message")
//                return
//            }
//            // Successfullu logged in our user
//            print("Maybe this is the real completion handler")
//            self.dismiss(animated: true, completion: nil)
//        })
//    }
//    
    
    func login(){
        // Sign In with credentials.
        
        guard let email = textFieldLoginEmail.text, !email.isEmpty else {
            self.loginErrorAlert("Login Failed", message: "Enter a Valid Email Address.")
            return
        }
        guard let password = textFieldLoginPassword.text, !password.isEmpty else {
            self.loginErrorAlert("Login Failed", message: "Password cannot be blank.")
            return
        }
 
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
//        self.loginErrorAlert("Login Failed", message: error?.localizedDescription)
                // an error occurred while attempting login
                                if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
                                    switch errCode {
                                    case .errorCodeInvalidEmail:
                                        self.loginErrorAlert("Sign In Failed", message: "Enter a Valid Email Address.")
                                    case .errorCodeWrongPassword:
                                        self.loginErrorAlert("Sign In Failed", message: "Incorrect Email address or Password.")
                                    default:
                                        self.loginErrorAlert("Sign In Failed", message: "Please Check Your Information and Try Again.")
                                    }
                                }
            

                 print(error)
                return
            }
            DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { snapshot in
                print("105")
                
                if let collectionRefString = snapshot.value as? String {
                    print(" LOGIN VC Collection ID is \(collectionRefString)")
                    COLLECTION_ID = collectionRefString
                }})
            // Successfullu logged in our user
            self.dismiss(animated: true, completion: nil)
        })

 
    }
    
    
    
    func segue(){
        
        FIRAuth.auth()!.removeStateDidChangeListener(self.handle!)
        self.performSegue(withIdentifier: self.loginToApp, sender:nil)

    }
    
    
    @IBAction func unwindLogOut(sender: UIStoryboardSegue) {
    
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
             self.dismiss(animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
        self.textFieldLoginPassword.text = ""
    }
    
    
    func loginErrorAlert(_ title: String, message: String) {
        // Called upon login error to let the user know login didn't work.
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
 

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("prepareForSegue ")
//        
//        if segue.identifier == "SIGNED_IN" {
//            if let destination = segue.destination as? itemFeedVC {
//            destination.collectionID = ""
//            }
//        }
//    }
    
    
}



//
//extension LoginViewController: UITextFieldDelegate {
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == textFieldLoginEmail {
//            textFieldLoginPassword.becomeFirstResponder()
//        }
//        if textField == textFieldLoginPassword {
//            textField.resignFirstResponder()
//        }
//        return true
//    }
//    
//}



//
//
//
//
//
//import UIKit
//import Firebase
//
//class LoginViewController: UIViewController {
//    
//    // MARK: Constants
//    let loginToApp = "SIGNED_IN"
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // 1
//        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
//            // 2
//            if user != nil {
//                print("USER UID is \(user?.uid)")
//                 self.completeSignIn(id: (user?.uid)!)
//                }
//        }
//    }
//    
//    // MARK: Outlets
//    @IBOutlet weak var textFieldLoginEmail: UITextField!
//    @IBOutlet weak var textFieldLoginPassword: UITextField!
//    
//    // MARK: Actions
//    @IBAction func loginDidTouch(_ sender: AnyObject) {
// 
//    
//        // Sign In with credentials.
//        guard let email = textFieldLoginEmail.text, let password = textFieldLoginPassword.text else { return }
//        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
//            if (error != nil) {
//                // an error occurred while attempting login
//                if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
//                    switch errCode {
//                     case .errorCodeInvalidEmail:
//                        self.loginErrorAlert("Sign In Failed", message: "Enter a Valid Email Address.")
//                     case .errorCodeWrongPassword:
//                        self.loginErrorAlert("Sign In Failed", message: "User Name and Passwords Do Not Match.")
//                    default:
//                        self.loginErrorAlert("Sign In Failed", message: "Please Check Your Information and Try Again.")
//                    }
//                }
//            }
//        }
//    }
//    
//    
// 
//    @IBAction func unwindLogOut(sender: UIStoryboardSegue) {
//        
//        let firebaseAuth = FIRAuth.auth()
//        do {
//            try firebaseAuth?.signOut()
//            self.dismiss(animated: true, completion: nil)
//            
//        } catch let signOutError as NSError {
//            print ("Error signing out: \(signOutError.localizedDescription)")
//        }
//        self.textFieldLoginPassword.text = ""
//    }
// 
//
//      func loginErrorAlert(_ title: String, message: String) {
//    // Called upon login error to let the user know login didn't work.
//        
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
//        alert.addAction(action)
//        present(alert, animated: true, completion: nil)
//    }
//    
//    
//    func completeSignIn(id: String) {
//DataService.ds.getSalonReference()
////        let defaults = UserDefaults.standard
////        defaults.set(SalonIdString, forKey: "SalonId")
//        
//        self.performSegue(withIdentifier: self.loginToApp, sender: nil)
//
//    }
//    
//}
//
//
//extension LoginViewController: UITextFieldDelegate {
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == textFieldLoginEmail {
//            textFieldLoginPassword.becomeFirstResponder()
//        }
//        if textField == textFieldLoginPassword {
//            textField.resignFirstResponder()
//        }
//        return true
//    }
//    
//}
