//
//  ExternalApplicationIntegration.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 3/22/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This file is responsible for integrating this app
//  with other apps to ensure a smooth experience for
//  the multi-app user. 
//
//  Example target apps for integration include Facebook, Twitter, and Safari.

import SafariServices
import Social
import Foundation
import UIKit

func safariSearch(coin: Coin) -> SFSafariViewController
{
        //the user does not know enough information about the coin and wants to get more info
        //we provide a native browsing experience in the app to relieve the user of the hassle of moving back and forth between this and the Safari App
    
        //the wantSpecificCoinInfo parameter represents if the client of this safariSearch function wants
        //the search to be for a specific coin with the specific information relating only to this coin
        //(such as year, mintmark, grade, and etc.).
        //if the wantSpecificCoin parameter is true, we include that type of specific information into the search
        //if it is false, then we assume that we want the safari search to be general and to search only for the specific coin category
    
        var url = "https://www.google.com/"     //we use this in the case that we do not have any information from the coin for a default google search
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
        //we construct a url for the coin search given the information that we do know regarding it if we have enough information to build it
        if (coin.getCountry() != Coin.DEFAULT_COUNTRY || coin.getValue() != 0 || coin.getDenomination() != Coin.DEFAULT_DENOMINATION || coin.getDescriptiveName() != Coin.DEFAULT_DESCRIPTIVE_NAME ||
            coin.getYear() != nil || coin.getMint() != Coin.DEFAULT_MINT ||
            coin.getGrade() != nil)
        {
            //we have at least one category to search from
            //we not construct our searchs string
        
            url += "search?q="            //we conduct a safe search. the "q=" will lead to the keywords that are being added
        
            //now we go down the line and add words from each category
            var keywordString: String = ""
            
            //we start to add in the basic keywords that are used to identify the general category of coins
            if coin.getCountry() != Coin.DEFAULT_COUNTRY
            {
                for str in coin.getCountry().components(separatedBy: " ")   //we tokenize the words in the country
                {
                    keywordString += str + "+"  //we add in a keyword and a plus sign for the keyword
                }
            }
        
            if coin.getValue() != 0 && coin.getDenomination() != Coin.DEFAULT_DENOMINATION  //we do not want a value searched if we do not know the denomination
            {
                keywordString += "\(coin.getValue())" + "+"
            }
        
            if coin.getDenomination() != Coin.DEFAULT_DENOMINATION
            {
                for str in coin.getDenomination().components(separatedBy: " ")  //we tokenize the words in the denomination
                {
                    keywordString += str + "+"
                }
            }
            
            //now we add in the specific keywords for a specific coin instance if we are searching for a specific coin, not a category
            if coin.getYear() != nil
            {
                keywordString += "\(abs(Int32(coin.getYear()!)))" + "+"
                
                //we can add in the BC and BCE keywords also
                if coin.getYear()!.intValue > 0
                {
                    keywordString += TimePeriods.CE.rawValue + "+"
                }
                
                else if coin.getYear()!.intValue < 0
                {
                    keywordString += TimePeriods.BCE.rawValue + "+"
                }
            }
            
            if coin.getMint() != Coin.DEFAULT_MINT
            {
                for str in coin.getMint().components(separatedBy: " ")
                {
                    keywordString += str + "+"                           //we tokenize the words in the mint
                }
            }
            
            if coin.getGrade() != nil
            {
                keywordString += "grade" + "+" + "\(coin.getGrade()!)" + "+"
            }
            
            //now we add in the keyword "coin" because sometimes, the google search might lead to other topics -> we specify it explicitely to search for a coin
            if keywordString != ""
            {
                keywordString += "coin+"
            }
            
            //ok, now we added in the keywords, but we need to remove the trailing "+" that can occur
            if keywordString.characters.last == "+"
            {
                keywordString = String(keywordString.characters.dropLast(1))
            }
            
            //great! we prepeared the google search url's keywords. let's add it to the url and search!
            url += keywordString
        }
    
    
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //we open the given url
    
        let sfViewController : SFSafariViewController
        if let theURL = URL(string: url)
        {
            sfViewController = SFSafariViewController(url: theURL,
                                                      entersReaderIfAvailable: false)
            
        
            //we now return the prepared view controller to the client that called the function
            //and it is up to the client of the function to present it appropriately
        }
        else
        {
            sfViewController = SFSafariViewController(url: URL(string: "www.google.com")!, entersReaderIfAvailable: false)
        }
        sfViewController.preferredBarTintColor = UIColor.orange
        sfViewController.preferredControlTintColor = UIColor.white
    
        //we want this viewcontroller to be presented over the current context and not to
        //take up space outside the bounds of the viewcontroller that is going to be presented
        sfViewController.modalPresentationStyle = .overCurrentContext
        sfViewController.hidesBottomBarWhenPushed = true
    
        return sfViewController
}

