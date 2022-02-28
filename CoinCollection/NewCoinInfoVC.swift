//
//  NewCoinInfoVC.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 5/30/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This file controlls the activity of the NewCoinInfoVC
//  which the user will invoked by the user to create a
//  new coin object to add to the collection

import Foundation
import UIKit

class NewCoinInfoVC: UIViewController
{
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    //this is the viewcontroller that this NewCoinInfoVC presents
    //where the user enters information
    var editCoinInfoVC: EditCoinInformationViewController? = nil
    
    @IBAction func closeViewControllerToParentVC()
    {
        //we call this function if the cancel button has been pressed in the viewcontroller
        //which means that the user does not want to enter a coin's information anymore...
        //we just return the user to the previous viewcontroller that he/she was using...
        navigationController?.popViewController(animated: true)
    }
    
    func closeViewControllerToHomeVC()
    {
        //this function is to be called when the "done" button is clicked
        //and we close this viewcontroller. 
        //We go back to the CoinTableViewController, which is the "home" viewcontroller for the app
        //WARNING: No changes are saved by the user in the app
        performSegue(withIdentifier: "unwindToCoinTableVC", sender: self)
    }
    
    @IBAction func doneButtonClicked()
    {
        //this function is called when the user clicks
        //the done button in the view controller.
        //
        //First, we need to check if the user entered
        //valid input and notify the user of any problems
        //in the inputted information if they exist
        if self.editCoinInfoVC?.validateUserInput() == true
        {
            //we can assume that given the user entering
            //valid information, that there is not a nil coin
            let resultingCoin: Coin =  (self.editCoinInfoVC?.getCoinFromInputtedData())!
            
            let coinTableVC = self.navigationController?.viewControllers[0] as! CoinTableViewController
            coinTableVC.addCoin(coinToAdd: resultingCoin)
            
            closeViewControllerToHomeVC()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "presentEditCoinInfoVCForNewCoin"
        {
            //we have this viewcontroller presenting the EditCoinInformationViewController
            let destinationController = segue.destination as! EditCoinInformationViewController
            
            //we now save the target viewcontroller to manipulate it later on
            //by default it will have nil for coinToEdit.
            self.editCoinInfoVC = destinationController
        }
    }
}
