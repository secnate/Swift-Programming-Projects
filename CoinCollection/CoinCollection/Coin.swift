//
//  Coin.swift
//  CoinCollection
//
//  Created by 1A Pavlovsky, N on 1/17/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This provides the class definition of Class Coin for the project

import UIKit
import CoreData

enum TimePeriods: String
{
    //this enumeration represents the different time periods that a 
    //coin was minted in, for the sake of this programn
    case BCE = "BCE"
    case CE = "CE"
}

public class Coin : NSObject, NSCoding
{
    //this struct represents all the keys used in encoding and decoding this object
    struct Keys
    {
        static let Country = "country"
        static let Mint = "mint"
        static let Year = "year"
        static let Currency = "currency"
        static let Value = "value"
        static let Grade = "grade"
        static let Comments = "comments"
        static let NumInstances = "numberInstances"
        static let Description = "description"
        static let Obverse = "obverse"
        static let Reverse = "reverse"
    }
    //this represents a coin in the table view
    static let GRADING_LOWER_LIMIT: NSNumber = 1
    static let GRADING_UPPER_LIMIT: NSNumber = 70
    
    //this represents the default strings returned if a field does not have the needed information
    static let DEFAULT_DESCRIPTIVE_NAME: NSString = "(Description?)"
    static let DEFAULT_COMMENTS: NSString = "(Comments?)"
    static let DEFAULT_DENOMINATION: NSString = "(Currency?)"
    static let DEFAULT_MINT: NSString = "(Mint?)"
    static let DEFAULT_COUNTRY: NSString = "(Country?)"
    static let DEFAULT_YEAR: NSString = "(Year?)"
    static let DEFAULT_GRADE: NSString = "(Grade?)"
    
    public static var DEFAULT_VALUE_AND_DENOMINATION: NSString
    {
        get
        {
            return (Coin.DEFAULT_VALUE_STRING as String) + " " + (Coin.DEFAULT_DENOMINATION as String) as NSString
        }
    }
    static let DEFAULT_VALUE_STRING : NSString = "(Value?)"
    
    static let OBVERSE_IMAGE_STRING : NSString = "Obverse"
    static let REVERSE_IMAGE_STRING : NSString = "Reverse"
    
    static let NOT_AVAILABLE : NSString = "N/A"
    
    static private let BULLET = "➣ "           //represents the kind of bullet to be used to build a complete summary of the coin
    
    //declare members with setters and getters
    private var country: NSString = ""        //what country/empire/etc. used in?
    private var mint: NSString = ""            //where minted? EX: US Mint, St. Petersburg
    private var year: NSNumber? = nil              //what year minted? per gregorian calendar
                                        //the year can be negative to represent the BCE period
                                        //positive to represent the CE periods
    private var typeCurrency: NSString = ""     //what is the unit of value? EX: Cents, dollars, centavos, etc
    private var theValue: NSNumber = 0         //how many? EX: how many dollars, cents, centavos, etc.?
    
    
    //additional information about the coin
    private var grade: NSNumber?            //on the american grading scale for coins. 1-70
    private var comments: NSString = ""        //extra comments stored by the user for himself
    
    
    private var numberOfInstances: NSNumber = 0 //number of coins exactly like this. EX: 1,2,3,4...etc? For each instance, it must be >= 1.
    
    //This describes the type of the coin
    //EX: Walking Liberty Quarter, Barber Quarter, Standing Liberty Quarter... etc
    private var descriptiveName: NSString = ""
    
