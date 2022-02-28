//
//  CoinCategory.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 6/22/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This class is supposed to represent a category of coin objects in CoreData

import Foundation
import CoreData


public class CoinCategory: NSObject, NSCoding
{
    static func swapValuesWithAnotherCategory(categoryOne: CoinCategory,categoryTwo: CoinCategory)
    {
        swap(&categoryOne.currentCategoryType, &categoryTwo.currentCategoryType)
        swap(&categoryOne.coinsInCategory,&categoryTwo.coinsInCategory)
    }
    
    //These are the various types of categories that a user can create out of their coin collection
    enum CategoryTypes : NSString
    {
        case COUNTRY_VALUE_AND_CURRENCY = "Country & Value"
        case COUNTRY = "Country"
        case YEAR = "Year"
        case CURRENCY = "Country & Currency"
        case NO_CATEGORY = "No Category"
        
        static func getTheCategoryFromString(str : NSString) -> CategoryTypes
        {
            if CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue.isEqual(to: str as String)
            {
                return CategoryTypes.COUNTRY_VALUE_AND_CURRENCY
            }
            
            else if CategoryTypes.COUNTRY.rawValue.isEqual(to: str as String)
            {
                return CategoryTypes.COUNTRY
            }
            
            else if CategoryTypes.YEAR.rawValue.isEqual(to: str as String)
            {
                return CategoryTypes.YEAR
            }
            
            else if CategoryTypes.CURRENCY.rawValue.isEqual(to: str as String)
            {
                return CategoryTypes.CURRENCY
            }
            else
            {
                return CategoryTypes.NO_CATEGORY
            }
        }
    }
    
    enum CategorySortingOrder : String
    {
        case ASCENDING = "Ascending"
        case DESCENDING = "Descending"
        
        static func getSortingCriteria(theString : String) -> CategorySortingOrder?
        {
            if theString == CoinCategory.CategorySortingOrder.ASCENDING.rawValue
            {
                return .ASCENDING
            }
            
            else if theString == CoinCategory.CategorySortingOrder.DESCENDING.rawValue
            {
                return .DESCENDING
            }
            
            else
            {
                return nil
            }
        }
    }
    
    //this struct is used to encode the data in Key-Value pairs per the NSCoding protocol
    struct Keys
    {
        static let Current_Category_Type = "current_category_type"
        static let Coins_In_Category = "coins_in_category"
    }
    
    //this is the collection of the coins in the category
    var coinsInCategory: [Coin] = []            //initially we have no coins in the collection
    var currentCategoryType : CategoryTypes.RawValue = ""
    
    public var countNumberOfTypes : NSNumber
    {
        //this is the number of different coin types in the category
        get
        {
            return coinsInCategory.count as NSNumber
        }
    }
    
    public var countNumberCoinsOverall : Int
    {
        get
        {
            var counter : Int = 0
            
            for coin in coinsInCategory
            {
                counter += coin.getNumInstances().intValue
            }
            
            return counter
        }
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        //we decode this object's information
        if let categoryTypeObject = aDecoder.decodeObject(forKey: Keys.Current_Category_Type) as? CategoryTypes.RawValue
        {
            self.currentCategoryType = categoryTypeObject
        }
        
        if let coinsInCategoryArrayObject = aDecoder.decodeObject(forKey: Keys.Coins_In_Category) as? [Coin]
        {
            self.coinsInCategory = coinsInCategoryArrayObject
        }
    }
    
    public func encode(with aCoder: NSCoder)
    {
        //we encode this object's information
        aCoder.encode(currentCategoryType, forKey: Keys.Current_Category_Type)
        aCoder.encode(self.coinsInCategory, forKey: Keys.Coins_In_Category)
    }
    
    override init()
    {
        super.init()
        self.coinsInCategory = []
        self.currentCategoryType = CategoryTypes.NO_CATEGORY.rawValue
    }
    
    convenience init(coins: [Coin], categoryType: CategoryTypes.RawValue)
    {
        self.init()
        
        self.coinsInCategory = coins
        
        if isACategoryType(categoryType: categoryType) == true
        {
            self.currentCategoryType = categoryType
        }
        else
        {
           self.currentCategoryType = CategoryTypes.NO_CATEGORY.rawValue
        }
    }
    