func safariSearch(category: CoinCategory) -> SFSafariViewController
{
    //the user does not know enough information about the coin and wants to get more info
    //we provide a native browsing experience in the app to relieve the user of the hassle of moving back and forth between this and the Safari App
    
    var url = "https://www.google.com/"     //we use this in the case that we do not have any information from the coin for a default google search
    
    var keywordString : String = ""
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //we construct a url based on sorting criteria for a category
    switch category.currentCategoryType
    {
        
    //the searching criteria depends on each category
    case CoinCategory.CategoryTypes.COUNTRY_VALUE_AND_CURRENCY.rawValue:
        
        //we add in the keywords for the country, value and currency
        let sampleCoin = category.coinsInCategory[0]    //assume that this coin is representative of all coins in the category
        
        //country
        if sampleCoin.getCountry() != Coin.DEFAULT_COUNTRY
        {
            for str in sampleCoin.getCountry().components(separatedBy: " ")   //we tokenize the words in the country
            {
                keywordString += str + "+"  //we add in a keyword and a plus sign for the keyword
            }
        }
        
        //value
        if sampleCoin.getValue() != 0 && sampleCoin.getDenomination() != Coin.DEFAULT_DENOMINATION //we do not want a value searched for a coin if we do not know the currency
        {
            keywordString += "\(sampleCoin.getValue())" + "+"
        }
        
        //currency
        if sampleCoin.getDenomination() != Coin.DEFAULT_DENOMINATION
        {
            for str in sampleCoin.getDenomination().components(separatedBy: " ")  //we tokenize the words in the denomination
            {
                keywordString += str + "+"
            }
        }
        
    case CoinCategory.CategoryTypes.COUNTRY.rawValue:
        
        let sampleCoin = category.coinsInCategory[0]    //assume that this coin is representative of all the coins in the category
        
        if sampleCoin.getCountry() != Coin.DEFAULT_COUNTRY
        {
            for str in sampleCoin.getCountry().components(separatedBy: " ")   //we tokenize the words in the country
            {
                keywordString += str + "+"  //we add in a keyword and a plus sign for the keyword
            }
        }
        
    case CoinCategory.CategoryTypes.CURRENCY.rawValue:
        
        let sampleCoin = category.coinsInCategory[0]    //assume that this coin is representative of all the coins in the category
        
        if sampleCoin.getCountry() != Coin.DEFAULT_COUNTRY
        {
            for str in sampleCoin.getCountry().components(separatedBy: " ")   //we tokenize the words in the country
            {
                keywordString += str + "+"  //we add in a keyword and a plus sign for the keyword
            }
        }
        
        if sampleCoin.getDenomination() != Coin.DEFAULT_DENOMINATION
        {
            for str in sampleCoin.getDenomination().components(separatedBy: " ")  //we tokenize the words in the denomination
            {
                keywordString += str + "+"
            }
        }

        
    case CoinCategory.CategoryTypes.YEAR.rawValue:
        
        if category.coinsInCategory[0].getYear() != nil
        {
            keywordString += "\(abs(Int32(category.coinsInCategory[0].getYear()!)))" + "+"
            
            //we can add in the BC and BCE keywords also
            if category.coinsInCategory[0].getYear()!.intValue > 0
            {
                keywordString += TimePeriods.CE.rawValue + "+"
            }
                
            else if category.coinsInCategory[0].getYear()!.intValue < 0
            {
                keywordString += TimePeriods.BCE.rawValue + "+"
            }
        }
        
    default:
        ()
    }
    
    //we add now the general "coin" keyword and remove an extraneous plus sign at the end of the keywordString
    if keywordString != ""
    {
        //we have added some valid keywords to the search parameters, so we need to include the keyword "coin" to indicate that we are searching a coin
        keywordString += "coin+"
    }
    
    //ok, now we added in the keywords, but we need to remove the trailing "+" that can occur
    if keywordString.characters.last == "+"
    {
        keywordString = String(keywordString.characters.dropLast(1))
    }

    //we now save the keywords to the url
    url += "search?q=" + keywordString
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //we open the given url
    
    let sfViewController : SFSafariViewController
    if let theURL = URL(string: url)
    {
        sfViewController = SFSafariViewController(url: theURL,
                                                  entersReaderIfAvailable: false)
        
        
        //we now return the prepared view controller to the client that called the function
        //and it is up to the client of the function to present it appropriately
    }
    else
    {
        sfViewController = SFSafariViewController(url: URL(string: "www.google.com")!, entersReaderIfAvailable: false)
    }
    sfViewController.preferredBarTintColor = UIColor.orange
    sfViewController.preferredControlTintColor = UIColor.white
    
    //we want this viewcontroller to be presented over the current context and not to
    //take up space outside the bounds of the viewcontroller that is going to be presented
    sfViewController.modalPresentationStyle = .overCurrentContext
    sfViewController.hidesBottomBarWhenPushed = true
    
    return sfViewController
}