    private var obverseImage: UIImage? = nil
    private var reverseImage: UIImage? = nil
    
    
    public var valueAndDenomination: NSString
    {
        get
        {
            //need to check four cases
            //case 1: we have the right values for value and denomination
            //case 2: we do not have a value but do have denomination
            //case 3: we have a value but do not have denomination
            //case 4: we do not have both
            //
            //the reason why we consider 0 to be an empty value is because a coin that was worth 
            //nothing would not have been minted in the first place!!!
            if (self.theValue != 0 && self.typeCurrency != "")
            {
                //have value and denomination
                return "\(self.theValue) \(self.typeCurrency)" as NSString //like "20 Cents"
            }
            
            else if (self.theValue == 0 && self.typeCurrency != "" )
            {
                //do not have value, but have denomination
                return (Coin.DEFAULT_VALUE_STRING as String) + " \(self.typeCurrency)" as NSString
            }
            
            else if (self.theValue != 0 && self.typeCurrency == "")
            {
                //we have value, but do not have denomination
                return "\(self.theValue) " + (Coin.DEFAULT_DENOMINATION as String) as NSString
            }
            
            else
            {
                //we do not have both
                return Coin.DEFAULT_VALUE_AND_DENOMINATION as NSString
            }
        
        }
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        //we decode this object's information
        if let countryObject = aDecoder.decodeObject(forKey: Keys.Country) as? NSString
        {
            self.country = countryObject
        }
        
        if let mintObject = aDecoder.decodeObject(forKey: Keys.Country) as? NSString
        {
            self.mint = mintObject
        }
        
        if let yearObject = aDecoder.decodeObject(forKey: Keys.Year) as? NSNumber
        {
            self.year = yearObject
        }
        
        if let currencyObject = aDecoder.decodeObject(forKey: Keys.Currency) as? NSString
        {
            self.typeCurrency = currencyObject
        }
        
        if let valueObject = aDecoder.decodeObject(forKey: Keys.Value) as? NSNumber
        {
            self.theValue = valueObject
        }
        
        if let gradeObject = aDecoder.decodeObject(forKey: Keys.Grade) as? NSNumber
        {
            self.grade = gradeObject
        }
        
        if let commentObject = aDecoder.decodeObject(forKey: Keys.Comments) as? NSString
        {
            self.comments = commentObject
        }
        
        if let numInstancesObject = aDecoder.decodeObject(forKey: Keys.NumInstances) as? NSNumber
        {
            self.numberOfInstances = numInstancesObject
        }
        
        if let descriptiveNameObject = aDecoder.decodeObject(forKey: Keys.Description) as? NSString
        {
            self.descriptiveName = descriptiveNameObject
        }
        
        if let obverseImageObject = aDecoder.decodeObject(forKey: Keys.Obverse) as? UIImage
        {
            self.obverseImage = obverseImageObject
        }
        
        if let reverseImageObject = aDecoder.decodeObject(forKey: Keys.Reverse) as? UIImage
        {
            self.reverseImage = reverseImageObject
        }
    }
    override init()
    {
        //default initializer
        super.init()
        
        self.country = ""
        self.mint = ""
        self.year = nil
        self.typeCurrency = ""
        self.theValue = 0
        self.comments = ""
        self.numberOfInstances = 1
        self.descriptiveName = ""
        self.obverseImage = nil
        self.reverseImage = nil
    }
    
    init(country: NSString,year: Int?,typeCurrency: NSString, theValue: NSNumber,mint: NSString,grade: Int?,numInstances: NSNumber = 1,description: NSString, comments: NSString)
    {
        super.init()
        self.country = country
        self.mint = mint
        self.year = year! as NSNumber
        self.typeCurrency = typeCurrency
        self.theValue = theValue
        self.comments = comments
        self.numberOfInstances = numInstances
        self.descriptiveName = description
        
        self.obverseImage = nil
        self.reverseImage = nil
    }
    
    init(country: NSString,year: NSNumber?,typeCurrency: NSString, theValue: NSNumber,mint: NSString,grade: NSNumber?,numInstances: NSNumber = 1,description: NSString, comments: NSString,obverseImage: UIImage, reverseImage: UIImage)
    {
        super.init()
        self.country = country
        self.mint = mint
        self.year = year
        self.typeCurrency = typeCurrency
        self.theValue = theValue
        self.comments = comments
        self.numberOfInstances = numInstances
        self.descriptiveName = description
    }
    
    public func encode(with aCoder: NSCoder)
    {
        //we encode the coin's information
        aCoder.encode(self.country, forKey: Keys.Country)
        aCoder.encode(self.mint, forKey: Keys.Mint)
        aCoder.encode(self.year, forKey: Keys.Year)
        aCoder.encode(self.typeCurrency, forKey: Keys.Currency)
        aCoder.encode(self.theValue, forKey: Keys.Value)
        aCoder.encode(self.grade, forKey: Keys.Grade)
        aCoder.encode(self.comments, forKey: Keys.Comments)
        aCoder.encode(self.numberOfInstances, forKey: Keys.NumInstances)
        aCoder.encode(self.descriptiveName, forKey: Keys.Description)
        aCoder.encode(self.obverseImage, forKey: Keys.Obverse)
        aCoder.encode(self.reverseImage, forKey: Keys.Reverse)
    }
    
    
    
    //////////////////////////////////////
    //setter and getter functions for class members
    