    convenience init(category: CoinCategory)
    {
        self.init()
        self.coinsInCategory = category.coinsInCategory
        self.currentCategoryType = category.currentCategoryType
    }
    
    func isACategoryType(categoryType: NSString) -> Bool
    {
        switch categoryType
        {
        case CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue:
            return true
        case CategoryTypes.COUNTRY.rawValue:
            return true
        case CategoryTypes.YEAR.rawValue:
            return true
        case CategoryTypes.CURRENCY.rawValue:
            return true
        default:
            return false
        }
    }
    
    func addCoin(newCoin: Coin)
    {
        //we are adding a new Coin object to this category 
        //if it falls into the category's type
        if self.coinFitsCategory(aCoin: newCoin) == true
        {
            self.coinsInCategory.append(newCoin)
        }
    }
    
    func coinFitsCategory(aCoin: Coin) -> Bool
    {
        //this function tests if aCoin fits into the category type
        //but that all varies depending on which category the coin is
        if self.coinsInCategory.count == 0
        {
            //this category is currently empty, so any addition goes!
            return true
        }
        
        //otherwise, this category is not empty... so we are now going to 
        //examine the situation more critically
        let testCoin = self.coinsInCategory[0]
        
        ///////////////////////////////////////////////////////////////////////////
        
        switch self.currentCategoryType
        {
        case CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue:
                return (testCoin.getCountry().lowercased == aCoin.getCountry().lowercased) && (testCoin.getValue() == aCoin.getValue()) && (testCoin.getDenomination().lowercased == aCoin.getDenomination().lowercased)
            
        case CategoryTypes.COUNTRY.rawValue:
            return testCoin.getCountry().lowercased == aCoin.getCountry().lowercased
            
        case CategoryTypes.CURRENCY.rawValue:
            return testCoin.getDenomination().lowercased == aCoin.getDenomination().lowercased && testCoin.getCountry().lowercased == aCoin.getCountry().lowercased
            
        case CategoryTypes.YEAR.rawValue:
            return testCoin.getYear() == aCoin.getYear()
            
        default:
            return false
        }
    }
    
    func getIndexOfCoinInCollection(coin: Coin) -> Int
    {
        //we are going to return -1 if the coin does not exist in the collection
        //and are going to return the index otherwise if yes
        for i in 0..<self.coinsInCategory.count
        {
            if coinsInCategory[i] == coin
            {
                return i
            }
        }
        
        //have not found anything
        return -1
    }
    
    func removeCoin(at: Int)
    {
        //we remove the coin at the index if it is in a valid range of the coinInCategory array
        if isValidArrayIndex(index: at)
        {
            self.coinsInCategory.remove(at: at)
        }
    }
    
    func getCoin(at: Int) -> Coin?
    {
        //we return nil if there is an issue in accessing the coin
        if isValidArrayIndex(index: at)
        {
            return self.coinsInCategory[at]
        }
        else
        {
            return nil
        }
    }
    
    func assignCoin(at: Int,c: Coin)
    {
        if isValidArrayIndex(index: at)
        {
            self.coinsInCategory[at].assign(right: c)
        }
    }
    
    func deleteAllCoins()
    {
        //we delete all the coin in this category
        self.coinsInCategory.removeAll()
    }
    
    func removeCoin(c: Coin)
    {
        //we delete a coin from the category
        for i in 0..<self.coinsInCategory.count
        {
            if self.coinsInCategory[i] == c
            {
                //the coin at index "i" is equal to the coin "c" that we want to delete from the category
                self.coinsInCategory.remove(at: i)
                return
            }
        }
    }
    
    func swapCoinsInCategory(indexOne: Int,indexTwo: Int)
    {
        //we swap the order of coins in the category
        if isValidArrayIndex(index: indexOne) && isValidArrayIndex(index: indexTwo)
        {
            swap(&self.coinsInCategory[indexOne], &self.coinsInCategory[indexTwo])
        }
    }
    
    func hasCoin(c: Coin) -> Bool
    {
        return getIndexOfCoinInCollection(coin: c) != -1
    }
    
    private func isValidArrayIndex(index: Int) -> Bool
    {
        return (0 <= index && index < coinsInCategory.count)
    }
    
}
