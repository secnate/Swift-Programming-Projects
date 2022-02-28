//
//  OrderSortCriteriaTableViewCell.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 7/21/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This class is responsible for running the OrderSortCriteriaTableView cell which tells the user in what order he is going to sort the coins

import UIKit

class OrderSortCriteriaTableViewCell: UITableViewCell
{

    @IBOutlet var sortOptionsSegmentedControl : UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sortOptionsSegmentedControl.setTitle(CoinCategory.CategorySortingOrder.ASCENDING.rawValue, forSegmentAt: 0)
        sortOptionsSegmentedControl.setTitle(CoinCategory.CategorySortingOrder.DESCENDING.rawValue, forSegmentAt: 1)
        self.sortOptionsSegmentedControl.isEnabled = false
    }

    func setCurrentSortingCriteria(newCriteria : CoinCategory.CategorySortingOrder)
    {
        
        if newCriteria == CoinCategory.CategorySortingOrder.ASCENDING
        {
            sortOptionsSegmentedControl.selectedSegmentIndex = 0
        }
        else if newCriteria == CoinCategory.CategorySortingOrder.DESCENDING
        {
            sortOptionsSegmentedControl.selectedSegmentIndex = 1
        }
        
        self.sortOptionsSegmentedControl.isEnabled = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
