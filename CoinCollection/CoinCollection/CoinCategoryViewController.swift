//
//  CoinCategoryViewController.swift
//  CoinCollection
//
//  Created by 1A Pavlovsky, N on 2/16/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  Used to represent the screen that shows all the coins of the specific
//  type that differ only by year, mintmark, or other less-significant criteria

import UIKit
import SafariServices

class CoinCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating
{
   
    @IBOutlet var coinsTable: UITableView!                //shows coins stored in coinsArr
    var theCategory: CoinCategoryMO!            //the category of coins

    @IBOutlet var firstRowLabel: UILabel!   //shows the value and denomination
    @IBOutlet var secondRowLabel: UILabel!                //shows the country
    @IBOutlet var sampleImage: UIImageView!             //shows a sample image of the coin
    @IBOutlet var sampleImageDescription: UILabel!      //describes the presented sampleImage
    
    //these are all the objects needed to ensure that we blur the viewcontroller
    //when we are calling on the uiactivityviewcontroller and the uiactivities
    //that it contains. Why do we blur this viwcontroller when that happens?
    //some of the uiactivities have semi-transparent background and we do not want
    //the text in the background to bleed into the uiactivites and distract the user
    private var blurEffect: UIBlurEffect? = nil
    private var blurEffectView: UIVisualEffectView? = nil
    
    //this is the index of the coin that we want to delete from this table and from the app in general
    //the state of the indexPathOfCoinToDelete equaling nil means that we do not want to delete anything as of now
    private var indexPathOfCoinToDelete: IndexPath? = nil
    
    //this is the index of the coin category that was selected in the CoinTableViewController
    //[the parent view controller in this case]
    var indexPathOfSelectedCoinCategory: IndexPath? = nil
    
    ///////////////////////////////////////////////////////////////////////////////////
    //these two buttons are supposed to allow the toggling of a booleain (isEditing) that allows
    //the user to reorder the rows in the tableviewcontrollerand in the appropriate array of data
    //the only case where such buttons do not appear is if there is only one coin in the category- 
    //meaning that the table is non-reorderable.
    //
    //Now on the navigation controller, we are going to have the following order for the right barbuttons:
    //cancelButton/editButton and then a createNewCoinButton
    private var cancelButton: UIBarButtonItem!
    private var editButton: UIBarButtonItem!
    private var createNewCoinButton: UIBarButtonItem!
    
    //this button is for the user to delete all the coins in the category
    private var deleteButton: UIBarButtonItem!
    
    ///////////////////////////////////////////////////////////////////////////////////

    //this is used for searching across the specific coins in the category
    //this is the search bar which the user can use to search for a specific coin
    var searchController : UISearchController!
    var searchResults : [Coin] = []
    private static let PLACEHOLDER_TEXT_FOR_BAR_WHEN_REORDERING = "Cannot Search While Reordering Coins"
    private var activeTextBeforeRotating : String? = nil
    
    ///////////////////////////////////////////////////////////////////////////////////

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //we assume that this sample coin is representative of all coins in the category
        let sampleCoin = theCategory.coinCategory!.coinsInCategory[0]
        
        //we setup the main labels that represent all of the countries
        switch theCategory.coinCategory!.currentCategoryType
        {
        case CoinCategory.CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue:
            //this category sorts based on the coins' countries, values, and currency
            self.firstRowLabel.text = sampleCoin.valueAndDenomination as String
            self.secondRowLabel.text = sampleCoin.getCountry() as String
            
        case CoinCategory.CategoryTypes.COUNTRY.rawValue:
            //this category sorts based on the coins' countries
            self.firstRowLabel.text = sampleCoin.getCountry() as String
            
            //since we only need one label to represent what is going on in the overal category, we can remove the second label
            self.secondRowLabel.removeFromSuperview()
            
        case CoinCategory.CategoryTypes.CURRENCY.rawValue:
            //this category sorts based on the coin's currency (which means that it has to come from the same country as well)
            self.firstRowLabel.text = sampleCoin.getCountry() as String
            self.secondRowLabel.text = sampleCoin.getDenomination() as String
            
        case CoinCategory.CategoryTypes.YEAR.rawValue:
            //this category sorts based on the coin's year
            if sampleCoin.getYear() != nil
            {
                if sampleCoin.getYear()!.intValue > 0
                {
                    //this year is CE
                    firstRowLabel.text = "\(abs(sampleCoin.getYear()!.intValue)) " + TimePeriods.CE.rawValue
                }
                else
                {
                    //this year is BCE 
                    firstRowLabel.text = "\(abs(sampleCoin.getYear()!.intValue)) " + TimePeriods.BCE.rawValue
                }
            }
            else
            {
                self.firstRowLabel.text = Coin.DEFAULT_YEAR as String
            }
            
            self.secondRowLabel.removeFromSuperview()
            
        default:
            self.firstRowLabel.text = ""
            self.secondRowLabel.text = ""
            
        }
        //set up the search results label
        setUpSearchBarPlaceholderText()
        
