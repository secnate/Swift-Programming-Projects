 //
//  SpecificCoinChecklistViewController.swift
//  CoinCollection
//
//  Created by 1A Pavlovsky, N on 3/7/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This is a view controller that shows all the information
//  pertaining to the single coin that is selected
import UIKit
import Foundation



class SpecificCoinChecklistViewController: UIViewController {

    var specificCoin: Coin!  //the coin whose information we have to load
    
    ////////////////////////////////////////////////////////////////
    
    //these are all the objects needed to blur and unblur this viewcontroller
    //both are nil initially as we do not create a viewcontroller that is blurred right off the bat
    private var blurEffect: UIBlurEffect? = nil
    private var blurEffectView: UIVisualEffectView? = nil
    
    //these are the buttons located on the navigationbar in this view
    @IBOutlet var navBar : UINavigationBar!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var actionButton: UIBarButtonItem!
    
    //this refers to the UIActivityViewController that the user can call by clickking the action button
    @IBOutlet private var activityViewController: UIActivityViewController? = nil  //this is the activity viewcontrolelr that we create for social sharing
    
    //this refers to the IndexPath of the specific coin in the tableview of the parent CoinCategoryViewController that
    //called was clicked to present this SpecificCoinChecklistViewController view
    var indexOfSelectedTableButton: IndexPath?

    
    //this refers to the presented EditCoinInformationViewController
    private var presentedEditCoinInformationViewController: EditCoinInformationViewController? = nil
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showSocialSharing()
    {
        //we have a specific coin whose details are shown in this viewcontroller
        //the user wants to share this coin via social media
        
        self.activityViewController = shareCoin(coin: specificCoin)
    
        if activityViewController?.popoverPresentationController != nil
        {
            //we have to present this modally with a popover presentation controller
            activityViewController?.popoverPresentationController!.barButtonItem = actionButton!
            activityViewController?.popoverPresentationController!.permittedArrowDirections = [UIPopoverArrowDirection.up]
            
        }
        
        //after the viewconroller is done, we want to unblur this viewcontroller
        activityViewController?.completionWithItemsHandler =
            {
                (activity, success, items, error) in
                self.unblur()
                self.activityViewController = nil   //we have no uiactivityviewcontroller
            }
        
            
        
        //we blur this viewcontroller in order to make sure that the uiactivities that
        //are called by the uiactivity controller do not have the background text bleeding into it
        //(if it is trasnaprent)
        self.blur()
        
        //we now present the viewcontroller
        self.present(activityViewController!, animated: true, completion: nil) //after we present this uiactivityviewcontroller, we unblur its parent view by the completion handler
    }
    
    @IBAction func searchCoin() -> Void
    {
        //we have a specific coin that we want to know more about..
        let safariViewController = safariSearch(coin: self.specificCoin)
        
        //now we have a possibility of the user clicking the social sharing button and then clicking
        //the search button while the uiactivityviewcontroller is presented. we close the uiactivityviewcontroller and present the sfsafariviewcontroller
        closeActivityViewController()
        
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    @IBAction func deleteTheCoin() -> Void
    {
        //the user wants us to delete the coin. we oblige
        self.close()
        
        let theTabBarController = self.presentingViewController as! UITabBarController
        let theCurrentNavigationController = theTabBarController.viewControllers?[theTabBarController.selectedIndex]
        let parentVC = theCurrentNavigationController?.childViewControllers[1] as! CoinCategoryViewController

        parentVC.askUserIfWantToDeleteCoinAndDeleteIfYes(indexPath: indexOfSelectedTableButton!)
        
    }
    
    func closeActivityViewController()
    {
        //if we have presented a uiactivityviewcontroller - close it
        if (self.activityViewController != nil)
        {
            //if there is an activityviewcontroller and we need to dismiss it, we do this!
            //we remove this uiactivityviewcontroller without any animation
            self.activityViewController?.dismiss(animated: false, completion: nil)
            self.unblur()
        
            self.activityViewController = nil
        }
    }
    
    func blur()
    {
        //we want to blur this viewcontroller (excluding the area of the navigation bar)
        if self.blurEffect == nil
        {
            //we hae not blurred this viewcontroller - let's do it!
            self.blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            self.blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            //now we create the appropriate frame for the blur effect
            //that allows the blur effect to take up all of the viewcontroller EXCLUDING the area of the navigation bar
            //keep in mind that in iOS paradigm, the origin is located in the top-left corner
            let bounds = CGRect(x: 0, y: self.navBar.bounds.height,
                                width: self.view.bounds.width,
                                height: self.view.bounds.height - self.navBar.bounds.height)
            blurEffectView?.frame = bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            
            //we animate the alpha value by making the blur effect take hold gradually
            blurEffectView?.alpha = 0
            self.view.addSubview(blurEffectView!)
            
            //now we animate
            UIView.animate(withDuration: 1, animations: {
                self.blurEffectView?.alpha = 1
            })
        }
        
    }
    
    func unblur()
    {
        //we want to unblur this viewcontroller (excluding the area of the navigation bar)
        if self.blurEffect != nil
        {
            //we animate the removing of the blur effect
            UIView.animate(withDuration: 1, animations: {
                self.blurEffectView?.alpha = 0
            })
            
            //we do have a blureffect to unblur - let's do it!
            self.blurEffectView?.removeFromSuperview()
            
            self.blurEffect = nil
            self.blurEffectView = nil
        }
    }
    
    func updateCoinInformation(c: Coin)
    {
        //this function updates the information presented in this viewcontroller
        //about the specific coin and in the SpecificCoinCategory
        //view controller which will save data throughout the entire app
        let theTabBarController = self.presentingViewController as! UITabBarController
        let theCurrentNavigationController = theTabBarController.viewControllers?[theTabBarController.selectedIndex]
        let parentVC = theCurrentNavigationController?.childViewControllers[1] as! CoinCategoryViewController
        
        parentVC.updateCoinInfo(newCoin: c,indexOfSelectedButton: indexOfSelectedTableButton!)
        
        //now we save in this specific view controller the data
        self.specificCoin.assign(right: c)  //we save the coin's data
        self.viewDidLoad()                  //now we reload the information presented for the specific coin in this view controller
        
        //we force the viewcontroller that presents the coin information to reload 
        //with the appropriate data loaded from the new coin "c"
        if self.presentedEditCoinInformationViewController != nil
        {
            self.presentedEditCoinInformationViewController!.coinToEdit = c
            self.presentedEditCoinInformationViewController!.viewDidLoad()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        // Pass the selected object to the new view controller.
        if segue.identifier == "presentCoinInformation"
        {
            let destinationController = segue.destination as! ShowEditCoinInformationViewController
            
            //we send the coin to present to the view controller
            //for editing purposes...           
            destinationController.coinToEdit = self.specificCoin
            destinationController.indexPathOfCoinToEdit = indexOfSelectedTableButton
        }
        else if segue.identifier == "presentCoinDataToShow"
        {
            let destinationController = segue.destination as! EditCoinInformationViewController
            self.presentedEditCoinInformationViewController = destinationController
            
            destinationController.coinToEdit = self.specificCoin
            destinationController.setEditingState(newCanEdit: false)
        }
    }
    

}
