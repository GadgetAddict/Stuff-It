//
//  PDFPreviewVC.swift
//  PDFGenerator
//
//  Created by Suguru Kishimoto on 2016/02/06.
//
//

import UIKit
import MessageUI

class PDFPreviewVC: UIViewController, MFMailComposeViewControllerDelegate {

   
    @IBOutlet fileprivate weak var webView: UIWebView!
    var url: URL!
    var pdfString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let req = NSMutableURLRequest(url: url)
     
        
        req.timeoutInterval = 60.0
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        webView.scalesPageToFit = true
        webView.loadRequest(req as URLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
 
    }
    
    @objc @IBAction fileprivate func close(_ sender: UIBarButtonItem!) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupWithURL(_ passedPDFpath: String) {
         self.url = URL(fileURLWithPath: passedPDFpath)
        self.pdfString = passedPDFpath
    }

//    MARK: Email 
    
    @IBAction func sendEmail(_ sender: UIBarButtonItem) {
             let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
 
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["michael.a.king@me.com"])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
       
   
             mailComposerVC.addAttachmentData(NSData(contentsOfFile: pdfString)! as Data, mimeType: "application/pdf", fileName: "Invoice")
        
//        mailComposerVC.addAttachmentData(req, mimeType: "application/pdf", fileName: self.url)

//        
//            if let fileData = NSData(contentsOfFile: self.url) {
//                print("File data loaded.")
//                mailComposerVC.addAttachmentData(fileData as Data, mimeType: "application/pdf", fileName: "QR Codes Label")
//            } else {
        
                
            
        
        return mailComposerVC
    }
    
    

    @IBAction func shareButtonClicked(sender: UIBarButtonItem) {
 
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            let objectsToShare = [self.url, mailComposeViewController] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            //
             self.present(activityVC, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }

    }
    
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
  


func showSendMailErrorAlert() {
    let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
    sendMailErrorAlert.show()
}
    
//    MARK: Print Methods
    
    @IBAction func print(sender: AnyObject) {
        
        let activityViewController = UIActivityViewController(activityItems: [url] , applicationActivities: nil)
        
        present(activityViewController,
                              animated: true,
                              completion: nil)
        
  
    }

}