        //we now prepare the table
        coinsTable.delegate = self
        coinsTable.dataSource = self
        
        //if there is an empty area in the table view, instead of showing
        //empty cells, we show a blank area
        self.coinsTable.tableFooterView = UIView()
        
        //and we make the cells resizable. 
        //this also allows the user to edit the text size in accessibility
        //and then the app will dynamically adapt to the user's needs!
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            //we are on iphone... can not use as much screen space
            coinsTable.estimatedRowHeight =  85
        }
        else
        {
            //we are on ipad... can use more screen space
            coinsTable.estimatedRowHeight = 100
        }
        coinsTable.rowHeight = UITableViewAutomaticDimension
        
        //sets the cell-separator lines for the UITableView to be clear [especially since we had black lines in between empty cells]
        coinsTable.separatorColor = UIColor.clear
        
        ///////////////////////////////////////////////////////////////////
        //we now prepare the navigation item with the appropriate buttons
        prepNavigationController()
        
        //we do not want the user to be able to hide the navigation bar
        //while scrolling in this view controller
        navigationController?.hidesBarsOnSwipe = false
        
        //we load a sample image for the user's visual plasure
        loadSampleImage()
        coinsTable.reloadData()
        
        //we prepare the search controller
        searchController = UISearchController(searchResultsController: nil)
        coinsTable.tableHeaderView = searchController.searchBar
        
        //we customize it
        self.setUpSearchBarPlaceholderText()
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.tintColor = .black
        
        //we do not want the search controller to collapse the navigation bar 
        //during the user searching across the various coin in the category
        searchController.hidesNavigationBarDuringPresentation = false
        
        //we want this search controller to dissappear when
        //we transition to the next view controller
        searchController.definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        //we create a white background color as when the user scrolls up, 
        //we do not want the
        searchController.searchBar.backgroundColor = UIColor.white

        //if the user scrolls up, he sees a white background,
        //not a grey one behind the table
        coinsTable.backgroundView = UIView()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //we want to prevent the user from being able to hide the navigation
        //bar while swiping in this view controller
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func willMove(toParentViewController parent: UIViewController?)
    {
        //this is a function that will be called when the user clicks the 
        //back button in this viewcontroller to go back to the parent viewcontroller
        //in the navigation hierarchy. If the user at that time had an already - 
        //activated search bar, then this function explicitely turns it OFF
        if self.searchController != nil && searchController.isActive == true
        {
            self.searchController.isActive = false
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval)
    {
        //This function is called when the user is rotating the device...
        //the the user is using the searchcontroller during the time, then we
        //want the searchController to end up in the proper position after the user
        //rotates the device and that the user's typed text does not get lost.
        //
        //Now, the only way that I, the programmer, have found the searchController to
        //re-orient itself properly is if it is inactivated, so before rotating the
        //device, we need to deactivate the searchController, and we save the text.
        if self.searchController != nil && self.searchController.isActive == true
        {
            self.activeTextBeforeRotating = self.searchController.searchBar.text
            self.searchController.isActive = false
            
            self.coinsTable.alpha = 0
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation)
    {
        //this function is called after the user finished rotating the device.
        //Per the described sitaution in the "willRotateTo" function, we need to
        //re-activate the searchController and load the searchText...
        if self.searchController != nil && self.activeTextBeforeRotating != nil
        {
            self.searchController.isActive = true
            self.searchController.searchBar.text = self.activeTextBeforeRotating
            self.coinsTable.alpha = 1
            
            self.activeTextBeforeRotating = nil
        }
    }
    
    func loadSampleImage()
    {
        //we load an image into the sampleImage ImageView so that the user
        //could get an idea of what type of coins are in the category.
        //Order of priorities: OBVERSE IMAGE, REVERSE IMAGE, NOT_AVAILABLE IMAGE
        sampleImage.clipsToBounds = true
        sampleImage.contentMode = .scaleAspectFill
        
        for coin in (self.theCategory.coinCategory?.coinsInCategory)!
        {
            if coin.getObverseImage() != nil
            {
                sampleImage.image = coin.getObverseImage()!
                sampleImageDescription.text = "Obverse - " + coin.getIncompleteSummary()
                return  //we are done
            }
        }
        
        for coin in (self.theCategory.coinCategory?.coinsInCategory)!
        {
            if coin.getReverseImage() != nil
            {
                sampleImage.image = coin.getReverseImage()!
                sampleImageDescription.text = "Reverse - " + coin.getIncompleteSummary()
                return
            }
        }
        
        //otherwise, since we are unable to come up with an obverse
        //or a reverse image, we initialize the sampleImage and its 
        //description to default values.
        sampleImage.image = #imageLiteral(resourceName: "photoalbum")
        sampleImageDescription.text = nil
    }
    
    func prepNavigationController()
    {
        //this function iniializes the appropriate buttons and the appropriate properties 
        //of the navigation item
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done,target: self, action: #selector(self.toggleEditing))
        self.editButton = UIBarButtonItem(title: "Reorder", style: .plain, target: self, action: #selector(self.toggleEditing))
        self.createNewCoinButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose,target: self, action: #selector(self.createNewCoin))
        
        self.deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteCategory))
        
        self.navigationItem.rightBarButtonItems = getAppropriateRightBarButtonItems()
    }
    
    func getAppropriateRightBarButtonItems() -> [UIBarButtonItem]
    {
        //used to select the proper combination of the right bar button items
        var arrayButtons: [UIBarButtonItem] = [self.createNewCoinButton,self.deleteButton]
        if ((self.theCategory.coinCategory?.countNumberOfTypes.intValue)! > 1)        //we have enough coins to make it reorderable
        {
            arrayButtons.insert(self.editButton, at: 0) //edit, create, delete buttons [in order from right to left]
        }
        
        return arrayButtons
    }
    
    func toggleEditing()
    {
        //if the user has activated the searchController before clicking one of these
        //buttons, then we want the user to focus on the clicked editing actions
        self.searchController.isActive = false  //we deactivate searchController
        
        if self.navigationItem.rightBarButtonItems?[0].style == self.editButton.style
        {
            ///////////////////////////////////////////////////////////////
            //first things first, let's say the user swiped the cell to the
            //right, revealing all the buttons that are revealed
            //and then clicks the edit button..... we first want to deselect
            //the cells that were swiped and then to prepare for editing
            if self.coinsTable.indexPathsForVisibleRows != nil    //we get the indexes of the visible rows
            {
                self.coinsTable.reloadRows(at: coinsTable.indexPathsForVisibleRows!, with: .none)
            }
            
            ///////////////////////////////////////////////////////////////
            //now we prepare for editing
            self.coinsTable.isEditing = true
            self.navigationItem.rightBarButtonItems?[0] = cancelButton
            
            //we do not want the user to be able to search across the coins
            //in the category when reordering them...
            self.searchController.searchBar.isUserInteractionEnabled = false
        }
        else if self.navigationItem.rightBarButtonItem?.style == self.cancelButton.style
        {
            self.coinsTable.isEditing = false
            self.searchController.searchBar.isUserInteractionEnabled = true
            
            //we are done editing.. now we change the buttons to the edit button
            self.navigationItem.rightBarButtonItems?[0] = editButton
        }
        
        
        setUpSearchBarPlaceholderText()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        //this returns the appropriate editing style based on if the person is reordering (a.k.a. "editing")
        //the cells in this tableview or if he is just swiping horizontally to access the buttons
        if self.coinsTable.isEditing == true
        {
            return UITableViewCellEditingStyle.none
        }
        else
        {
            //this editing style allows for the swiping actions for each cell in the table view
            return UITableViewCellEditingStyle.delete
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool
    {
        //we do not want the cells to be indentable when editing
        return false
    }

    // Override to support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath)
    {
        if (fromIndexPath.row != to.row)
        {
            //we swap the order of the coins in this view controller
            //but we also save the changes in the "master array" of the coin 
            //collection in the CoinTableViewController
            //
            //the reason why we first swap the coins in the CoinCategory object and then create an entire
            //new category is that with the changing of the CoinCategory object by setting it to an entirely
            //NEW value, the appDelegate will save the context and the changes
            self.theCategory.coinCategory?.swapCoinsInCategory(indexOne: fromIndexPath.row, indexTwo: to.row)
            self.theCategory.coinCategory = CoinCategory(coins: (self.theCategory.coinCategory?.coinsInCategory)!, categoryType: (self.theCategory.coinCategory?.currentCategoryType)!)
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
            {
                appDelegate.saveContext()
            }
        }
    }
    
    // Override to support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    //we determine that a table view's cells are not selectable if the user is in the process of
    //rearranging the cell's rows
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        //there is only the create newcoinbutton or we have the edit button ready to go!
        if (self.navigationItem.rightBarButtonItems!.count == 1 ||
            self.navigationItem.rightBarButtonItems?[0].style == self.editButton.style)
        {
            //we have two possiblities that we are checking for here
            //(1) We do not have an edit button. This only occurs when
            //    we have only one coin in this category of coins, which
            //    makes the editing button redundant and not needed.
            //(2) there is an edit button in the navigation bar, meaning that
            //    we are not CURRENTLY editing - making selection of a cell possible
            return indexPath
        }
            
        //we have two buttons for the right side in the navigation item....
        //so we can consider the possibility of the cancel button existing....
        else if (self.navigationItem.rightBarButtonItems?.count)! > 1 &&
            self.navigationItem.rightBarButtonItems?[0].style == self.cancelButton.style
        {
            //we are currently editing the cell - so selection of a cell is not possible
            return nil
        }
        
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //set the table's number of rows
        if searchController != nil && searchController.isActive
        {
            return searchResults.count
        }
        else
        {
            if self.theCategory.coinCategory == nil
            {
                return 0
            }
            else
            {
                return Int((self.theCategory.coinCategory?.countNumberOfTypes)!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //we load the table
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SpecificCoinCell
        
        let currentCoin : Coin = (searchController.isActive) ? searchResults[indexPath.row] : (theCategory.coinCategory?.getCoin(at: indexPath.row))!  //we get the current coin being examined to build the table cell
        
        cell.configureCell(currentCoin: currentCoin, categoryType: theCategory.coinCategory!.currentCategoryType)
        
        
        cell.accessoryType = .disclosureIndicator    //shows that clicking the cell will lead to more information about the specific coin
        
        //now let's frame the cell with a blue color
        cell.layer.masksToBounds = true
        cell.layer.borderColor = UIColor.blue.cgColor
        cell.layer.borderWidth = 1.0
        
        return cell
    }
    
    func setUpSearchBarPlaceholderText()
    {
        if self.searchController != nil
        {
            if self.searchController.searchBar.isUserInteractionEnabled == true
            {
                if (theCategory.coinCategory?.countNumberOfTypes == 1)
                {
                    if searchController != nil
                    {
                        searchController.searchBar.placeholder = "Search Across 1 Coin Type..."
                    }
                }
                else
                {
                    if searchController != nil
                    {
                        searchController.searchBar.placeholder = "Search Across \(Int((theCategory.coinCategory?.countNumberOfTypes)!)) Coin Types..."
                    }
                }
            }
            else
            {
                //the user is re-ordering the order of the coin in the category
                //and thus does not need to use the search bar
                self.searchController.searchBar.placeholder = CoinCategoryViewController.PLACEHOLDER_TEXT_FOR_BAR_WHEN_REORDERING
            }
        }
    }
    
    //enable the swiping actions for each button
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        //Social Sharing Button
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "📨\nShare", handler: { (action, indexPath) -> Void in
            
            let viewControllerToPresent = shareCoin(coin: (self.theCategory.coinCategory?.getCoin(at: indexPath.row))!)
            
            if viewControllerToPresent.popoverPresentationController != nil
            {
                //we have to present this modally with a popover presentation controller
                viewControllerToPresent.popoverPresentationController!.sourceView = tableView
                viewControllerToPresent.popoverPresentationController!.sourceRect = tableView.rectForRow(at: indexPath)
                viewControllerToPresent.popoverPresentationController!.permittedArrowDirections = [UIPopoverArrowDirection.up,UIPopoverArrowDirection.down]
            }
            
            //after the viewconroller is done, we want to unblur this viewcontroller
            viewControllerToPresent.completionWithItemsHandler =
                {
                    (activity, success, items, error) in
                    self.unblur()
            }
            
            //we blur this viewcontroller in order to make sure that the uiactivities that
            //are called by the uiactivity controller do not have the background text bleeding into it
            //(if it is trasnaprent)
            self.blur()
            
            self.present(viewControllerToPresent, animated: true, completion: nil)
            
        })
        shareAction.backgroundColor = UIColor.orange //configuring the looks of the shareAction
        
        
        //we google search for more information
        let searchAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "🔎\nSearch", handler: { (action, indexPath) -> Void in
            
            let coin : Coin = (self.theCategory.coinCategory?.getCoin(at: indexPath.row))!  //we get the coin that we are looking at to get more information
            
            //we got the appropriate SFViewController for the google search - present it
            self.present(safariSearch(coin: coin), animated: true, completion: nil)
        })
        searchAction.backgroundColor = UIColor.blue
        
        //Delete button... we want to delete this specific coin from the app
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive,title: "🗑\nDelete", handler: { (action, indexPath) -> Void in
            
            if self.searchController.isActive == true
            {
                self.askUserIfWantToDeleteCoinAndDeleteIfYes(indexPath: IndexPath(row: self.theCategory.coinCategory!.getIndexOfCoinInCollection(coin: self.searchResults[indexPath.row]), section: 0))
            }
            else
            {
                self.askUserIfWantToDeleteCoinAndDeleteIfYes(indexPath: indexPath)
            }
        })
        deleteAction.backgroundColor = UIColor.red
        
        
        return [deleteAction, shareAction, searchAction]
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
            let bounds = CGRect(x: 0,
                                y: (self.navigationItem.accessibilityFrame.height),
                                width: self.view.bounds.width,
                                height: self.view.bounds.height - (self.navigationItem.accessibilityFrame.height))
            blurEffectView?.frame = bounds
            blurEffectView?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            
            self.view.addSubview(blurEffectView!)
            
        }
        
    }
    
    func unblur()
    {
        //we want to unblur this viewcontroller (excluding the area of the navigation bar)
        if self.blurEffect != nil
        {
            //we do have a blureffect to unblur - let's do it!
            self.blurEffectView?.removeFromSuperview()
            
            self.blurEffect = nil
            self.blurEffectView = nil
        }
    }
    
    func askUserIfWantToDeleteCoinAndDeleteIfYes(indexPath: IndexPath)
    {
        //we save the IndexPath of the coin that we are considering deleting so that the index can be use if needed
        saveCoinToDelete(indexPath: indexPath)
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //we ask user if they want to delete the coin at the given indexPath in the table.
        //if this is what the user REALLY wants to do, then we of course, delete it.
        
        //Because this is an irreversible action of deleting a coin, we want to make sure that this
        //is really what the user wants to do - so we ask
        let confirmMenu = UIAlertController(title: "Confirmation Required",
                                            message: "Are you sure you want to delete this coin?", preferredStyle: .alert)
        
        //now we add the two actions to the confirmMenu - one allows the user to continue with the deletion process
        //and the other one allows the user to return to the previous viewcontroller without any harm done
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive, handler: { (nil) -> Void in
            
            //we have to delete the coin
            self.deleteTheCoin()
        
        })
        let cancelAction = UIAlertAction(title: "No", style: .default, handler: {(nil) -> Void in
            
            //the user does not want to delete the coin - everything is (surprisingly) good now :-/
            self.clearCoinToDelete()
        })
        
        
        confirmMenu.addAction(deleteAction)
        confirmMenu.addAction(cancelAction)
        
        //let's present the menu and get the show rollin'!
        self.present(confirmMenu, animated: true, completion: nil)
        
    }
    
    func saveCoinToDelete(indexPath: IndexPath)
    {
        //this function records the indexpath of the coin that we want 
        //to delete from the table and from the app in general
        //
        //the saved indexpath can then be used in the future to actually delete
        self.indexPathOfCoinToDelete = indexPath
    }
    
    func clearCoinToDelete()
    {
        //this function clears the indexPathOfCoinToDelete as we do not want to delete any coin as of NOW
        self.indexPathOfCoinToDelete = nil
    }
    
    func deleteTheCoin()
    {
        //this function deletes the coin from the table of this viewcontroller and from the app
        //in general. IFF the indexpath of the coin that we are to remove has been saved in advance
        if (self.indexPathOfCoinToDelete != nil && self.indexPathOfSelectedCoinCategory != nil)
        {
            //we do have a valid coin that we want to delete
            //we first delete the coin from the category, and then we create an entirely new CoinCategory
            //object as that is the only way that the appDelegate will be able to register the change in the
            //coinCategory attribute of the CoinCategoryMO generated class and save it in core data
            
            if self.theCategory.coinCategory?.countNumberOfTypes == 1
            {
                //we have only one remaining coin in the category meaning that we have to delete the entire category
                //we delete the category...
                let parentVC = self.navigationController!.viewControllers[0] as! CoinTableViewController
                
                //and since we have deleted the category, we should not remain at this viewcontroller anymore
                self.navigationController?.popToRootViewController(animated: true)
                
                //the reader might ask, "why did you joe programmer not delete the coins in this viewcontroller as well?"
                //I respond with the following: "there was no point." We delete the coin category from the "master array"
                //in the CoinTableViewController class and then we have a segue to go to the CoinTableViewController...
                //and thus we destroy this viewcontroller and the data it stores in the process... otherwise
                //deleting the coins from this viewcontroller as well before destroying the viewcontroller itself
                //would have been a waste of time and memory and we would have achieved the same result...
                parentVC.deleteCoinCategory(rowPath: self.indexPathOfSelectedCoinCategory!)
                self.coinsTable.deleteRows(at: [indexPathOfCoinToDelete!], with: .fade)
                
                
            }
            else
            {
                //we have only more than one coin in this category, so we are not deleting the last coin in it
                
                //we remove the coin from the 'coinCategory' and then we create an entire new CoinCategory object
                //so that the AppDelegate will register the changes to the "theCategory" object and will save
                //the changed states in core data
                self.theCategory.coinCategory?.removeCoin(at: indexPathOfCoinToDelete!.row)
                self.theCategory.coinCategory = CoinCategory(coins: (self.theCategory.coinCategory?.coinsInCategory)!, categoryType: (self.theCategory.coinCategory?.currentCategoryType)!)
                
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate
                {
                    appDelegate.saveContext()
                }
                
                //we have now deleted the coin from the category and the app, system-wide
                self.coinsTable.deleteRows(at: [indexPathOfCoinToDelete!], with: .fade)
                
                //we have altered the number of coins in the table, so we want to ensure that
                //we have the right number of search results in the search arr label
                setUpSearchBarPlaceholderText()
                
                //we have the possibility where the number of coins in this category [coinsArr]
                //is one after deleting the coin, making the coin table unorderable
                if theCategory.coinCategory!.countNumberOfTypes.intValue <= 1 && (self.navigationItem.rightBarButtonItems?.count)! > 1
                {
                    self.navigationItem.rightBarButtonItems = getAppropriateRightBarButtonItems()
                }

                clearCoinToDelete() //we have deleted a coin - clear the indexpath
            }
        }
    }
    
    func deleteCategory()
    {
        //this function is called by the user who clicks the delete button in the navigation bar
        //at the top of the screen in this view controller... the user wants to delete the ENTIRE category
        //
        //Now the reason why we turn off the search controller is that the user could
        //have activated the searchController and then clicked the delete button.
        //We want to turn off the seach controller in this case so that the only
        //thing that the user has to focus on is the deleting of the entire coin category
        self.searchController.isActive = false

        let askIfDeleteCategory: UIAlertController = UIAlertController(title: "Confirmation Required",
                                                                       message: "Are you sure you want to delete this category and all the coins in it?", preferredStyle: .alert)
        
        askIfDeleteCategory.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (UIAlertAction) in
            
            //we delete the category...
            let parentVC = self.navigationController!.viewControllers[0] as! CoinTableViewController
            
            self.navigationController?.popToRootViewController(animated: true)
            //the reader might ask, "why did you joe programmer not delete the coins in this viewcontroller as well?"
            //I respond with the following: "there was no point." We delete the coin category from the "master array"
            //in the CoinTableViewController class and then we have a segue to go to the CoinTableViewController...
            //and thus we destroy this viewcontroller and the data it stores in the process... otherwise
            //deleting the coins from this viewcontroller as well before destroying the viewcontroller itself
            //would have been a waste of time and memory and we would have achieved the same result...
            parentVC.deleteCoinCategory(rowPath: self.indexPathOfSelectedCoinCategory!)
        }))
        
        askIfDeleteCategory.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        present(askIfDeleteCategory, animated: true, completion: nil)
    }
    
    func updateCoinInfo(newCoin: Coin,indexOfSelectedButton: IndexPath)
    {
        //this function helps save the updated data for a coin that a user has entered
        //
        //Parameter indexOfSelectedButton represents the index of the coinsTable row
        //that the user has selected to have the coin's data displayed.
        //
        //Parameter newCoin represents a complete coin object composed of all the 
        //updated versions of the data.
        //
        //Now, we have three cases to consider:
        //(1) The user has edited the coin's data so that it has some
        //    minor details altered but it is in the same category of coins
        //    as before. Thus, the only thing the program needs to do is to save
        //    the updated information, and not worry about moving this coin
        //    to another category or creating a new category.
        //
        //    OR: The user has edited the coin's data so that it is in a new
        //        category entirely.
        //
        //(2) The coin was the only one in its category, meaning that the user
        //    modifying its data to the point where it is in a new category of
        //    its own is not a significant problem, compared to creating an
        //    entirely new category of coins or moving the coin to an existing
        //    category.
        //
        //(3) The coin was not the only one in its category, meaning that the user
        //    modifying its data to the point where it is in a new category of
        //    its own poses a significant problem. Not only do we need to save
        //    the updated coin data, but we also need to move the coin to either
        //    an existing category or to create a new category of coins entirely.
        
        let parentVC = self.navigationController!.viewControllers[0] as! CoinTableViewController
        
        //we now save the data
        if theCategory.coinCategory?.getCoin(at: indexOfSelectedButton.row)?.ofSameType(rhs: newCoin) == true
        {
            //(1) The user has edited the coin's data so that it has some
            //    minor details altered but it is in the same category of coins
            //    as before. Thus, the only thing the program needs to do is to save
            //    the updated information, and not worry about moving this coin
            //    to another category or creating a new category.
            
            //we now need to save the data in this view controller
            theCategory.coinCategory?.getCoin(at: indexOfSelectedButton.row)?.assign(right: newCoin)
            
            //the reason why we create an entirely new CoinCategory object is that the
            //only way that the appDelegate will register the changes and thus save the 
            //information is if we assign to it an ENTIRELY NEW CATEGORY
            theCategory.coinCategory = CoinCategory(coins: (theCategory.coinCategory?.coinsInCategory)!,categoryType: (theCategory.coinCategory?.currentCategoryType)!)
            
            //we update the information in the table
            viewDidLoad()
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate
            {
                appDelegate.saveContext()
            }
        }
        else
        {
            //we have met the conditions for (2) and (3)
            if theCategory.coinCategory?.countNumberOfTypes == 1
            {
                //We have met the conditions for case 2.
                //The coin whose data was modified was the only coin in its
                //category.          
                if parentVC.coinFitsExistingCategory(coin: newCoin) == false
                {
                    //this coin does not fit into any previously existing category
                    //since it is the only coin in the category, we leave it as is
                    theCategory.coinCategory = CoinCategory(coins: [newCoin], categoryType: (theCategory.coinCategory?.currentCategoryType)!)
                
                    //we reload the view controller's information in light of recent developments
                    viewDidLoad()
                
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    {
                        appDelegate.saveContext()
                    }
                }
                else
                {
                    //with the updates, the coin does fit into a previously existing 
                    //category. we thus need to delete this category and add the coin to
                    //one of the existing ones....
                    parentVC.deleteCoinCategory(rowPath: self.indexPathOfSelectedCoinCategory!)
                    parentVC.addCoin(coinToAdd: newCoin)
                }
            }
            else
            {
                //We have met the conditions for case 3.
                //The coin whose data was modified was not the only coin in its
                //category. We have a very complex problem as we need to remove
                //this coin from this category of coins and then add it to
                //either an existing category or create an entirely new category
                saveCoinToDelete(indexPath: indexOfSelectedButton)
                deleteTheCoin()
                
                //and the changes will be saved throughout the entire app
                parentVC.addCoin(coinToAdd: newCoin)
            }
        }
    }

    func returnToParentVC()
    {
        //we go back from this specific coin category viewcontroller to the general viewcontroller
        performSegue(withIdentifier: "returnToCoinTable", sender: self)
    }
    
    func reloadTheGeneralCoinCategoryVCCellInTable(index: IndexPath)
    {
        //this function can be used after deleting a coin from the app
        //it updates the information in a specific row to make sure that it stays up to date
        let generalCoinVC = self.navigationController!.viewControllers[0] as! CoinTableViewController
      
        generalCoinVC.tableView.reloadRows(at: [index], with: .automatic)
    }
    
    @IBAction func createNewCoin()
    {
        //this function is called by the user who clicked the "compose" button
        //
        //we let the general coin view controller perform the segue to present the NewCoinInfoVC
        //as if the user clicks "cancel" or clicks "done" in the new coin view controller, we want
        //the app to send the user back to the CoinTableViewController
        
        //if the user has activated the search controller, we turn it off before we transition
        self.searchController.isActive = false
        let generalCoinVC = self.navigationController!.viewControllers[0] as! CoinTableViewController
        generalCoinVC.performSegue(withIdentifier: "presentNewCoinVC", sender: generalCoinVC)
        
    }
    
    // MARK: - Searching
    
    func filterContent(for searchText : String)
    {
        searchResults = (theCategory.coinCategory!.coinsInCategory.filter({ (coin) -> Bool in
            
            for word in searchText.components(separatedBy: " ")
            {
                if wordFitsCoin(word: word,coin: coin) == true
                {
                    return true
                }
            }
            
            return false
        }))
    }
    
    func wordFitsCoin(word: String, coin: Coin) -> Bool
    {
       //we have a word that can be used to describe this coin, potentially
       //
       //we look if the word describes the coin in the following data:
       //Value, Denomination, Year, Mint, Description, Grade
        
       //value
       if coin.getValue().intValue > 0
       {
            //the coin has a valid value over 0
            let value: String = "\(coin.getValue())"
            if value.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
       }
       else
       {
            if Coin.DEFAULT_VALUE_STRING.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
       }
        
       //denomination
        if coin.getDenomination().localizedCaseInsensitiveContains(word) == true
        {
            return true
        }
        
       //year 
        if coin.getYear() != nil
        {
            if "\(coin.getYear()!)".localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
            
            //we also check for the user entering either "AD" or "BCE" into the searchBar
            //
            //By definition, if the coin's year is negative, then it is from the BCE
            //time period. If the coin's year is positive, then it is from the CE time period
            if coin.getYear()!.intValue < 0 && TimePeriods.BCE.rawValue.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
            
            if coin.getYear()!.intValue > 0 && TimePeriods.CE.rawValue.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
        }
        else
        {
            if Coin.DEFAULT_YEAR.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
        }
        
        //mint 
        if coin.getMint().localizedCaseInsensitiveContains(word) == true
        {
            return true
        }
        
        //Grade 
        if coin.getGrade() != nil
        {
            if "\(coin.getGrade()!.intValue)".localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
        }
        else
        {
            if Coin.NOT_AVAILABLE.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
        }
    
        //number of instances of this particular coin type
        if "\(coin.getNumInstances().intValue)".localizedCaseInsensitiveContains(word) == true
        {
            return true
        }
        
        //country 
        if coin.getCountry().localizedCaseInsensitiveContains(word) == true
        {
            return true
        }
        
        //if everything failed up until this point 
        return false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text
        {
            filterContent(for: searchText)
            coinsTable.reloadData()
        }
    }
    
    // MARK: - Navigation
    @IBAction func returnToSpecificCoinCategory(segue: UIStoryboardSegue)
    {
        //this is an action in an unwind segue to get back to this view controller
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showSpecificCoinChecklist"
        {
            if let indexPath = coinsTable.indexPathForSelectedRow
            {
                let destinationController = segue.destination as! SpecificCoinChecklistViewController
                
                //set the appropriate data
                destinationController.specificCoin = (searchController.isActive) ? searchResults[indexPath.row] : theCategory.coinCategory?.getCoin(at: indexPath.row)
                
                destinationController.indexOfSelectedTableButton = (searchController.isActive) ? IndexPath(row:  theCategory.coinCategory!.getIndexOfCoinInCollection(coin: destinationController.specificCoin), section: 0) : indexPath
            }
        }
        
        else if segue.identifier == "presentCoinDataToShow"
        {
            if let indexPath = coinsTable.indexPathForSelectedRow
            {
                let destinationController = segue.destination as! EditCoinInformationViewController
                
                //set the appropriate data
                destinationController.coinToEdit = (searchController.isActive) ? searchResults[indexPath.row] : theCategory.coinCategory?.getCoin(at: indexPath.row)
                destinationController.setEditingState(newCanEdit: true)
            }
        }
        
        //regardless of the type of segue that we are performing, if the user has
        //activated a specific searchController, we want it to be turned off BEFORE we transition
        searchController.isActive = false
    }

}