    //setter functions to avoid recursion
    func setCountry(c : NSString) -> Void {
        self.country = c
    }
    
    
    func getCountry() -> NSString
    {
        if self.country == ""
        {
            return Coin.DEFAULT_COUNTRY
        }
        else
        {
            return String(self.country) as NSString
        }
    }
    
    
    func getMint() -> NSString
    {
        if self.mint == ""
        {
            return Coin.DEFAULT_MINT
        }
        else
        {
            return self.mint
        }
    }
    
    func setMint(newMint: NSString) -> Void
    {
        self.mint = newMint
    }
    
    func getYear() -> NSNumber?
    {
        guard self.year != nil else
        {
            //value requirements not met, do something
            return nil
        }
        return (self.year)
    }
    
    func setYear(newValue: NSNumber?)
    {
        if newValue == nil
        {
            self.year = nil
        }
        else
        {
            self.year = newValue
        }
    }
    
    
    func getDenomination() -> NSString
    {
        guard self.typeCurrency != "" else
        {
            //value requirements not met, do something
            return Coin.DEFAULT_DENOMINATION
        }
        return self.typeCurrency
    }
    
    func setDenomination(newValue: NSString) -> Void
    {
        self.typeCurrency = newValue
    }
    
    
    func getValue() -> NSNumber
    {
        return self.theValue
    }
    
    func setValue(newValue: NSNumber) -> Void
    {
        self.theValue = newValue
    
        if (self.theValue.intValue < 0)  //can not have a negative value, set it to zero for placeholder
        {
            self.theValue = 0
        }
    }
    
    
    func getGrade() -> NSNumber?
    {
        guard (self.grade != nil && (Coin.GRADING_UPPER_LIMIT.intValue >= self.grade!.intValue && Coin.GRADING_LOWER_LIMIT.intValue <= self.grade!.intValue)) else
        {
            //we either have a nil grade or it does not fall into the valid range for grading
            return nil
        }
        return self.grade
    }
    
    func setGrade(newValue: NSNumber?) -> Void
    {
        self.grade = newValue
    }
    
    func getComments() -> NSString
    {
        guard (self.comments != "") else
        {
            return Coin.DEFAULT_COMMENTS
        }
        return self.comments
    }
    
    func setComments(newComments: NSString)
    {
        self.comments = newComments
    }
    
    func getNumInstances() -> NSNumber
    {
        guard self.numberOfInstances.intValue >= 0 else
        {
            return 0    //return at least 0 if the numberOfInstances is negative
        }
        return self.numberOfInstances
    }
    
    func setNumInstances(newValue: NSNumber) -> Void
    {
    //setting to a minimum of zero
        guard ( newValue.intValue >= 0 ) else
        {
            self.numberOfInstances = 0  //set to a minimum of zero
            return
        }
        self.numberOfInstances = newValue
    }
    
    func incrementNumInstances()
    {
        self.numberOfInstances = NSNumber(integerLiteral: self.numberOfInstances.intValue + 1)
    }
    
    func decrementNumInstances()
    {
        self.numberOfInstances = NSNumber(integerLiteral: self.numberOfInstances.intValue - 1)
    }
    
    func setDescriptiveName(newValue: NSString) -> Void
    {
        //empty string is default
        self.descriptiveName = newValue
    }
    
    func getDescriptiveName() -> NSString
    {
        if self.descriptiveName == ""
        {
            return Coin.DEFAULT_DESCRIPTIVE_NAME
        }
        else
        {
            return self.descriptiveName
        }
    }
    
    func getObverseImage() -> UIImage?
    {
        return self.obverseImage
    }
    
    func setObverseImage(newImage: UIImage?)
    {
        self.obverseImage = newImage
    }
    
    func getReverseImage() -> UIImage?
    {
        return self.reverseImage
    }
    
    func setReverseImage(newImage: UIImage?)
    {
        self.reverseImage = newImage
    }
    
    func getImages() -> [UIImage]?
    {
        if self.reverseImage == nil && self.obverseImage == nil
        {
            return nil
        }
        else
        {
            var toReturn: [UIImage] = []
            
            if self.obverseImage != nil
            {
                toReturn.append(self.obverseImage!)
            }
            
            if self.reverseImage != nil
            {
                toReturn.append(self.reverseImage!)
            }
            
            return toReturn
        }
    }
    
