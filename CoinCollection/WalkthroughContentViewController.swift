//
//  WalkthroughContentViewController.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 7/6/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This is the class responsible for running the viewcontrollers
//  that are presented by the pageviewcontroller

import UIKit

class WalkthroughContentViewController: UIViewController {

    @IBOutlet var headingLabel : UILabel!
    @IBOutlet var contentLabel : UILabel!
    @IBOutlet var contentImageView : UIImageView!
    @IBOutlet var pageControl : UIPageControl!
    @IBOutlet var forwardButton : UIButton!
    
    var index = 0
    var heading = ""
    var imageFile = ""
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        headingLabel.text = heading
        contentLabel.text = content
        contentImageView.image = UIImage(named: imageFile)
        pageControl.currentPage = index
        
        switch index
        {
        case 0...3:
            forwardButton.setTitle("NEXT",for: .normal)
        case 4:
            forwardButton.setTitle("DONE", for: .normal)
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonTapped(sender : UIButton)
    {
        switch index
        {
        case 0...3:
            //Next Button:
            let pageViewController = parent as! WalkthroughPageViewController
            pageViewController.forward(index: index)
            
        case 4:
            //Done Button
            UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
            
            //this is the first time that the user has fired up the app
            //so we set the sorting criteria for organizing this app to be, by default CoinCategory.CategoryTypes.COUNTRY_VALUE_AND_CURRENCY
            UserDefaults.standard.set(CoinCategory.CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue, forKey: "currentSortingCriteria")
            
            //we also set the sorting order for this app to be in ascending order, by default
            UserDefaults.standard.set(CoinCategory.CategorySortingOrder.ASCENDING.rawValue, forKey: "currentSortingOrder")
            
            dismiss(animated: true, completion: nil)
            
        default:
            break
        }
    }
    
}
