//
//  SpecificCoinCell.swift
//  CoinCollection
//
//  Created by 1A Pavlovsky, N on 2/21/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This class represents a single cell in the tableview of the CoinDetailsViewController.swift file
//  It shows all of the given information for the coin

import UIKit

class SpecificCoinCell: UITableViewCell {
    
    @IBOutlet var valueAndDenominationLabel : UILabel!
    @IBOutlet var countryLabel : UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var mintLabel: UILabel!
    @IBOutlet var instancesLabel: UILabel!
    @IBOutlet var gradeLabel: UILabel!
    @IBOutlet var denominationLabel : UILabel!

    private static let COLOR_OF_ALL_LABELS_EXCEPT_FOR_TOP = UIColor.darkGray
    private static let COLOR_OF_TOP_LABEL = UIColor.black
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the cell for the selected state
    }
    
    func restoreAllLabelsToCell()
    {
        //we restore all the labels to the cell, and it is used
        //to 'reset' the text labels in a reusable tableview cell
        //as in a previous usage some labels could have been removed
        gradeLabel.isHidden = false
        instancesLabel.isHidden = false
        mintLabel.isHidden = false
        yearLabel.isHidden = false
        countryLabel.isHidden = false
        valueAndDenominationLabel.isHidden = false
        denominationLabel.isHidden = false
    }
    
    func hideLabels(categoryType : CoinCategory.CategoryTypes.RawValue)
    {
        //we hide certain labels from the cell based on what category the coin that this cell represents belongs to and what sorting criteria it has.
        
        //typically we remove the labels that correspond to the general category information
        switch categoryType
        {
        case CoinCategory.CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue:
            countryLabel.isHidden = true
            valueAndDenominationLabel.isHidden = true
            denominationLabel.isHidden = true
            
        case CoinCategory.CategoryTypes.COUNTRY.rawValue:
            countryLabel.isHidden = true
            denominationLabel.isHidden = true
            
        case CoinCategory.CategoryTypes.CURRENCY.rawValue:
            countryLabel.isHidden = true
            denominationLabel.isHidden = true
            
        case CoinCategory.CategoryTypes.YEAR.rawValue:
            yearLabel.isHidden = true
            denominationLabel.isHidden = true
            
        default:
            ()  //nothing
        }
    }
    
    func setLabelsColor(categoryType : CoinCategory.CategoryTypes.RawValue)
    {
        //we assume that this 'cell' is "dirty" and thus that we need to force a manual restart of the labels colors
        valueAndDenominationLabel.textColor = SpecificCoinCell.COLOR_OF_ALL_LABELS_EXCEPT_FOR_TOP
        yearLabel.textColor = SpecificCoinCell.COLOR_OF_ALL_LABELS_EXCEPT_FOR_TOP
        mintLabel.textColor = SpecificCoinCell.COLOR_OF_ALL_LABELS_EXCEPT_FOR_TOP
        instancesLabel.textColor = SpecificCoinCell.COLOR_OF_ALL_LABELS_EXCEPT_FOR_TOP
        gradeLabel.textColor = SpecificCoinCell.COLOR_OF_ALL_LABELS_EXCEPT_FOR_TOP
        denominationLabel.textColor = SpecificCoinCell.COLOR_OF_ALL_LABELS_EXCEPT_FOR_TOP
        
        //then depending on what category type this cell is sorted into, we change the top label of this cell to a black color
        switch categoryType
        {
        case CoinCategory.CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue:
            yearLabel.textColor = SpecificCoinCell.COLOR_OF_TOP_LABEL
            
        case CoinCategory.CategoryTypes.COUNTRY.rawValue:
            valueAndDenominationLabel.textColor = SpecificCoinCell.COLOR_OF_TOP_LABEL
            
        case CoinCategory.CategoryTypes.CURRENCY.rawValue:
            valueAndDenominationLabel.textColor = SpecificCoinCell.COLOR_OF_TOP_LABEL
            
        case CoinCategory.CategoryTypes.YEAR.rawValue:
            valueAndDenominationLabel.textColor = SpecificCoinCell.COLOR_OF_TOP_LABEL
            
        default:
            ()  //we do ABSOLUTELY NOTHING
        }

        
    }
    
    func configureCell(currentCoin : Coin, categoryType : CoinCategory.CategoryTypes.RawValue)
    {
        //now configure the cell by loading the information and removing the labels that are not needed for the current category sorting criteria.
        //we assume that the currentCoin is representative of all the coins in this category on the sorting criteria
        
        //we assume that this cell that is being reused is 'dirty' with some labels already removed
        self.restoreAllLabelsToCell()
        self.hideLabels(categoryType: categoryType)
        
        //we configur their color
        setLabelsColor(categoryType: categoryType)
        
        //we set up the cell's year
        if currentCoin.getYear() == nil
        {
            //this coin does not have a valid year... we set defualt year label
            self.yearLabel.text = "Year: " + (Coin.DEFAULT_YEAR as String)
        }
        else
        {
            // we have a non-nil year
            // because the year can be negative, representing the BCE period, we must check appropriately
            // if positive, we have the CE period
            if Int(currentCoin.getYear()!) < 0
            {
                //coin is BCE period
                self.yearLabel.text = "Year: \(abs(Int(currentCoin.getYear()!))) BCE"  //EX: -50 represents 50 BCE
            }
            else
            {
                //coin is CE period
                self.yearLabel.text = "Year: \(Int(currentCoin.getYear()!)) CE"
            }
        }
        
        //if we do have a specific mint, then we add the "Mint:" qualifier before we display the information
        if (currentCoin.getMint() != Coin.DEFAULT_MINT)
        {
            self.mintLabel.text = "Mint: " + (currentCoin.getMint() as String)
        }
        else
        {
            self.mintLabel.text = "Mint: " + (Coin.DEFAULT_MINT as String)
        }
        
        self.instancesLabel.text = "Num.: \(Int(currentCoin.getNumInstances()))"
        
        if currentCoin.getGrade() == nil
        {
            // we do not have a valid grade....
            self.gradeLabel.text = "Grade: " + (Coin.NOT_AVAILABLE as String)
        }
        else
        {
            self.gradeLabel.text = "Grade: \(currentCoin.getGrade()!)"
        }
        
        self.valueAndDenominationLabel.text = "Value: " + (currentCoin.valueAndDenomination as String)
        
        self.countryLabel.text = "Country: " + (currentCoin.getCountry() as String)
        
        self.denominationLabel.text = "Denom.: " + (currentCoin.getDenomination() as String)
    }

}
