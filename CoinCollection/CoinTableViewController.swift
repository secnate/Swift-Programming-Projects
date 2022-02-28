//
//  CoinTableViewController.swift
//  CoinCollection
//
//  Created by 1A Pavlovsky, N on 1/19/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  Controls the table view controller showing the general coins (one per each category)
import UIKit
import CoreData

//////////////////////////////////////////////////////////////////

class CoinTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UITabBarControllerDelegate
{

    @IBOutlet var navItem: UINavigationItem!
    
    //this is an array of all the coins in the collection
    //each row of this two-dimensional array represents a new category
    var coinsByCategory: [CoinCategoryMO] = []
    var fetchResultController: NSFetchedResultsController<CoinCategoryMO>!
    
    //we sort the coins by the category and then display them in the view controller
    //example includes [ [Iraq Dinar 1943, Iraq Dinar 1200], etc. etc.]
    
    //this label is supposed to let the user know that the collection is empty
    private var collectionEmptyLabel: UILabel!
    
    //we configure the searching across my controller
    //this is the controller that allows the user to search across the various categories of coins
    var searchController : UISearchController!
    var searchResults : [CoinCategoryMO] = []
    private var activeTextBeforeRotating: String? = nil
    ////////////////////////////////////////////////////////////////////////
    
    private var indexOfCoinTableViewControllerInTabController = -1
    
    ///////////////////////////////////////////////
    
    //the data here is used for resorting the coins into their respective categories
    
    //the default sorting criteria is sorting the coins into categories with the same country, value, and currency
    //and the user can change the app's sorting criteria by opening the ConfiguringPopoverViewController and changing the sorting criteria there
    private var isCurrentlyResortingCoinsIntoNewCategories : Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //////////////////////////////////////////////////////////////////////////////////
        
        self.tabBarController?.delegate = self
        
        //we now fetch the data
        let fetchRequest : NSFetchRequest<CoinCategoryMO> = CoinCategoryMO.fetchRequest()
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        {
            let context = appDelegate.persistentContainer.viewContext
            
            let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do
            {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects
                {
                    self.coinsByCategory = fetchedObjects
                }
            }
            catch
            {
                print(error)
            }
        }
        
        //////////////////////////////////////////////////////////////////////////////
        
        //if there is an empty area in the table view, instead of showing
        //empty cells, we show a blank area
        self.tableView.tableFooterView = UIView()
        
        //we configure the row heights for the table view so that the cells are resizable.
        //ALSO: should the user want to adjust the text size in "General"->"Accessibility"
        //the text size in the app will be automatically adjusted for him...
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //we remove the title of the back button as we want to see the back
        //back button in the navigation controller, not the title "Coin Categories"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //now there is a possibility that the coin collection is empty
        //this function will check the needd conditions and alert the user if there is an issue
        initCollectionEmptyLabel()
        
        //we create and configure the searchbar
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        //we want this search controller to dissappear when
        //we transition to the next view controller
        searchController.definesPresentationContext = true
        
        //we customize the search bar's appearance
        searchController.searchBar.placeholder = "Search Coin Categories..."
        searchController.searchBar.tintColor = self.navigationController?.navigationBar.tintColor
        searchController.searchBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        
        //we do not want the search controller to collapse the navigation bar
        //during the user searching across the various coin in the category
        searchController.hidesNavigationBarDuringPresentation = false
        
        //we remove the gray line that separated the
        //navigation bar and the search bar
        self.searchController.searchBar.layer.borderColor = self.navigationController?.navigationBar.barTintColor?.cgColor
        self.searchController.searchBar.layer.borderWidth = 1
        
