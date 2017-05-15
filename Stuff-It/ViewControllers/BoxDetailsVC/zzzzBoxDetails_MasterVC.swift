//
//  BoxDetails_MasterVC.swift
//  Stuff-It
//
//  Created by Michael King on 5/1/17.
//  Copyright © 2017 Microideas. All rights reserved.
//

import UIKit

enum BoxState {
    case new
    case existing
    case qr
}


class zzzzBoxDetails_MasterVC: UIViewController {
    
    var modelController: ModelController!
    var containerViewController: BoxDetails_SummaryVC?

    @IBAction func editPressed(_ sender: UIBarButtonItem) {
//        if(self.tableView.isEditing == true)
//        {
//            self.tableView.isEditing = false
//            self.urBarButton.title = "Done"
//        }
//        else
//        {
//            self.tableView.isEditing = true
//            self.urBarButton.title = "Edit"
//        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        
        popViewController()
    
    }
    
    @IBOutlet var segmentedControl: UISegmentedControl!

    private lazy var boxDetails_summaryVC: BoxDetails_SummaryVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BoxDetails_SummaryVC") as! BoxDetails_SummaryVC
         // Add View Controller as Child View Controller
        
         self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    
    private lazy var boxDetails_editVC: BoxDetails_EditVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "BoxDetails_EditVC") as! BoxDetails_EditVC
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    
    @IBOutlet weak var LeftNavigationBtn: UIBarButtonItem!
   
    override func viewWillAppear(_ animated: Bool) {
        
        if let MC = modelController{
            let thestring = MC.myString
            print("\nFrom: \(self.curPage) ->  thestring is \(thestring)\n ")
         } else {
            print("\nFrom: \(self.curPage) ->  thestring is MISSING \n ")

        }
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let boxKey = self.modelController.box.boxKey
           print("I got the modelcontrollerbox key \(boxKey)")
        
        
        setupView()
    }

    private func setupView() {
        setupSegmentedControl()
        updateView()

    }
    
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Summary", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Edit", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
    }

    
    func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }

 

    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: boxDetails_editVC)
            add(asChildViewController: boxDetails_summaryVC)
            
        } else {
            remove(asChildViewController: boxDetails_summaryVC)
            add(asChildViewController: boxDetails_editVC)
        }
    }
    
//    MARK: NAVIGATION 
    
    
        func popViewController()  {
//    
//            switch boxSegueType {
//            case .qr:
//                _ = navigationController?.popToRootViewController(animated: true)
//            default:
                _ = navigationController?.popViewController(animated: true)
    
//            }
        }
    
    
  
             override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                 print("Box Details Master SEGUE")
                if let destinationViewController = segue.destination as? BoxDetails_SummaryVC {
                    print("Box Details Master SEGUE \(modelController.box.boxKey)")
                    destinationViewController.passedBoxKey = modelController.box.boxKey
                }
            }
    
        

        
        
    var curPage = "BoxDetails Master"

    
}
