//
//  OverlayView.swift
//  Dealership
//
//  Created by Sztanyi Szabolcs on 05/01/16.
//  Copyright © 2016 Zappdesigntemplates. All rights reserved.
//

import UIKit

protocol OverlayDelegate {
    func createNewItem()
    func addMixedContent()
   
}


/// Custom view that displays when a user adds a Car to the Garage (Saves it locally)
class OverlayView: UIView {

    var delegate:OverlayDelegate?
    var boxCategory: String?
    
    @IBOutlet weak var allowMixedButton: RoundCircleButton!
    
    func setLabel() {
        if let category = boxCategory {
            print("Category is \(category)")
        titleLabel.text = "There are no items matching the \(category) category."
        }else {
            print("Category is missing")

            titleLabel.text = "There are no items matching this category."

        }
    }
    
    
    
    func showMixedContentButton(otherItemsAvailable: Bool) {
        print("showMixedContentButton is called and Bool is \(otherItemsAvailable)")
        self.allowMixedButton.isHidden = !otherItemsAvailable
    }
    
    
    /// Label to show the empty text
    @IBOutlet weak var titleLabel: UILabel!
    /// ImageView that holds the icon
    @IBOutlet weak var emptyIcon: UIImageView!

    
  
    @IBAction func createNewItem(_ sender: UIButton) {
   print("createNewItem")
        delegate?.createNewItem()
    }
    
    @IBAction func addMixedContent(_ sender: Any) {
        print("allowMixedContent")
        delegate?.addMixedContent()
    }
    
    // Our custom view from the XIB file
    var view: UIView!

    /// Visual effectView for having a blurry background

    /**
     Initialiser method

     - parameter frame: frame to use for the view
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    /**
     Initialiser method

     - parameter aDecoder: aDecoder
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    /**
     Loads a view instance from the xib file

     - returns: loaded view
     */
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "OverlayView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

    /**
     Sets up the view by loading it from the xib file and setting its frame
     */
    func setupView() {
        print("Overlay NIB:  SETUP was called ")
        
        view = loadViewFromXibFile()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        self.translatesAutoresizingMaskIntoConstraints = false
        
        setLabel()
        
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOpacity = 0.2
//        view.layer.shadowRadius = 4.0
//        view.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)

    }

    override func updateConstraints() {
        super.updateConstraints()
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 500.0))
//        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 20.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
    }
    /**
     Displays the overlayView on the passed in view

     - parameter onView: the view that will display the overlayView
  
    func displayView(_ onView: UIView) {
        self.alpha = 0.0
        onView.addSubview(self)

        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: onView, attribute: .centerY, multiplier: 1.0, constant: -80.0)) // move it a bit upwards
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: onView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        onView.needsUpdateConstraints()

        // display the view
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.alpha = 1.0
                self.transform = CGAffineTransform.identity
            }, completion: { (finished) -> Void in
                // When finished wait 1.5 seconds, than hide it
                let delayTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.hideView()
                }
        })
    }
   */
    
    /**
     Updates constraints for the view. Specifies the height and width for the view
 
    
    override func updateConstraints() {
        super.updateConstraints()

        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 170.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
    }

    /**
     Hides the view with animation
     */
    fileprivate func hideView() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: { (finished) -> Void in
                self.removeFromSuperview()
        }) 
    }
    */
}
