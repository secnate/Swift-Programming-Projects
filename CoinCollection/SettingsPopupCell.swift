//
//  SettingsPopupCell.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 7/16/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This is the class that is responsible for running the cells
//  that are displayed in the "Settings" popup

import UIKit

class SettingsPopupCell: UITableViewCell {

    //this is the button that is an empty circle or a circle with a checkmark
    @IBOutlet var selectedButton : UIButton!
    
    //this label shows information about the type of option that the user can select
    @IBOutlet var typeTextLabel : UILabel!
        
    public static let UNSELECTED_BUTTON_IMAGE = #imageLiteral(resourceName: "Unchecked Circle ")
    public static let SELECTED_BUTTON_IMAGE = #imageLiteral(resourceName: "CheckedCircle ")
    
    //this is the default image. The client of this class can
    //change this variable's value to whichever one he wants
    var currentButtonImage : UIImage  = SettingsPopupCell.UNSELECTED_BUTTON_IMAGE
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        //we do not want the user to be able to click the circular button 
        //in such a way that it clicking it is considered to be a diffferent action than
        //clicking on the entire cell. Disabling
        //user interaction with the selectedButton
        //means that if the user clicks the selectedButton,
        //he clicks the entire cell automatically, so clicking the selectedButton
        //and an area outside of the selectedButton will by default trigger the same action
        selectedButton.isUserInteractionEnabled = false
        
        //and we load the image
        selectedButton.imageView?.image = currentButtonImage
    }
    
    func select()
    {
        currentButtonImage = SettingsPopupCell.SELECTED_BUTTON_IMAGE
        selectedButton.setImage(currentButtonImage, for: .normal)
    }
    
    func deselect()
    {
        currentButtonImage = SettingsPopupCell.UNSELECTED_BUTTON_IMAGE
        selectedButton.setImage(currentButtonImage, for: .normal)
    }
    
    var selectedByUser : Bool
    {
        //this calculated variable returns whether this cell has been selected by the user
        if currentButtonImage == SettingsPopupCell.SELECTED_BUTTON_IMAGE
        {
            return true
        }
        else
        {
            return false
        }
    }
}
