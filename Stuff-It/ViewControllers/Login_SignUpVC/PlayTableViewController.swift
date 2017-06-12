//
//  PlayTableViewController.swift
//  Stuff-It
//
//  Created by Michael King on 5/23/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet
import Kingfisher

class PlayTableViewController: UITableViewController ,UINavigationControllerDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SegueHandlerType {

    var items = [Item]()
    var item: Item!
    var box: Box!
    var itemIsBoxed: Bool!
    var qrData = QR()
    lazy var itemIndexPath: NSIndexPath? = nil
    let REF_ITEMS =  DataService.ds.REF_INVENTORY.child("items")

    
    enum SegueIdentifier: String {
        case New
        case BoxFeed
        case BoxDetails
        case Existing
        case ScanQR
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadDataFromFirebase()
        
        let xib : UINib = UINib (nibName: "_itemFeedCell", bundle: nil)
        self.tableView.register(xib, forCellReuseIdentifier: "_itemFeedCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func loadDataFromFirebase() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.REF_ITEMS.observe(.value, with: { snapshot in
            self.items = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let itemDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let item = Item(itemKey: key, dictionary: itemDict)
                        
                        
                        if let childSnapshotDict = snapshot.childSnapshot(forPath: "\(key)/box").value as? Dictionary<String, AnyObject> {                             let itemBoxNumber = childSnapshotDict["itemBoxNumber"]
                            let itemBoxKey = childSnapshotDict["itemBoxKey"]
                            let itemIsBoxed = childSnapshotDict["itemIsBoxed"]
                            
                            
                            item.itemBoxKey = itemBoxKey as! String?
                            item.itemBoxNum = itemBoxNumber as! String?
                            item.itemIsBoxed = itemIsBoxed as! Bool
                        }
                        self.items.append(item)
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }

    // MARK: - Table view data source
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        let image = "package"
        
        return UIImage(named: image)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "You Have No Items"
        
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text =  "Add Items By Tapping the + Button"
            
 
        
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
        
        var text = "Add Your First Item"
        
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: view.tintColor
            ] as [String : Any]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        //         self.performSegue(withIdentifier: "newItem_SEGUE", sender: self)
        performSegueWithIdentifier(segueIdentifier: .New, sender: self)
    }
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        
        return items.count
    }
    
  
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "_itemFeedCell", for: indexPath) as? _itemFeedCell {
           
                let item = items[indexPath.row]
           
            
            cell.configureCell(item: item)
            
            
            return cell
        } else {
            return _itemFeedCell()
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
