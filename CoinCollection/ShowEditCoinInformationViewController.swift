//
//  ShowEditCoinInformationViewController.swift
//  CoinCollection
//
//  Created by 1A Pavlovsky, N on 5/10/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This is the viewcontroller responsible for presenting the EditCoinInformationViewController
//  and getting/showing data from it.

import UIKit

///////////////////////////////////////////////////////////////////////////////////////////////////////////

class ShowEditCoinInformationViewController: UIViewController {

    @IBOutlet var cancelButton: UIBarButtonItem!        //allows the user to exit the view controller
    @IBOutlet var doneButton: UIButton!                 //allows the user to click "Done" when done using the application
    @IBOutlet private var navBar: UINavigationBar!      //can be used to set an appropriate title/message to the user
    
    //can be used to prompt the user with a certain message, should it be needed
    @IBOutlet private var messageLabel: UILabel!
    
    var canEditInformation: Bool = true                 //true if user can edit the data presented in this view controller
    
    var coinToEdit: Coin? = nil                         //by default, this is nil, meaning that we are just getting a new coins information from a user. if not, then we are having the user edit a specific coin's information
    
    var coinInformationVC: EditCoinInformationViewController? = nil //this is the viewcontroller that presents the coin's information in a table to the user
    
    //this is the index path of the selected coin's position in the parent viewcontroller's table
    var indexPathOfCoinToEdit: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCanEditInfo(newEditingState: self.canEditInformation)
    }

    func setCanEditInfo(newEditingState: Bool)
    {
        self.canEditInformation = newEditingState
        
        if self.canEditInformation == true
        {
            //we can edit information, so we set an appropriate title in the
            //navBar to make the user aware of their being able to do this
            navBar.topItem?.title = "Editing Data"
            messageLabel.text = "Important: If You Do Not Know Something, Please Leave the Corresponding Field(s) Empty."
        }
        else
        {
            //we can not edit information. the user is just viewing the data
            //which means that we are just viewing the coin's data
            navBar.topItem?.title = "Viewing Data"
            messageLabel.text = nil
        }
    }
    func toggleCanEditInformation()
    {
        setCanEditInfo(newEditingState: !self.canEditInformation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToParentViewController()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finishUsingTheViewController()
    {
        //this function gets information from the coin and then saves
        //the updated coin or a new coin that is created to the program
        //
        //we get a coin object from the values stored in each text field
        //and if there is a value of nil returned by this function,
        //it means that there is some invalid data in the text fields, 
        //meaning that we can't do anything now
        
        //if the user did not enter valid input, then this called function would 
        //tell them what the probelm with the entered data is
        let coin = coinInformationVC!.getCoinFromInputtedData()
        
        if coin != nil
        {
            //ok, now we have valid input entered by the user
            //and we can get a brand new coin object created with the information stored
            
            if (self.presentingViewController != nil) &&
               (self.presentingViewController! is SpecificCoinChecklistViewController == true)
            {
                let specificCoinVC = (self.presentingViewController! as! SpecificCoinChecklistViewController)
                
                if coinToEdit?.ofSameType(rhs: coin!) == true
                {
                    //we kick off a chain of updating information
                    //throughout the various view controllers
                    specificCoinVC.updateCoinInformation(c: coin!)
                    
                    //the updated version of the coin and the older
                    //version of the coin in coinToEdit are of the same type,
                    //meaning that this is a relatively minor change.
                    returnToParentViewController()  //the specific coin view controller
                }
                
                else
                {
                    //the updated version of the coin and the older version of the coin in coinToEdit are not of the same type
                    let theTabBarController = self.presentingViewController?.presentingViewController as! UITabBarController
                    let theNavigationController = theTabBarController.childViewControllers[theTabBarController.selectedIndex]
                    let coinCategoryVC = theNavigationController.childViewControllers[1] as! CoinCategoryViewController

                    
                    if coinCategoryVC.theCategory.coinCategory?.countNumberOfTypes == 1
                    {
                        //it was the only coin type in the category that we are
                        //updating, which is a relatively minor issue.
                        //
                        //Two possibilities: either the coin was updated and it still can form its own distinct category
                        //or it can be added to a brand new one
                        let coinTableVC = coinCategoryVC.navigationController?.viewControllers[0] as! CoinTableViewController
                        if coinTableVC.coinFitsExistingCategory(coin: coin!) == true
                        {
                            //we can add this coin to an existing category
                            specificCoinVC.updateCoinInformation(c: coin!)
                            
                            let alertToUser = UIAlertController(title: "Coin Category Updated", message: "Due to the updated information, the coin is placed moved from its own category to an already existing one.", preferredStyle: .alert)
                            alertToUser.addAction(UIAlertAction(title: "OK", style: .default,handler: { (UIAlertAction) in  self.performSegue(withIdentifier: "unwindToCoinTableVC", sender: self)}))
                            
                            
                            self.present(alertToUser, animated: true, completion: nil)
                        }
                        
                        else
                        {
                            //we kick off a chain of updating information
                            specificCoinVC.updateCoinInformation(c: coin!)
                            returnToParentViewController()
                        }
                    }
                    else
                    {
                        //it is not the only coin in the category
                        specificCoinVC.updateCoinInformation(c: coin!)
                        
                        let alertToUser = UIAlertController(title: "Coin Category Updated", message: "Due to updated information, the coin was moved into a new category of its own or an already existing category.", preferredStyle: .alert)
                        
                        
                        alertToUser.addAction(UIAlertAction(title: "OK", style: .default,handler: { (UIAlertAction) in  self.performSegue(withIdentifier: "unwindToCoinTableVC", sender: self)}))
                        
                        
                        self.present(alertToUser, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        
        if segue.identifier == "presentCoinDataToEdit"
        {
            let destinationController = segue.destination as! EditCoinInformationViewController
            destinationController.coinToEdit = self.coinToEdit
            
            //we now save a reference to the childviewcontroller
            //so that we can invoke its methods later on
            self.coinInformationVC = destinationController
        }
    }
    

}
