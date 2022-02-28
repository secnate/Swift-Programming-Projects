//
//  WalkthroughContentViewController.swift
//  SpaceshipGame
//
//  Created by Nathan Pavlovsky on 8/16/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This is the file for the view controller(s) that will be presented in the tutorial walkthrough

import UIKit

class WalkthroughContentViewController: UIViewController
{

    @IBOutlet var tutorialImageView : UIImageView!
    @IBOutlet var forwardButton : UIButton!
    
    var imageFile : String = ""
    var index : Int = 0
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tutorialImageView.image = UIImage(named: imageFile)
       
        //configure the forward button's titles
        switch index
        {
        case 0...4:
            forwardButton.setTitle("NEXT", for: .normal)
            
        case 5:
            forwardButton.setTitle("GET STARTED!",for: .normal)
            
        default:
            break
        }
    }

    @IBAction func nextButtonTapped(sender : UIButton)
    {
        switch index
        {
        case 0...4:
            let pageViewController = parent as! WalkthroughPageViewController
            pageViewController.forward(index: index)
            
        case 5:
            UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}
