//
//  BoxDetailsSummaryVC.swift
//  Stuff-It
//
//  Created by Michael King on 5/1/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

  class BoxDetails_SummaryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var summaryHeader_View: Summary_HeaderView!
    
  
    var passedText = "stale text"

   
    @IBOutlet weak var tableView: UITableView!
    var passedBoxKey: String?
        var items = [Item]()
        var box: Box!
        var selectedItem: Item!
        var boxItemIndexPath: NSIndexPath? = nil
        var REF_BOX_ITEMS = DataService.ds.REF_BASE.child("/collections/\(COLLECTION_ID!)/inventory/items/")
    
         
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
         }
        
    
        

        override func viewDidLoad() {
            super.viewDidLoad()
//              summaryHeader_View.updateLabels(box: box)
            print("I came from master page: \(self.passedText)")
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            
                 
            loadDataFromFirebase()
          
        }   // End ViewDidLoad
    
    
    func loadDataFromFirebase() {
        print("loadDataFromFirebase")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
 let key = "-KimXMLUtR4ShKJLNqiu"
        let ref = REF_BOX_ITEMS.child("box").queryOrdered(byChild: "itemBoxKey").queryEqual(toValue : key)

        
       
      ref.observeSingleEvent(of: .value, with: { snapshot in
            
            self.items = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("Box-Contents-Snap: \(snap)")
                    
                    if let itemDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let item = Item(itemKey: key, dictionary: itemDict)
                        self.items.append(item)
                    }
                }
            }
                         self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }

    
//    MARK: DZNEmptyDataSet
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        var image: String!
        image = "package"
    
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
        
        
        let text = "Add Items By Tapping the + Button"
            
        
        
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
        
        let text = "Add Your First Item"
    
        
        let attribs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: view.tintColor
            ] as [String : Any]
        
        return NSAttributedString(string: text, attributes: attribs)
    }
    
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
//        self.performSegue(withIdentifier: "newItem_SEGUE", sender: self)
    }

    
//    Mark: TableDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as? ItemCell {
            
            cell.configureCell(item:item)
          
            return cell
        } else {
            return ItemCell()
        }
    }

    
}
    
