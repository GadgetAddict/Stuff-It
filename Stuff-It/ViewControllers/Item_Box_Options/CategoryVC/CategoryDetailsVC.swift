//
//  CategoryDetailsVC.swift
//  Inventory17
//
//  Created by Michael King on 2/16/17.
//  Copyright © 2017 Microideas. All rights reserved.
//
//
//  CategoryDetailsVC.swift
//  Inventory17
//
//  Created by Michael King on 2/13/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

enum CategorySelection:String {
    case item
    case settings
    case box
}


class CategoryDetailsVC: UITableViewController, SegueHandlerType {
   
    
    enum SegueIdentifier: String {
        case Item
        case CancelItem
        case Settings
        case Category
        case Subcategory
    }
    
    
    var categoryName:String! {
        didSet {
            categoryNameLabel.text? = categoryName
            self.category = Category(category: categoryName, subcategory: nil)
            subCatTableCell.isUserInteractionEnabled = true
            subCcategoryNameLabel.isHidden = false
            subCcategoryNameLabel.text = "Select"
            subCatTableCell.isUserInteractionEnabled = true
        }
    }

    var subCategoryName:String = "Not Set" {
        didSet {
            subCcategoryNameLabel.text? = subCategoryName
            self.category = Category(category: categoryName, subcategory: subCategoryName)
        }
    }

    
    var category:Category?
    var categorySelectionOption: CategorySelection = .item
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var subCcategoryNameLabel: UILabel!
    @IBOutlet weak var subCatTableCell: UITableViewCell!


    
    override func viewDidLoad() {
        super.viewDidLoad()

        subCatTableCell.isUserInteractionEnabled = false
        subCcategoryNameLabel.isHidden = true

        switch categorySelectionOption {
        case .box:
            print("")
        case .item:
            print("")
        case .settings:
            categoryNameLabel.text = "View"
            subCcategoryNameLabel.isHidden = true
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clear
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            subCatTableCell.isUserInteractionEnabled = false
        }
    }
    
    
    func segue(segue: SegueIdentifier) {
   
        performSegueWithIdentifier(segueIdentifier: segue, sender: self)
    }
    
    func segue() {
    switch categorySelectionOption {
    case .item:
        performSegueWithIdentifier(segueIdentifier: .Item, sender: self)
       
//    case .settings:
//        performSegueWithIdentifier(segueIdentifier: .Settings, sender: self)
    
    default:
        print("")
        }
    
    }
 
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        switch categorySelectionOption{
        case .item:
            segue(segue: .CancelItem)

       
        default:
            print("")
  
            }
        }
    

    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
     
        switch categorySelectionOption{
        case .item:
            if categoryNameLabel.text != "Detail" {
                segue(segue: .Item)
        } else {
                errorAlert("Whoops", message: "A Category is Required")
            }
            
        case .settings:
            segue(segue: .Settings)
            
        default:
            print("")
   
        }
    }
    
    func errorAlert(_ title: String, message: String) {
        // Called upon login error to let the user know login didn't work.
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let categoryPickerViewController = segue.destination as? CategoryPicker {
            
            switch segueIdentifierForSegue(segue: segue) {
                
            case .Category:
                categoryPickerViewController.categoryType = CategoryType.Category
                
            case .Subcategory:
                
                switch categorySelectionOption{
                case .settings:
                    categoryPickerViewController.categorySelection = .settings

                default:
                    
                categoryPickerViewController.categoryType = CategoryType.Subcategory
                if let cat = category?.category{
                        categoryPickerViewController.passedCategory = cat
                        
                    }
                }
            default:
                print("")
            
            }
        }
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
// 
//        if let categoryPickerViewController = segue.destination as? CategoryPicker {
//            
//            if segue.identifier == "showCatList" {
//                categoryPickerViewController.categoryType = CategoryType.category
//                print("I picked Category Type \(categoryPickerViewController.categoryType.rawValue) aka category")
//                
//            }
//            if segue.identifier == "showSubcatList" {
//                categoryPickerViewController.categoryType = CategoryType.subcategory
//                
//                if let cat = category?.category{
//                    categoryPickerViewController.passedCategory = cat
//
//                }
//                if categorySelectionOption == .settings {
//                    categoryPickerViewController.categorySelection = .settings
//                }
//            }
//            
//            if segue.identifier == "unwind_saveCategoryToItemDetails" {
//                category = Category(category: categoryName, subcategory: subCategoryName)
//
//            }
//            
//        }
  //w  }
 
    //    //Unwind segue
    
    @IBAction func CategoryUnwindCancel(_ segue:UIStoryboardSegue) {
    }
            
    @IBAction func CategoryUnwindWithSelection(_ segue:UIStoryboardSegue) {
        if let categoryPickerVC = segue.source as? CategoryPicker {
            let selectedCategory = categoryPickerVC.selectedCategory
            print("Selection that came back is \(String(describing: selectedCategory))")
            
            let categoryType = categoryPickerVC.categoryType
            
            switch categoryType {
                
            case .Category:
                print("category")
                self.categoryName = (selectedCategory?.category)!
                
                
            case .Subcategory :
                print("subcategory ")
                self.subCategoryName = (selectedCategory?.subcategory)!
                
                
             
                
            }
        }
        
    }
    
    
    
    
    
    var curPage = "CategoryDetails"
}
