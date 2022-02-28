//
//  CoinTableViewCell.swift
//  CoinCollection
//
//  Created by 1A Pavlovsky, N on 1/19/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  Represents a cell of the coin buttons

import UIKit

class CoinTableViewCell: UITableViewCell {

    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var valueAndDenominationLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var denominationOnlyLabel : UILabel!
    @IBOutlet var yearLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func restoreAllLabelsToCell()
    {
        //this is a function that is called when this cell is being initialized in the cellForRowAt method in a tableview..
        //we want to make all the labels visible so that the previous usage of a reusable tableview cell does not affect this usage of the cell
        countryLabel.isHidden = false
        valueAndDenominationLabel.isHidden = false
        quantityLabel.isHidden = false
        denominationOnlyLabel.isHidden = false
        yearLabel.isHidden = false
    }

    func configureLabelsForCategoryType(theType : NSString)
    {
        //in this function, we remove all the extra labels
        //that contain information that does not relate to the general type of the category from the stack view
        //For example, the year label is removed when the category is a country, as a year does not determine what category a coin falls into.
        
        //we restore all the labels in this cell as we do not want the reusable cell's past usage
        //which may have lead to a label dissappearing to carry over into this new usage of the cell
        self.restoreAllLabelsToCell()
        
        //we hide the unecessary labels
        switch theType
        {
        case CoinCategory.CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue:
            //we do not need information about the coin's denomination (without its value) or the year
            denominationOnlyLabel.isHidden = true
            yearLabel.isHidden = true
            
            //after we remove the labels, we now make the first label bold and black
            valueAndDenominationLabel.font = UIFont.boldSystemFont(ofSize: self.valueAndDenominationLabel.font.pointSize)
            valueAndDenominationLabel.textColor = UIColor.black
            
        case CoinCategory.CategoryTypes.COUNTRY.rawValue:
            //we do not need the information about the coin's value and denominations nor year
            valueAndDenominationLabel.isHidden = true
            denominationOnlyLabel.isHidden = true
            yearLabel.isHidden = true
            
            //after we remove the labels, we make the first label bold and black
            countryLabel.font = UIFont.boldSystemFont(ofSize: self.countryLabel.font.pointSize)
            countryLabel.textColor = UIColor.black
            
        case CoinCategory.CategoryTypes.CURRENCY.rawValue:
            //we do not information about the coin's value & denomination (together, that is), or year
            valueAndDenominationLabel.isHidden = true
            yearLabel.isHidden = true
            
            //after we remove the labels, we make the first label bold and black
            denominationOnlyLabel.font = UIFont.boldSystemFont(ofSize: self.denominationOnlyLabel.font.pointSize)
            denominationOnlyLabel.textColor = UIColor.black
            
        case CoinCategory.CategoryTypes.YEAR.rawValue:
            //we do not information about the coin's value, denomination, or country
            valueAndDenominationLabel.isHidden = true
            denominationOnlyLabel.isHidden = true
            countryLabel.isHidden = true
            
            //after we remove the labels, we make the first label bold and black
            yearLabel.font = UIFont.boldSystemFont(ofSize: self.yearLabel.font.pointSize)
            yearLabel.textColor = UIColor.black
            
        default:
            //the string does not match any of the categories available
            //we do not remove any labels
            break
        }
    }

}