        //if the user scrolls up, he sees a white background, not a grey one
        tableView.backgroundView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        //We present a walkthrough if this is the user's first time opening the app
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") == false
        {
            if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughController") as? WalkthroughPageViewController
            {
                present(pageViewController,animated: true, completion: nil)
            }
        }
        else
        {
            messageUserIfCollectionEmpty()
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
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
            
            for i in 0..<self.tableView.numberOfRows(inSection: 0)
            {
                tableView.cellForRow(at: IndexPath(item: i, section: 0))?.alpha = 0
            }
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation)
    {
        //this function is called after the user finished rotating the device.
        //Per the described sitaution in the "willRotateTo" function, we need to
        //re-activate the searchController and load the searchText...
        if self.searchController != nil && self.activeTextBeforeRotating != nil
        {
            for i in 0..<self.tableView.numberOfRows(inSection: 0)
            {
                tableView.cellForRow(at: IndexPath(item: i, section: 0))?.alpha = 1
            }
            
            self.searchController.isActive = true
            self.searchController.searchBar.text = self.activeTextBeforeRotating
            
            self.activeTextBeforeRotating = nil
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        //the user is changing tabs.
        //
        //if the searchcontroller in this viewcontroller is active, we need
        //to deactivate it to prevent it from appearing on the next screen
        //which will create a lot of graphical unpleasantness and error.
        //
        //YES, this means that the user's search text will be lost, even
        //if the user clicks on the "Categories" tab while the Coin Categories 
        //viewcontroller is up and running....
        if self.searchController != nil && self.searchController.isActive == true
        {
            self.searchController.isActive = false
        }
        
        //we deactivate the label that shows if the collection is
        //empty if it is already displayed, so that when the user 
        //returns to this screen
        self.activateCollectionEmptyLabel(newState: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchController != nil && searchController.isActive
        {
            return searchResults.count
        }
        else
        {
            if let sections = fetchResultController?.sections
            {
                return sections[section].numberOfObjects
            }
            else
            {
                return 0
            }

        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //configure the cell
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CoinTableViewCell
        
        //////////////////////////////////////////////////////////////////////////
        
        //Initialize the Cell
        let category = (searchController != nil && searchController.isActive) ? searchResults[indexPath.row] : coinsByCategory[indexPath.row]
        
        //we now remove the extra labels that we do not need
        cell.configureLabelsForCategoryType(theType: (category.coinCategory?.currentCategoryType)!)
        
        let sampleCoin : Coin = category.coinCategory!.getCoin(at: 0)!
        
        cell.countryLabel.text = "Country: \(sampleCoin.getCountry())"
        cell.valueAndDenominationLabel.text = "Value: \(sampleCoin.valueAndDenomination)"
        
        //now we add in the quantity
        cell.quantityLabel.text = "Number: \(String(describing: coinsByCategory[indexPath.row].coinCategory!.countNumberCoinsOverall))"
        
        //we now add in the denomination
        cell.denominationOnlyLabel.text = "Currency: \(sampleCoin.getDenomination())"
        
        //we now add in the year
        if sampleCoin.getYear() == nil
        {
            cell.yearLabel.text = "Year: " + (Coin.DEFAULT_YEAR as String)
        }
        else
        {
            let yearABS = abs(Int32(sampleCoin.getYear()!))
            cell.yearLabel.text = "Year: \(yearABS) \(sampleCoin.getYear()!.intValue > 0 ? TimePeriods.CE.rawValue : TimePeriods.BCE.rawValue)"
        }
        
        //we add in an accessory to indicate that clicking this cell will result in more information
        cell.accessoryType = .disclosureIndicator
        
        //////////////////////////////////////////////////////////////////////////
        return cell
    }
    
    override var prefersStatusBarHidden: Bool
    {
            return false
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if searchController != nil && searchController.isActive
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    //enable the swiping actions for each table row and the appropriate buttons
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        //if there is only one coin in the categroy, we can include a delete action
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive,
                                                title: "🗑\nDelete",
                                                handler: { (action, indexPath) -> Void in
                                                
                        self.askUserIfWantToDeleteCategoryAndDeleteIfYes(rowPath: indexPath)
                                                        
        })
        deleteAction.backgroundColor = UIColor.red
        
        
        
        //we google search for more information on this category of coins
        let searchAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "🔎\nSearch", handler: { (action, indexPath) -> Void in
        
            //we present the prepared viewcontroller
            let theVC = safariSearch(category:  self.coinsByCategory[indexPath.row].coinCategory!)
            theVC.modalPresentationStyle = .overFullScreen
            self.present(theVC, animated: true, completion: nil)
        
        })
        searchAction.backgroundColor = UIColor.blue
        
        return [deleteAction, searchAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //a cell has been selected - show the next viewcontroller with the coins from this category
        performSegue(withIdentifier: "showSpecificCoinDetail", sender: self)
    }
    
    func messageUserIfCollectionEmpty()
    {
        //this function is to be called when the coin collection is empty,
        //and the program gives a message to a user asking him if he wants to add a coin
        if coinsByCategory.count == 0
        {
            self.activateCollectionEmptyLabel(newState: false)
            
            let messageToUserAlert: UIAlertController = UIAlertController(title: "Coin Collection Is Empty",
                                                                          message: "Do you want to add a coin to the collection?",
                                                                          preferredStyle: UIAlertControllerStyle.alert)
            messageToUserAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            
                //we activate the coin collectionEmptyLabel for only one reason.
                //say we go to the NewCoinInfoVC and the user decides that he does not want
                //to add a coin and clicks the cancel button. the user then gets taken to the
                //CoinTableViewController and then, the user will not see the collectionEmptyLabel...
                //so thus, we activate this label just in case. if a coin is added, the label becomes hidden
                self.activateCollectionEmptyLabel(newState: true)
                
                //if the user clicked yes, then we take him to the NewCoinInfoVC and we go from there
                self.performSegue(withIdentifier: "presentNewCoinVC", sender: self)
            }))
            messageToUserAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {   (UIAlertAction) in
                
                //the user does not want to create a new coin... meaning that 
                //we are going to continue to have an empty collection.
                //we activate the collectionEmptyLabel to serve as a visual reminder
                //to the user that the collection is empty and also to
                //take up some of the empty space used up by the tableView in the viewcontroller
                self.activateCollectionEmptyLabel(newState: true)
            }))
            
            present(messageToUserAlert, animated: true, completion: nil)
        }
    }
    
    func askUserIfWantToDeleteCategoryAndDeleteIfYes(rowPath: IndexPath)
    {
        //This function is called when the user clicks the "Delete" action
        //when he/she swipes the cell to the right....
        //The parameter "rowPath" indicates the index path of the row that user has swiped to delete...
        
        let messageToUserAboutDeleting: UIAlertController = UIAlertController(title: "Confirmation Required",message: "Are you sure you want to delete this category and all the coins in it?", preferredStyle: .alert)
        
        messageToUserAboutDeleting.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (UIAlertAction) in
           
            self.deleteCoinCategory(rowPath: rowPath)
        }))
        
        messageToUserAboutDeleting.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        present(messageToUserAboutDeleting, animated: true, completion: nil)
    }
    
    func initCollectionEmptyLabel()
    {
        //this function initializes the label that is supposed to overlay the
        //table and tell the user if the collection is empty (instead of 
        //having white space in the area that is the table)
        self.collectionEmptyLabel = UILabel()
        self.collectionEmptyLabel.frame = CGRect(x: 0,
                                                 y: (self.view.frame.height/3)-(200/2),
                                                 width: self.view.frame.width, height: 200)
        self.collectionEmptyLabel.backgroundColor = UIColor.clear
        self.collectionEmptyLabel.textColor = UIColor.blue
        
        //we adjust the font size for the type of device that the user is using...
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.collectionEmptyLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        }
        else    //the app is running on an ipad...
        {
            self.collectionEmptyLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 40)
        }
        
        self.collectionEmptyLabel.textAlignment = NSTextAlignment.center
        self.collectionEmptyLabel.numberOfLines = 3
        self.collectionEmptyLabel.lineBreakMode = .byWordWrapping
        self.collectionEmptyLabel.textAlignment = .center
        self.collectionEmptyLabel.text = "The Collection is Empty.\nGet Started By Adding a New Coin!"
        
        //if the device is rotated, we want the label to resize accordingly in all directions
        self.collectionEmptyLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        
        //add it to the view...
        self.view.addSubview(self.collectionEmptyLabel)
        
        //when we initialize the label, we want to keep
        //it hidden from the user until we need to activate it...
        activateCollectionEmptyLabel(newState: false)
    }
    
    func activateCollectionEmptyLabel(newState: Bool)
    {
        //if we want the label to be activated, we make it visible, if not, invisible
        if newState == true && self.collectionEmptyLabel.alpha == 0
        {
            //the collection is empty and we have not displayed a label yet
            self.collectionEmptyLabel.alpha = 1
        }
        else if newState == false && self.collectionEmptyLabel.alpha == 1
        {
            //the collection is not empty and we have displayed a label
            self.collectionEmptyLabel.alpha = 0
        }
    }
 
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected category of coins to the new view controller.
        
        if segue.identifier == "showSpecificCoinDetail"         //we clicked on this category of coins and want to get more information about it
        {
            
            if tableView.indexPathForSelectedRow != nil
            {
                if let indexPath = tableView.indexPathForSelectedRow
                {
                    let destinationController = segue.destination as! CoinCategoryViewController
                
                    //we pass the coins in this category to the destination controller and the table for display
                    destinationController.theCategory = (searchController.isActive) ? searchResults[indexPath.row] : coinsByCategory[indexPath.row]
                
                    //we also pass into this the index of the selected coin category to be used at a later time
                    destinationController.indexPathOfSelectedCoinCategory = tableView.indexPathForSelectedRow
                }
            }
        }
        
        else if segue.identifier == "presentControlMenu"
        {
            let destinationController = segue.destination as! ConfiguringPopupViewController
            
            destinationController.currentSortingCriteria = CoinCategory.CategoryTypes.getTheCategoryFromString(str: UserDefaults.standard.object(forKey: "currentSortingCriteria") as! NSString)
            
            destinationController.currentOrderCriteria = CoinCategory.CategorySortingOrder.getSortingCriteria(theString: (UserDefaults.standard.object(forKey: "currentSortingOrder") as! NSString) as String)
            
            destinationController.coinTableViewController = self
        }
        
        
        //we do not want this search controller to
        //persist when we go to the next screen, regardless of what segue we perform
        searchController.isActive = false
    }
    
    @IBAction func unwindToCoinTableVC(segue: UIStoryboardSegue)
    {
        //we go from a client viewcontroller to the CoinTableViewController (this View Controller)
    }
        
    func deleteCoinCategory(rowPath: IndexPath)
    {
        if 0 <= rowPath.row && rowPath.row < self.coinsByCategory.count
        {
            //we have just tested that the rowPath index is valid
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
            {
                let context = appDelegate.persistentContainer.viewContext
                let coinCategoryToDelete = self.fetchResultController.object(at: rowPath)
                context.delete(coinCategoryToDelete)
                
                appDelegate.saveContext()
                
                //ok we now deleted the category, now we update the indices
                updateIndices()
                appDelegate.saveContext()
            }
        }
    }
    
    func deleteCoin(c: Coin, indexOfSelectedCategory: IndexPath) -> Bool
    {
        //we have a coin that we want to delete from this viewcontroller
        //and the data contained in it.
        //
        //the parameter indexOfSelectedCategory refers to the IndexPath of the
        //row in the TableView contained in THIS viewcontroller whose category
        //of coins we are modifying in this method
        //
        //Return value: a boolean that indicates whether a single coin has
        //been deleted - meaning that the user should return to the parentviewcontroller
        if 0 < indexOfSelectedCategory.row && indexOfSelectedCategory.row < self.coinsByCategory.count && self.coinsByCategory[indexOfSelectedCategory.row].coinCategory?.hasCoin(c: c) == true
        {
            //the index is valid as it refers to a category in the coinsByCategory array
            //and the examined category has the coin in question
            if self.coinsByCategory[indexOfSelectedCategory.row].coinCategory?.countNumberOfTypes == 1
            {
                //the coin "c" that we are going to delete is the only coin in the entire category
                //we reduce the problem to a simpler one that has been already solved (thanks mathematicians!)
                self.deleteCoinCategory(rowPath: indexOfSelectedCategory)
                
                return true
            }
            else
            {
                //there is more than one coin in the category
                self.coinsByCategory[indexOfSelectedCategory.row].coinCategory?.removeCoin(c: c)
                
                //we save the changes in the database...
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
                {
                    appDelegate.saveContext()
                }
                
                return false
            }
        }
        
        return false
    }
    
    func addCoin(coinToAdd: Coin)
    {
        //we add coins by the currentCategoryType and the currentSortingOrder [ascending or descending] into the collection
        //we check over each category to see if the coin can be added
        var addedToExistingCategory: Bool = false
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            for i in 0..<self.coinsByCategory.count
            {
                if self.coinsByCategory[i].coinCategory?.coinFitsCategory(aCoin: coinToAdd) == true
                {
                    //first we check if there is an existing coin that matches the coin that we are going to add on ALL PARAMETERS.
                    //if that happens, then we change the quantity of the existing coin
                    for coin in self.coinsByCategory[i].coinCategory!.coinsInCategory
                    {
                        if coin.isIdenticalCoin(rhs: coinToAdd)
                        {
                            coin.incrementNumInstances()
                            addedToExistingCategory = true
                            break
                        }
                    }
                    
                    //if we were not able to find an existing coin that the coinToAdd could fit
                    //we can add the coin to the category
                    self.coinsByCategory[i].coinCategory = CoinCategory(coins: self.coinsByCategory[i].coinCategory!.coinsInCategory+[coinToAdd], categoryType: coinsByCategory[i].coinCategory!.currentCategoryType)
                    addedToExistingCategory = true
                    break
                }
            }
        
            if addedToExistingCategory == false
            {
                //since the coinToAdd does not fall in the existing categories, we create a new one
                let newCategory = CoinCategoryMO(context: appDelegate.persistentContainer.viewContext)
            
                newCategory.coinCategory = CoinCategory(coins: [coinToAdd], categoryType: CoinCategory.CategoryTypes.getTheCategoryFromString(str: UserDefaults.standard.object(forKey: "currentSortingCriteria") as! NSString).rawValue)
                
                //we choose the index so that we insert this new category in order into the tableviewcontroller per the sorting orders and categories
                let currentCategoryType = CoinCategory.CategoryTypes.getTheCategoryFromString(str: UserDefaults.standard.object(forKey: "currentSortingCriteria") as! NSString)
                let currentOrderType = CoinCategory.CategorySortingOrder.getSortingCriteria(theString: UserDefaults.standard.object(forKey: "currentSortingOrder") as! String)!
                
                //we now configure the index of the new category that we are adding so that we are adding the new category in the appropriate order
                switch currentCategoryType
                {
                case .COUNTRY_VALUE_AND_CURRENCY:
                    if currentOrderType == CoinCategory.CategorySortingOrder.ASCENDING
                    {
                        let countryOfNewCategory = newCategory.coinCategory?.coinsInCategory[0].getCountry()
                        
                        var arrayOfCountries = coinsByCategory.map({
                            String(describing: $0.coinCategory!.coinsInCategory[0].getCountry())})
                        var insertIndex = arrayOfCountries.count > 0 ? arrayOfCountries.count : 1  //by default, it is the index of the space following the last one
                        
                        for i in 0..<arrayOfCountries.count
                        {
                            if countryOfNewCategory?.localizedCaseInsensitiveCompare(arrayOfCountries[i]) == ComparisonResult.orderedAscending
                            {
                                //we save the index and move on with the saving
                                insertIndex = i
                                break
                            }
                        }
                        
                        //after we finish this, we save the index
                        newCategory.index = Int16(insertIndex)
                    }
                    else
                    {
                        //currentOrderType == CoinCategory.CategorySortingOrder.DESCENDING
                        let countryOfNewCategory = newCategory.coinCategory?.coinsInCategory[0].getCountry()
                        
                        var arrayOfCountries = coinsByCategory.map({
                            String(describing: $0.coinCategory!.coinsInCategory[0].getCountry())})
                        var insertIndex = arrayOfCountries.count > 0 ? arrayOfCountries.count : 1  //by default, it is the index of the space following the last one
                        
                        for i in 0..<arrayOfCountries.count
                        {
                            if countryOfNewCategory?.localizedCaseInsensitiveCompare(arrayOfCountries[i]) == ComparisonResult.orderedDescending
                            {
                                //we save the index and move on with the saving
                                insertIndex = i
                                break
                            }
                        }
                        
                        //after we finish this, we save the index
                        newCategory.index = Int16(insertIndex)
                    }

                    
                case .CURRENCY:
                    if currentOrderType == CoinCategory.CategorySortingOrder.ASCENDING
                    {
                        let countryOfNewCategory = newCategory.coinCategory?.coinsInCategory[0].getCountry()
                        
                        var arrayOfCountries = coinsByCategory.map({
                            String(describing: $0.coinCategory!.coinsInCategory[0].getCountry())})
                        var insertIndex = arrayOfCountries.count > 0 ? arrayOfCountries.count : 1  //by default, it is the index of the space following the last one
                        
                        for i in 0..<arrayOfCountries.count
                        {
                            if countryOfNewCategory?.localizedCaseInsensitiveCompare(arrayOfCountries[i]) == ComparisonResult.orderedAscending
                            {
                                //we save the index and move on with the saving
                                insertIndex = i
                                break
                            }
                        }
                        
                        //after we finish this, we save the index
                        newCategory.index = Int16(insertIndex)
                    }
                    else
                    {
                        //currentOrderType == CoinCategory.CategorySortingOrder.DESCENDING
                        let countryOfNewCategory = newCategory.coinCategory?.coinsInCategory[0].getCountry()
                        
                        var arrayOfCountries = coinsByCategory.map({
                            String(describing: $0.coinCategory!.coinsInCategory[0].getCountry())})
                        var insertIndex = arrayOfCountries.count > 0 ? arrayOfCountries.count : 1  //by default, it is the index of the space following the last one
                        
                        for i in 0..<arrayOfCountries.count
                        {
                            if countryOfNewCategory?.localizedCaseInsensitiveCompare(arrayOfCountries[i]) == ComparisonResult.orderedDescending
                            {
                                //we save the index and move on with the saving
                                insertIndex = i
                                break
                            }
                        }
                        
                        //after we finish this, we save the index
                        newCategory.index = Int16(insertIndex)
                    }

                    
                case .COUNTRY:
                    if currentOrderType == CoinCategory.CategorySortingOrder.ASCENDING
                    {
                        let countryOfNewCategory = newCategory.coinCategory?.coinsInCategory[0].getCountry()
                        
                        var arrayOfCountries = coinsByCategory.map({
                            String(describing: $0.coinCategory!.coinsInCategory[0].getCountry())})
                        var insertIndex = arrayOfCountries.count > 0 ? arrayOfCountries.count : 1  //by default, it is the index of the space following the last one
                        
                        for i in 0..<arrayOfCountries.count
                        {
                            if countryOfNewCategory?.localizedCaseInsensitiveCompare(arrayOfCountries[i]) == ComparisonResult.orderedAscending
                            {
                                //we save the index and move on with the saving
                                insertIndex = i
                                break
                            }
                        }
                        
                        //after we finish this, we save the index
                        newCategory.index = Int16(insertIndex)
                    }
                    else
                    {
                        //currentOrderType == CoinCategory.CategorySortingOrder.DESCENDING
                        let countryOfNewCategory = newCategory.coinCategory?.coinsInCategory[0].getCountry()
                        
                        var arrayOfCountries = coinsByCategory.map({
                            String(describing: $0.coinCategory!.coinsInCategory[0].getCountry())})
                        var insertIndex = arrayOfCountries.count > 0 ? arrayOfCountries.count : 1  //by default, it is the index of the space following the last one
                        
                        for i in 0..<arrayOfCountries.count
                        {
                            if countryOfNewCategory?.localizedCaseInsensitiveCompare(arrayOfCountries[i]) == ComparisonResult.orderedDescending
                            {
                                //we save the index and move on with the saving
                                insertIndex = i
                                break
                            }
                        }
                        
                        //after we finish this, we save the index
                        newCategory.index = Int16(insertIndex)
                    }
                    
                case .YEAR:
                    if currentOrderType == CoinCategory.CategorySortingOrder.ASCENDING
                    {
                        let yearOfNewCategory = (newCategory.coinCategory!.coinsInCategory[0].getYear() != nil) ? newCategory.coinCategory!.coinsInCategory[0].getYear()! : 0
                        
                        var arrayOfYears = coinsByCategory.map({
                                $0.coinCategory!.coinsInCategory[0].getYear() != nil ? $0.coinCategory!.coinsInCategory[0].getYear()! : 0
                            })
                        
                        var insertIndex = arrayOfYears.count > 0 ? arrayOfYears.count : 1  //by default, it is the index of the space following the last one
                        
                        for i in 0..<arrayOfYears.count
                        {
                            if yearOfNewCategory.intValue < arrayOfYears[i].intValue
                            {
                                //we save the index and move on with the saving
                                insertIndex = i
                                break
                            }
                        }
                        
                        //after we finish this, we save the index
                        newCategory.index = Int16(insertIndex)

                    }
                    else
                    {
                        let yearOfNewCategory = (newCategory.coinCategory!.coinsInCategory[0].getYear() != nil) ? newCategory.coinCategory!.coinsInCategory[0].getYear()! : 0
                        
                        var arrayOfYears = coinsByCategory.map({
                            $0.coinCategory!.coinsInCategory[0].getYear() != nil ? $0.coinCategory!.coinsInCategory[0].getYear()! : 0
                        })
                        
                        var insertIndex = arrayOfYears.count > 0 ? arrayOfYears.count : 1  //by default, it is the index of the space following the last one
                        
                        for i in 0..<arrayOfYears.count
                        {
                            if yearOfNewCategory.intValue > arrayOfYears[i].intValue
                            {
                                //we save the index and move on with the saving
                                insertIndex = i
                                break
                            }
                        }
                        
                        //after we finish this, we save the index
                        newCategory.index = Int16(insertIndex)
                    }
                    
                default:
                    //we have an issue with the current category type
                    //we act in the default way and we add the category to the very top of the view controller
                    newCategory.index = 0
                }
            }
            
            appDelegate.saveContext()
            
            //now since we have added the coin, we now updated the indices of each CoinCategoryMO object
            updateIndices()
        }
    }
    
    func coinFitsExistingCategory(coin: Coin) -> Bool
    {
        //this function checks if the coin can be added to the existing categories
        for i in 0..<self.coinsByCategory.count
        {
            if self.coinsByCategory[i].coinCategory?.coinFitsCategory(aCoin: coin) == true
            {
                //we can add the coin to the category
                return true
            }
        }
        
        return false
    }
    
    func resortCoinsInNewCategories(newCategorySetting : CoinCategory.CategoryTypes?, newCategorySortingOrder : CoinCategory.CategorySortingOrder?)
    {
        //we want to resort all the coins in the category by new sorting criteria
        if newCategorySetting != nil && newCategorySortingOrder != nil
        {
            //we need to eliminate a couple possiblities where we do not need to do anything...
            
            //if we have exactly the same settings for both the category and sorting order as before, we do not do anything
            if newCategorySetting! == CoinCategory.CategoryTypes.getTheCategoryFromString(str: UserDefaults.standard.object(forKey: "currentSortingCriteria") as! NSString) && newCategorySortingOrder! == CoinCategory.CategorySortingOrder.getSortingCriteria(theString: UserDefaults.standard.object(forKey: "currentSortingOrder") as! String)
            {
                //nothing changed
                return
            }
                
            //We have a valid CoinCategory.CategoryTypes sorting criteria that is different from the one currently used.
            //We resort the coins in the collection by the new category
            UserDefaults.standard.setValue(newCategorySetting!.rawValue, forKey: "currentSortingCriteria")
            
            //we have a sorting newCategorySortingOrder that is either in ascending or descending order
            UserDefaults.standard.setValue(newCategorySortingOrder!.rawValue, forKey: "currentSortingOrder")
            
            if self.coinsByCategory.count != 0
            {
                //we actually have some coins to resort... let's get to work!
                self.isCurrentlyResortingCoinsIntoNewCategories = true
            
                //we first get an array of all the coins in existing categories
                var allCoinsArray : [Coin] = []
            
                for i in 0..<self.coinsByCategory.count
                {
                    allCoinsArray += self.coinsByCategory[i].coinCategory!.coinsInCategory
                }
            
                //now we need to delete all the categories in existence...
                let firstCategoryIndexPath = IndexPath(row: 0, section: 0)
                let numberOfCategoriesToDelete = self.coinsByCategory.count
            
                for _ in 0..<numberOfCategoriesToDelete
                {
                    self.deleteCoinCategory(rowPath: firstCategoryIndexPath)
                }
            
                //OK... now that we have deleted all old categories... it is time to start to create new ones...
                for i in 0..<allCoinsArray.count
                {
                    //AND we add the coin to the array!
                    //this function also automatically updates the indices, so it is not an issue there
                    self.addCoin(coinToAdd: allCoinsArray[i])
                }
            
                //we are done resorting
                self.isCurrentlyResortingCoinsIntoNewCategories = false
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////
    
    private func updateIndices()
    {
        //this function updates the "index" property so that
        //each CoinCategoryMO object in the coinsByCategory array
        //has an index corresponding to its position.
        //After this function is called, we must save the core data in the AppDelegate.
        //
        //This function is called ONLY after the changes to the CoinCategoryMO objects
        //are saved in core data and the self.coinsByCategory array is updated to have
        //the latest version of the data
        for i in 0..<self.coinsByCategory.count
        {
            //the only reason why we create an entirely new CoinCategory object
            //is that the creation of an entirely new CoinCategory object
            //is the only way that the appDelegate will save the information
            self.coinsByCategory[i].index = Int16(i)
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate
        {
            appDelegate.saveContext()
        }
    }
    
    //these delegate methods controll the core data database
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type
        {
        case .insert :
            if let newIndexPath = newIndexPath
            {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            
        case .delete:
            if let indexPath = indexPath
            {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
                
        case .update:
            if let indexPath = indexPath
            {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
            
        default:
            tableView.reloadData()
        }
        
        if let fetchedObjects = controller.fetchedObjects
        {
            self.coinsByCategory = fetchedObjects as! [CoinCategoryMO]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
        
        if self.isCurrentlyResortingCoinsIntoNewCategories != true
        {
            //we let the user know if the collection is empty
            if self.coinsByCategory.count == 0
            {
                self.messageUserIfCollectionEmpty()
            }
            else
            {
                self.activateCollectionEmptyLabel(newState: false)
            }
        }
    }
    
    // MARK - We configure the search bar searching
    
    func updateSearchResults(for searchController : UISearchController)
    {
        if let searchText = searchController.searchBar.text
        {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
    
    func filterContent(for searchText: String)
    {
        searchResults = coinsByCategory.filter( { (category) -> Bool in
            
            //we get a sample coin to evaulate the coin category
            //we assume that it is representative of all coins in the category
            
            //ok, now we need to consider the different types of categories
            
            for word in searchText.components(separatedBy: " ")
            {
                if wordFitsCategory(word: word,category: category) == true
                {
                    return true
                }
            }
            
            return false
        })
    }
    
    private func wordFitsCategory(word: String, category: CoinCategoryMO) -> Bool
    {
        //we have a word that is part of the searchText in the filterContent
        //method and we want to make sure that the word DOES fit into the
        //category accurately
        
        let sampleCoin : Coin = category.coinCategory!.getCoin(at: 0)!
        
        //we look at how the word fits into each specific type of coin category
        switch (category.coinCategory!.currentCategoryType)
        {
        case CoinCategory.CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue:
            
            //we match a coin into this category based on the country, its value, and currency
            let country = sampleCoin.getCountry() as String
            if country.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
            
            if sampleCoin.getValue().intValue > 0
            {
                //we have a valid value for the coin that is non-negative
                let value : String = "\(sampleCoin.getValue())"
                
                if value.localizedCaseInsensitiveContains(word) == true
                {
                    return true
                }
                
                //we can also check if the user has sorted by "CE" or "BCE"
                if sampleCoin.getYear() != nil
                {
                    if sampleCoin.getYear()!.intValue > 0 && "CE".localizedCaseInsensitiveContains(word) == true
                    {
                        return true
                    }
                
                    if sampleCoin.getYear()!.intValue < 0 && "BCE".localizedCaseInsensitiveContains(word) == true
                    {
                        return true
                    }
                }
            }
            else
            {
                if Coin.DEFAULT_VALUE_STRING.localizedCaseInsensitiveContains(word) == true
                {
                    return true
                }
            }
            
            
            let currency = sampleCoin.getDenomination()
            if currency.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
            
        case CoinCategory.CategoryTypes.COUNTRY.rawValue:
            
            //we check if the coin fits into the category if it has the same country
            let country = sampleCoin.getCountry() as String
            
            if country.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
            
        case CoinCategory.CategoryTypes.YEAR.rawValue:
            if sampleCoin.getYear() != nil
            {
                if sampleCoin.getYear() != nil
                {
                    let year = String(Int(sampleCoin.getYear()!))
                    if year.localizedCaseInsensitiveContains(word) == true
                    {
                        return true
                    }
                    
                    //we can also check if the user has sorted by "CE" or "BCE"
                    if sampleCoin.getYear()!.intValue > 0 && "CE".localizedCaseInsensitiveContains(word) == true
                    {
                        return true
                    }
                    
                    if sampleCoin.getYear()!.intValue < 0 && "BCE".localizedCaseInsensitiveContains(word) == true
                    {
                        return true
                    }
                }
            }
            
        case CoinCategory.CategoryTypes.CURRENCY.rawValue:
            let denomination = sampleCoin.getDenomination() as String
            
            if denomination.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }
            
            let country = sampleCoin.getCountry() as String
            
            if country.localizedCaseInsensitiveContains(word) == true
            {
                return true
            }

            
        default:
            ()
        }
        
        //we also consider the quantity, as the user could be searching by the number of coins
        if "\(String(describing: category.coinCategory!.countNumberCoinsOverall))".localizedCaseInsensitiveContains(word)
        {
            return true
        }
        else
        {
            return false
        }
    }
}