    func getCompleteSummary() -> NSString
    {
        //returns a bulleted list that represents the coin 
        //and it describes every single detail 
        
        var toReturn: String = "Information about this coin:\n\n"
        
        //Ex: '20 Cents', '0 units of an unknown currency', etc.
        toReturn += Coin.BULLET + "Value and Denomination: " +
                    "\(self.theValue)" + " " +
                    (self.typeCurrency != "" ? "\(self.typeCurrency)" : "units of an unknown currency") + "\n"
        
        toReturn += Coin.BULLET + "Year: " + (self.year != nil ? "\(self.year!)" : "Unknown Year") + "\n"
        
        //Ex: "Ottoman Empire," or "Unknown country"
        toReturn += Coin.BULLET + "Country: " + (self.country != Coin.DEFAULT_COUNTRY ? "\(self.country)" : "Unknown Country") + "\n"
        
        toReturn += Coin.BULLET + "Mint: " + (self.mint != Coin.DEFAULT_MINT ? "\(self.mint)" : "Unknown Mint") + "\n"
        
        toReturn += Coin.BULLET + "Grade: " + (self.grade != nil ? "\(self.grade!)" : "Unknown Grade") + "\n"
        
        toReturn += Coin.BULLET + "Number of Coins: " + "\(self.numberOfInstances)" + "\n"
        
        toReturn += Coin.BULLET + "Additional Comments: " + (self.comments != Coin.DEFAULT_COMMENTS && self.comments != "" ? self.comments as String : "No Additional Comments") + "\n"
        
        return toReturn as NSString
        
    }
    
    func getIncompleteSummary() -> String
    {
            //returns a string that describes the coin's main detail
            
            var toReturn: String = ""
            
            //Ex: '20 Cents', '0 units of an unknown currency', etc.
            toReturn += "\(self.theValue)" + " " + (self.typeCurrency != "" ? "\(self.typeCurrency)" : "units of an unknown currency") + ". "
            
            toReturn += ((self.year != nil) ? "Year: \(self.year!)" : "Year unknown") + ". "
            
            //Ex: "Ottoman Empire," or "Unknown country"
            toReturn += ((self.country != Coin.DEFAULT_COUNTRY && self.country != "") ? "Country: \(self.country)" : "Country unknown") + ". "
            
            toReturn += ((self.mint != Coin.DEFAULT_MINT && self.mint != "") ? "Mint: \(self.mint)" : "Mint unknown") + ". "
            
            toReturn += (self.grade != nil ? "Grade: \(self.grade!)" : "Grade unknown") + "."
            
            return toReturn
            
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    
    func ofSameType(rhs: Coin) -> Bool
    {
        return (self.getCountry().lowercased == rhs.getCountry().lowercased) && (self.getValue() == rhs.getValue()) && (self.getDenomination().lowercased == rhs.getDenomination().lowercased)
    }
    
    func isIdenticalCoin(rhs: Coin) -> Bool
    {
        //this function is used by the CoinTableViewController in the "addCoin" method
        //and it is used to determine if the added coin matches one that already exists in the collection
        return  self.country.lowercased == rhs.country.lowercased &&
            self.theValue == rhs.theValue &&
            self.typeCurrency.lowercased == rhs.typeCurrency.lowercased &&
            self.mint.lowercased == rhs.mint.lowercased &&
            self.year == rhs.year &&
            self.grade == rhs.grade &&
            self.comments == rhs.comments &&
            self.descriptiveName == rhs.descriptiveName
    }
    
    public static func==(lhs: Coin, rhs: Coin) -> Bool
    {
        //we compare two coin objects for equality in ALL Categories
        return  lhs.country.lowercased == rhs.country.lowercased &&
                lhs.theValue == rhs.theValue &&
                lhs.typeCurrency.lowercased == rhs.typeCurrency.lowercased &&
                lhs.mint.lowercased == rhs.mint.lowercased &&
                lhs.year == rhs.year &&
                lhs.grade == rhs.grade &&
                lhs.comments == rhs.comments &&
                lhs.numberOfInstances == rhs.numberOfInstances &&
                lhs.descriptiveName == rhs.descriptiveName &&
                lhs.obverseImage == rhs.obverseImage &&
                lhs.reverseImage == rhs.reverseImage
    }
    
    func assign(right: Coin)
    {
        //we implement this instead of overloading the assignment "=" operator
        //as it is not possible to overload the "=" operator
        //we assign the right-hand-coin's field values
        //to the left-hand coin's side
        self.country = right.country
        self.theValue = right.theValue
        self.typeCurrency = right.typeCurrency
        self.mint = right.mint
        self.year = right.year
        self.grade = right.grade
        self.comments = right.comments
        self.numberOfInstances = right.numberOfInstances
        self.descriptiveName = right.descriptiveName
        self.obverseImage = right.obverseImage
        self.reverseImage = right.reverseImage
    }
    
}
