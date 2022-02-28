//
//  PopoverMenuViewController.swift
//  Pong
//
//  Created by Nathan Pavlovsky on 8/3/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This file is responsible for running the Popover Menu that can be called by the user during gameplay

import UIKit

class PopoverMenuViewController: UIViewController
{

    @IBOutlet var closeButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func quitGame()
    {
        //we quit the game and we go back to the home menu
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "GameMenu") as! MenuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    
    //MARK: - Segues 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showSettings"
        {
            //we are showing the Settings Configure View Controller
        }
    }
    
    @IBAction func returnToPopoverMenu(segue : UIStoryboardSegue)
    {
    }
}
