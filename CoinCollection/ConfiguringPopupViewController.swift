//
//  ConfiguringPopupViewController.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 7/13/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This class is responsible for controlling the popup view controller
//  that is presented modally on top of the CoinTableViewController for changing settings

import UIKit

////////////////////////////////////////////////////////

class ConfiguringPopupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var popupView: UIView!
    @IBOutlet var optionsTable : UITableView!
    @IBOutlet var popupTitleLabel : UILabel!
    
    var coinTableViewController : CoinTableViewController!
    
    var currentSortingCriteria : CoinCategory.CategoryTypes!
    var currentOrderCriteria : CoinCategory.CategorySortingOrder! 
    
    //titles of the sections in the optionsTable
    var sectionTitles = ["Sort Coins Into Categories By:","Sort Order"]
    
    //these are the names of the sections in the optionsTable.... will be displayed in the label of the cell
    var sectionContent = [
        [CoinCategory.CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue, CoinCategory.CategoryTypes.COUNTRY.rawValue,CoinCategory.CategoryTypes.CURRENCY.rawValue,CoinCategory.CategoryTypes.YEAR.rawValue],
        ["","Sorting the coins in either sorting orders means that the coins are sorted by the selected sorting criteria either alphabetically (from \"A\" to \"Z\" or from \"Z\" to \"A\") or by recency (such as year - from oldest to recent or from recent to oldest)."]
    ]
    
    //this is a handler to the segmented control that allows the user to choose either an ASCENDING or DESCENDING order of sort
    //the reason why we mantain a handler on this control is so that we do not lose access to the segmented control when the user is scrolling 
    //and the tableview cell that contains the segmented control is DEALLOCATED
    private var sortOrderSegmentedControl : UISegmentedControl? = nil
    
    //these are constants for the configuration of a label's text in the section headers
    private static let HORIZONTAL_CONSTRAINT_CONSTANT : CGFloat = 5
    private static let VERTICAL_CONSTRAINT_CONSTANT : CGFloat = 5
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //we make the optionsTable have rounded corners
        self.optionsTable.layer.cornerRadius = 5
        self.optionsTable.layer.masksToBounds = true
        
        //we underline the title of the popup menu
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: popupTitleLabel.text!)
        attributeString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
        self.popupTitleLabel.attributedText = attributeString
        
        //we move the popup view out of the window and we want it to appear by translating right into the window.
        //we want the popup view to enter into the viewcontroller
        //
        //The reason why we move the popupView to the left by its frame
        popupView.transform = CGAffineTransform.init(translationX: -popupView.frame.width - 700 , y: 0)
        
        //we hide the tab bar controller from the user so that it would not obstruct the view of the menu
        UIView.animate(withDuration: 0.4, animations: {
            self.presentingViewController?.tabBarController?.tabBar.alpha = 0
        })
        
        self.presentingViewController?.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        
        //////////////////////////////////////
        
        //we make each row resizable to fit the text entirely
        optionsTable.estimatedRowHeight = 70
        optionsTable.rowHeight = UITableViewAutomaticDimension
        optionsTable.tableFooterView = UIView()
        
        self.optionsTable.delegate = self
        self.optionsTable.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        //we animate the popup view transitioning into 
        //the screen from the left side..
        UIView.animate(withDuration: 0.2, animations: {
            self.popupView.transform = CGAffineTransform.identity
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if indexPath.section == 0
        {
            let theCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SettingsPopupCell
            
            theCell.typeTextLabel.text = sectionContent[indexPath.section][indexPath.row] as String
            //we by default set every cell as being unselected

            
            //we are in the section for the sorting of the categories... 
            //we are presenting the different options to the user for how they can sort the coins in their collection into categories
            if sectionContent[indexPath.section][indexPath.row] == self.currentSortingCriteria.rawValue
            {
                //the option for the sorting of the categories matches the current option that this collection is organized by
                theCell.select()
            }
            else
            {
                theCell.deselect()
            }
            
            return theCell
        }
            
        else
        {
            //we are in section 1
            if indexPath.row == 0
            {
                //first row is the OrderCell
                let theCell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! OrderSortCriteriaTableViewCell
                theCell.setCurrentSortingCriteria(newCriteria: self.currentOrderCriteria)
                self.sortOrderSegmentedControl = theCell.sortOptionsSegmentedControl
                self.sortOrderSegmentedControl?.addTarget(self, action: #selector(segmentSelected), for: .valueChanged)
                
                //we want this cell to react ONLY to the clicking of the segmented control in it, not the background
                theCell.selectionStyle = .none
            
                return theCell
            }
            else
            {
                //the rest of the rows in this section are the ExplanationCell
                let theCell = tableView.dequeueReusableCell(withIdentifier: "ExplanationCell")!
                theCell.textLabel?.text = sectionContent[indexPath.section][indexPath.row] as String
                
                return theCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //if the user selects a optionsTable's rows, then, he wants to select this particular row.
        //now if the user selected a particular row/cell, then it is his only choice in the category of options (i.e. sections)
        if indexPath.section == 0
        {
            let selectedCell = tableView.cellForRow(at: indexPath) as! SettingsPopupCell
            
            if selectedCell.currentButtonImage != SettingsPopupCell.SELECTED_BUTTON_IMAGE
            {
                //the user has previously NOT selected this cell, and he now clicked to select it
                
                
                //we reload the ALL rows in the section as not being selected as we are selecting one row at the expense of others
                
                //this acts like the index "i" when we are looping over the cells in the category
                var indexPathForCellsInThisSection : IndexPath = IndexPath(row: 0, section: indexPath.section)
                
                //this is going to act like a reference to each cell in the category 
                //when we are looping over the cells in the particular section to deselect it
                var theCell : SettingsPopupCell? = nil
                
                //we now loop over each cell in this section and we deselect it
                for row in 0..<optionsTable.numberOfRows(inSection: indexPath.section)
                {
                    indexPathForCellsInThisSection.row = row
                    theCell = tableView.cellForRow(at: indexPathForCellsInThisSection) as? SettingsPopupCell
                    
                    //we change the image of all cells in the category to being deselected
                    theCell?.deselect()
                }
                
                //we now set the image of the selected cell to the appropriate image
                selectedCell.select()
                self.currentSortingCriteria = CoinCategory.CategoryTypes.getTheCategoryFromString(str: selectedCell.typeTextLabel.text! as NSString)
                
                //after going through this process, we are sure that the user has selected ONLY ONE item in each category
            }
            
            
            optionsTable.deselectRow(at: indexPath, animated: false)
        }
        else if indexPath.section == 1
        {
            optionsTable.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.sectionContent[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        //we now create the label that we will put into the  returned view
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: heightForView(text: sectionTitles[section], font: UIFont.preferredFont(forTextStyle: .headline), width: tableView.frame.width)))
        
        label.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        label.textAlignment = .center
        label.text = sectionTitles[section]
        label.numberOfLines = 0
        label.textColor = .black
        label.backgroundColor = UIColor(hue: 0.8278, saturation: 0.41, brightness: 0.78, alpha: 1.0)
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        label.sizeToFit()
        
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return heightForView(text: sectionTitles[section], font: UIFont.preferredFont(forTextStyle: .headline), width: optionsTable.frame.width)
    }
    
    private func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    
    
    @IBAction func closePopup(_ sender : Any)
    {
        //we animate the popup view transitioning
        //out from the screen into the left side
        UIView.animate(withDuration: 0.2, animations:
            {
                self.popupView.transform = CGAffineTransform.init(translationX: -self.popupView.frame.width, y: 0)
        })
        
        //after the popupView left, we want to make
        //the tabbar controller visible
        UIView.animate(withDuration: 0.4, animations: {
            self.presentingViewController?.tabBarController?.tabBar.alpha = 1
        })
        
        //after we completely lose this popup view controller, we now make updates with the changes in information
        self.coinTableViewController.resortCoinsInNewCategories(newCategorySetting: self.currentSortingCriteria, newCategorySortingOrder: self.currentOrderCriteria)
        
        //we finished animating this viewcontroller and transfer control back to the original view controller that we presented
        dismiss(animated: true, completion: nil)
        
        //after we make the tab bar visible, we enable 
        //the user's interactions with it
        self.presentingViewController?.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    override var prefersStatusBarHidden: Bool
    {
        //we do not want any status bar information to be presented on this popup
        return true
    }
    
    func segmentSelected(sender : UISegmentedControl)
    {
        //we react to the user clicking the sender segmented control with the sorting order options
        self.currentOrderCriteria = CoinCategory.CategorySortingOrder.getSortingCriteria(theString: sender.titleForSegment(at: sender.selectedSegmentIndex)!)!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        //if the user taps outside the popupView, we can close this menu
        let touch = touches.first!
        
        if touch.view?.tag != 900    //the tag value for the containerView is 900
        {
            self.closePopup(self)
        }
    }
}