func shareCoin(coin: Coin) -> UIActivityViewController
{
    //we have a coin from the user that now we want to share it across platforms
    //
    //it is the responsibility of the client function to present it in the right place at the right time
    
    let itemSource = CoinSharingItemSource(c: coin)
    let toReturn = UIActivityViewController(activityItems: [itemSource], applicationActivities: nil)
    
    //we modify the toReturn to prevent certain unecessary activities
    //from being available
    toReturn.excludedActivityTypes = [UIActivityType.addToReadingList,
            UIActivityType.airDrop, UIActivityType.assignToContact,
            UIActivityType.openInIBooks,UIActivityType.postToFlickr,
            UIActivityType.postToTencentWeibo,UIActivityType.postToVimeo,
            UIActivityType.postToWeibo,UIActivityType.saveToCameraRoll]
    
    //the only reason that we are returning the itemSource as well as toReturn is to
    //unblur the parent view controller with the itemSource
    return toReturn
}


////////////////////////////////////////////////////////////////////////////////////////////


//we use the UIActivityItemSource to ensure that we can return different values for different sharing actions
//so that we can tweet one thing, facebook another, google drive a third, and etc and etc.

class CoinSharingItemSource: NSObject, UIActivityItemSource
{
    private let coin: Coin  //this is the coin that the uiactivityviewcontroller is going to share
    
    
    ////////////////////////////////////////////////////////////////
    init(c: Coin)
    {
        self.coin = c
    }
    
    @objc func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    @objc func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any?
    {
        //now we return different results for each type of activity
        //EX: I return a short twitter tweet but I also can return a LONG email summary
        
        var toReturn: String
        toReturn = "Check out this coin in my collection!\n"
        toReturn += "---\n"
        
        if (activityType == UIActivityType.mail ||
            activityType == UIActivityType.postToFacebook ||
            activityType == UIActivityType.copyToPasteboard ||
            activityType == UIActivityType.airDrop ||
            activityType == UIActivityType.postToWeibo)
        {
            //we are sharing via email or facebook
            //and because we are capable of sending
            toReturn += coin.getCompleteSummary() as String
        
        }
        
        else if (activityType == UIActivityType.message ||
                 activityType == UIActivityType.postToTwitter ||
                 activityType == UIActivityType.postToTencentWeibo)
        {
            //let's build the defaultText so that only the fields of the coin that actually have a value get shown here:
            
            //we go down the line
            
            //now we check if the value and currency fields are initialized and ONLY display if we know both
            //first we add in the value
            if (coin.getValue() != 0 &&  coin.getDenomination() != Coin.DEFAULT_DENOMINATION)
            {
                toReturn.append("\(coin.valueAndDenomination).\n")
            }
            else
            {
                toReturn.append("Value and Denomination N/A.\n")
            }
            
            
            //now we add in a country
            if (coin.getCountry() != Coin.DEFAULT_COUNTRY)
            {
                toReturn.append("\(coin.getCountry()).\n")
            }
            else
            {
                toReturn.append("Country N/A.\n")
            }
            
            if (coin.getDescriptiveName() != Coin.DEFAULT_DESCRIPTIVE_NAME)
            {
                toReturn.append("\(coin.getDescriptiveName()).\n")
            }
            else
            {
                toReturn.append("Description N/A.\n")
            }
            
            
        }
        
        //////////////////////////////////////////////////////////////
        
        //we are done creating toReturn - we return the final string!
        return toReturn as AnyObject?
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        
        return "Check out this coin in my collection!"
    }
    
    
    private func activityViewController(_ activityViewController: UIActivityViewController, thumnailImageForActivityType activityType: UIActivityType?, suggestedSize size: CGSize) -> UIImage?
    {
        //we return the custom thumbnail for each social sharing action
        
        if activityType == UIActivityType.message
        {
            return #imageLiteral(resourceName: "messageIcon")
        }
        
        else if activityType == UIActivityType.mail
        {
            return #imageLiteral(resourceName: "mailIcon")
        }
        
        else if (activityType == UIActivityType.postToTwitter)
        {
            return #imageLiteral(resourceName: "twitterIcon")
        }
        
        else if activityType == UIActivityType.postToFacebook
        {
            return #imageLiteral(resourceName: "facebookIcon")
        }
        
        else if activityType == UIActivityType.copyToPasteboard
        {
            return #imageLiteral(resourceName: "copyIcon")
        }
        
        
        

        //there is no other social sharing action that we specifically have an icon for
        return #imageLiteral(resourceName: "defaultSharingIcon")
    
    }
}



