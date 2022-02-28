//
//  EditCoinInformationViewController.swift
//  CoinCollection
//
//  Created by 1A Pavlovsky, N on 5/8/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This is the viewcontroller responsible for allowing the user to edit a coin's 
//  information. This is embedded into a presenting viewcontroller called 
//  ShowEditCoinInformationViewController.

import Foundation
import UIKit

///////////////////////////////////////////////////////////////////////////////////////////////////////////

extension String
{
    //this extension of the String class allows this viewcontroller to validate ther user's input effectively
    var isInt: Bool
    {
        //helps determine whether it is an integer
        return Int(self) != nil
    }
    
    var isDouble: Bool
    {
        return Double(self) != nil
    }
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////

class EditCoinInformationViewController: UITableViewController, UITextFieldDelegate,UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet var labels: [UILabel]!  = []   //describe the category of information that can be inputted
    @IBOutlet var textFields: [UITextField] = []
    @IBOutlet var textViews: [UITextView] = []
    ///////////////////////////////////////////////////////////
    
    //we save all the text fields by name so that 
    //we can initialize each text field with the appropriate
    //value of the data stored in the coinToEdit, if we need
    //to display the values of the information for the coin
    @IBOutlet private var valueField: UITextField!
    @IBOutlet private var denominationField: UITextField!
    @IBOutlet private var yearField: UITextField!
    @IBOutlet private var countryField: UITextField!
    @IBOutlet private var mintField: UITextField!
    @IBOutlet private var descriptionField: UITextView!
    @IBOutlet private var gradeField: UITextField!
    @IBOutlet private var numberField: UITextField!
    @IBOutlet private var commentField: UITextView!
    
    @IBOutlet private var beforeOrAfterZeroADChooser: UISegmentedControl!
    
    @IBOutlet var obverseImageView: UIImageView!
    @IBOutlet var reverseImageView: UIImageView!
    
    //this boolean will help the program tell if the user had selected
    //either the obverse or the reverse ImageViews. 
    //If selectedObverseImageView == true, then the user had selected 
    //the obverseImageView and if it is false, then the user had 
    //selected the reverseImageView.
    private var selectedObverseImageView: Bool = true //temporarily true
    
    ///////////////////////////////////////////////////////////
    
    //these two variables represent the default values of the two 
    //textview's texts that are shown if the user is editing the 
    //coin's information and we do not have any information about
    //these specific data instances
    private let DEFAULT_NO_COMMENTS_TEXT: String = "Additional Comments Not Available"
    private let DEFAULT_NO_DESCRIPTION_TEXT: String = "Description Not Available"
    
    ///////////////////////////////////////////////////////////
    private var canEdit: Bool = true          //represents whether the information is just presented or the user can edit them - can edit unless said otherwise
    
    var coinToEdit: Coin? = nil             //this represents whether the viewcontroller is just having the user edit a certain coin's fields (if non-nil) or if it is getting information from a user to initialize a brand-new coin
    
    //these are the colors of the textviews in the viewcontroller when they are
    //empty (with a default placeholder text) or actively used, respectively
    private static var DEFAULT_TEXT_VIEW_COLOR_PLACEHOLDER = UIColor.lightGray
    private static var DEFAULT_TEXT_VIEW_COLOR_USAGE = UIColor.black
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //we set the titles for the beforeOrAfterZeroAD chooser as we want the text
        //presented in each segment to be equal to the raw values of the options in the TimePeriods
        beforeOrAfterZeroADChooser.setTitle(TimePeriods.BCE.rawValue, forSegmentAt: 0)
        beforeOrAfterZeroADChooser.setTitle(TimePeriods.CE.rawValue, forSegmentAt: 1)
        
        //we disable the segmented control selector for now - when there is an empty
        //text field, there is no year that the user can choose to be either in the
        //"BCE" or "CE" periods. When the user enters in a valid year, then the
        //program will enable the segmented control.
        //
        //if when we initialize the fields the program sees fit for the segmented
        //control to be activated, then it will do so correspondingly
        beforeOrAfterZeroADChooser.isEnabled = false
        
        //now if we have a coin to edit, we can initialize the fields and textviews presented
        initializeFields()
        
        /////////////////////////////////////////////////////////////////////////////
        updateViewControllerForEditing()
        updateWidthsForLabels(labels: self.labels)
        
        //if there is extra space at the bottom of the table, we cover it up
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidLayoutSubviews() {
        
        //this function is called after the view
        //controller adjusts the positions of its subviews
        super.viewDidLayoutSubviews()
        
        //now, if we have long, multi-lined text, then
        //we want the UITextViews that are displayed
        //to have the text start from the very top, not the bottom...
        commentField.setContentOffset(CGPoint.zero, animated: false)
        descriptionField.setContentOffset(CGPoint.zero, animated: false)
    }
        
    func setEditingState(newCanEdit: Bool)
    {
        self.canEdit = newCanEdit
        updateViewControllerForEditing()
    }
    
    func toggleEditing()
    {
        setEditingState(newCanEdit: !self.canEdit)
    }
    
    func updateViewControllerForEditing()
    {
        //this function makes edits the viewcontroller
        //to ensure that the user can or can not edit, given the value of canEdit
        for field in textFields
        {
            field.isUserInteractionEnabled = self.canEdit
        }
        
        for textView in textViews
        {
            textView.isUserInteractionEnabled = true
            textView.isEditable = self.canEdit
        }
    }
    
  
    
    private func calculateLabelWidth(label: UILabel) -> CGFloat
    {
        let labelSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: label.frame.height))
        
        return labelSize.width
    }
    
    private func calculateMaxLabelWidth(labels: [UILabel]) -> CGFloat
    {
        return labels.map(calculateLabelWidth).max()!
    }
    
    private func updateWidthsForLabels(labels: [UILabel])
    {
        //we make sure that the labels align in the table
        let maxLabelWidth = calculateMaxLabelWidth(labels: labels)
        for label in labels
        {
            let constraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal,toItem: nil, attribute: .notAnAttribute, multiplier: 1,constant: maxLabelWidth)
            label.addConstraint(constraint)
        }
    }
    
    private func addDoneButtonToKeyboard(inputField: UITextField)
    {
        //this function adds "Done" button to the keypad of a text field
        //that the user uses to input information. 
        //the primary purpose is to add a "done" button to a numeric keypad that some 
        //text fields that require numerical input will need a "done" button
        
        let toolbarDone = UIToolbar.init()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.stopEditingAllTextFields))
        
        toolbarDone.items = [flexBarButton,barBtnDone]
        toolbarDone.sizeToFit()
        /////////////////////////////////////////////////////////////////////
        
        //ok, now we have the "done" button created, we now save it to 
        //textfields using the numerical keyboards
        inputField.inputAccessoryView = toolbarDone
    }
    
    private func addDoneButtonToKeyboard(inputField: UITextView)
    {
        //this function adds "Done" button to the keypad of a text field
        //that the user uses to input information.
        
        let toolbarDone = UIToolbar.init()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.stopEditingAllTextFields))
        
        toolbarDone.items = [barBtnDone]
        toolbarDone.sizeToFit()
        /////////////////////////////////////////////////////////////////////
        
        //ok, now we have the "done" button created, we now save it to
        //textfields using the numerical keyboards
        inputField.inputAccessoryView = toolbarDone
    }
    
    @objc private func stopEditingAllTextFields()
    {
        //this function forces the stopping of the editing of a textfield.
        //this is useful when a user presses the "done" button on a keyboard
        //and we want to close the keyboard
        for field in self.textFields
        {
            //we stop the editing of every field
            field.resignFirstResponder()
        }
    }
    
    private func getNotAvailableStringForMissingCoinData(nameForMissingData: String) -> String
    {
        //say that we are missing a coin's year... this function helps generate the appropriate string
        //that can be used to tell the user that this bit of data is missing
        return nameForMissingData + " N/A"
    }
    
    private func initializeFields()
    {
        //this function initializes the fields of this viewcontroller
        
        //we now initialize the values of the placeholders for each field and textview
        valueField.placeholder = getNotAvailableStringForMissingCoinData(nameForMissingData: "Value")
        denominationField.placeholder = getNotAvailableStringForMissingCoinData(nameForMissingData: "Denom.")
        yearField.placeholder = getNotAvailableStringForMissingCoinData(nameForMissingData: "Year")
        countryField.placeholder = getNotAvailableStringForMissingCoinData(nameForMissingData: "Country")
        mintField.placeholder = getNotAvailableStringForMissingCoinData(nameForMissingData: "Mint")
        gradeField.placeholder = getNotAvailableStringForMissingCoinData(nameForMissingData: "Grade")
        numberField.placeholder = getNotAvailableStringForMissingCoinData(nameForMissingData: "Quantity")
        descriptionField.text = self.DEFAULT_NO_DESCRIPTION_TEXT
        commentField.text = self.DEFAULT_NO_COMMENTS_TEXT
        numberField.placeholder = "1"
        
        //now we present the specific coin data
        if self.coinToEdit != nil
        {
            //we have a coin to present in this viewcontroller
            //we load the appropriate information from the coin
            //into each appropriate text field in the viewcontroller
            
            ////////////////////////////////////////////////////////////////////////////
            //load information into the appropriate fields
            if (coinToEdit!.getValue() != 0)
            {
                valueField.text = "\(coinToEdit!.getValue())"
            }
            
            if coinToEdit!.getDenomination() != Coin.DEFAULT_DENOMINATION
            {
                denominationField.text = coinToEdit!.getDenomination() as String
            }
            
            if coinToEdit!.getYear() != nil //we make sure that we have a year actually
            {
                yearField.text = "\(abs(Int32(coinToEdit!.getYear()!)))"
                
                //we have a valid year and thus we also activate the segmented control
                if coinToEdit!.getYear()!.intValue > 0
                {
                    //this year is positive, meaning that the coin was minted in a CE period
                    beforeOrAfterZeroADChooser.selectedSegmentIndex = 1
                }
                else
                {
                    //this year is negative, meaning that the coin was minted in a BCE period
                    beforeOrAfterZeroADChooser.selectedSegmentIndex = 0
                }
                
                beforeOrAfterZeroADChooser.isEnabled = canEdit
            }
            
            if coinToEdit!.getCountry() != Coin.DEFAULT_COUNTRY
            {
                countryField.text = coinToEdit!.getCountry() as String
            }
            
            if coinToEdit!.getMint() != Coin.DEFAULT_MINT
            {
                mintField.text = coinToEdit!.getMint() as String
            }
            
            if coinToEdit!.getDescriptiveName() != Coin.DEFAULT_DESCRIPTIVE_NAME
            {
                descriptionField.text = coinToEdit!.getDescriptiveName() as String!
            }
            
            if (coinToEdit!.getGrade() != nil)
            {
                gradeField.text = "\(coinToEdit!.getGrade()!)"
            }
            
            if (coinToEdit!.getNumInstances().intValue > 0)
            {
                numberField.text = "\(coinToEdit!.getNumInstances())"
            }
            
            if (coinToEdit!.getComments() != Coin.DEFAULT_COMMENTS)
            {
                commentField.text = "\(coinToEdit!.getComments())"
            }
            
            
            if (coinToEdit!.getObverseImage() != nil)
            {
                obverseImageView.image = coinToEdit!.getObverseImage()!
                setImageViewConstraints(imageView: obverseImageView)
            }
            else
            {
                obverseImageView.image = #imageLiteral(resourceName: "photoalbum")
            }
            
            if (coinToEdit!.getReverseImage() != nil)
            {
                reverseImageView.image = coinToEdit!.getReverseImage()!
                setImageViewConstraints(imageView: reverseImageView)
            }
            else
            {
                reverseImageView.image = #imageLiteral(resourceName: "photoalbum")
            }
        }
        
        ///////////////////////////////////////////////////////////////////////////
        
        //we set this viewcontroller as a delegate of these text fields
        //for one reason only - we need to be able to control the user's input
        //and prevent him/her from entering non-numeric input into these fields
        for field in self.textFields
        {
            field.delegate = self
        }
        
        //check if this app is running on an iPad or iPhone
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone
        {
            //OK, now since we set up the various fields' text, we now set up their keyboards
            //if this app is running on an iPhone, the 
            //keyboard used for numerical inputs will be
            //a numbers-only keyboard and will not have a "done" 
            //button, so we add one.
            //
            //on an iPad, the keyboard for numerical input will
            //have an <Enter> button, so this checking is not needed here
            addDoneButtonToKeyboard(inputField: valueField)
            addDoneButtonToKeyboard(inputField: yearField)
            addDoneButtonToKeyboard(inputField: gradeField)
            addDoneButtonToKeyboard(inputField: numberField)
        }
        
        //we create
        configureTextViews()
    }
    
    func configureTextViews()
    {
        //we set up each textview so that its text is
        //then we set this viewcontroller as a delegate of these text views
        //so that the viewcontroller can create an appropriate "placeholder" property
        for textView in self.textViews
        {
            textView.delegate = self
        }
        
        //now we go down each individual field, and if it is empty or has the default
        //value (as specified by the coin class) then we create appropriate placeholder text
        textViewDidEndEditing(self.commentField)
        textViewDidEndEditing(self.descriptionField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //we can check whether the user is entering the appropriate input with
        //the right characters into a text field.
        if string == ""
        {
            //we have a textfield whose last item is being deleted,
            //leaving the whole yearField empty, meaning we need to consider the segmented control
            if textField == self.yearField &&
               String(textField.text!.characters.dropLast()) == ""
                
            {
                deactivateBeforeOrAfterChooser()
            }
            return true
        }
        
        //now, we consider the case where we want numerical input only
        else if (textField == valueField || textField == yearField ||
            textField == gradeField || textField == numberField)
        {
            //in this case, we ensure that the user can only enter numerical digits
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            let haveAllNumbers: Bool = allowedCharacters.isSuperset(of: characterSet)
            
            //entering numerical input into the yearField
            if haveAllNumbers && textField == yearField
            {
                //we have the user entering a year into the year field
                //if the user is entering input for the first time, then we want
                //the program to automatically select the "CE" button as most coins
                //in people's collections are minted after 0 CE. This is to fix the problem
                //of people forgetting to click an appropriate segment in the segment controller,
                //resulting in all the appropriate information being entered.
                //should the user have a coin that is minted before 0 CE, then he can
                //always change the selected segment to the "CE" one...
                
                if (yearField.text == "" || yearField.text == nil) && string == "0"
                {
                    //we have an empty yearField with no text, but the user wants to enter a leading zero.
                    //the entering of a leading zero is not permissible, so we return false
                    return false
                }
                else if (yearField.text == "" || yearField.text == nil) && string != "" && string != "0"
                {
                    beforeOrAfterZeroADChooser.isEnabled = true
                    beforeOrAfterZeroADChooser.selectedSegmentIndex =  1
                }
            }
            
            else if haveAllNumbers && (textField == numberField || textField == valueField || textField == yearField || textField == gradeField)
            {
                //we have the user entering a number for the number of coins
                //of this particular type that he/she owns. 
                //we want to make sure that he can not enter a zero if the textField is currently empty
                if string == "0"
                {
                    //we have the user entering a zero... makes sure that there textfield's text is not empty
                    if textField.text == nil || (textField.text != nil && textField.text! == "")
                    {
                        //we do not allow him to enter a leading zero
                        return false
                    }
                }
            }
            
            return haveAllNumbers
        }
        else
        {
            
            return true
        }
    }
    
    func deactivateBeforeOrAfterChooser()
    {
        //we do not have a selected year and the yearField is going to
        //be left empty- we disable the segmentcontroller as it is not needed
        beforeOrAfterZeroADChooser.selectedSegmentIndex = -1
        beforeOrAfterZeroADChooser.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason)
    {
        //we have a text field and we stopped editing it
        //if it is a text field whose text was only whitespace, then 
        //no meaningful information has been saved there...
        if trimWhiteSpaceAndRemoveLastPunctuation(str: textField.text) == ""
        {
            //the text field does not have any meaningful text to it
            //so we allow for the textField to be empty and display the placeholder text instead.
            textField.text = nil
        }
        
        if textField == self.yearField && (self.yearField.text == nil || (self.yearField.text != nil && self.yearField.text! == ""))
        {
            //the yearField text field is empty with no value... we thus have no need for the beforeOrAfterADChooser to be activated
            deactivateBeforeOrAfterChooser()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if a user presses "enter" on the keyboard while editing
        //a text field, we stop editing this particular text field
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        //we check if the user pressed "Enter" while editing the text inside this 
        //text view. If he did, then we stop editing this particular text view
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        //if the text view is now being edited, then 
        //we shift attributes in the text- the text
        //is now regular text, not placeholder
        if textView.textColor == EditCoinInformationViewController.DEFAULT_TEXT_VIEW_COLOR_PLACEHOLDER
        {
            textView.text = nil
            textView.textColor = EditCoinInformationViewController.DEFAULT_TEXT_VIEW_COLOR_USAGE
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        //we check if there is any textfield whose text we need to
        //configure as there is no useful information entered
        if textView == self.descriptionField
        {
            if ((trimWhiteSpaceAndRemoveLastPunctuation(str: textView.text!)?.isEmpty)! ||
                //we remove any leading or trailing whitespace so that an extra
                //space entered by the user doesn't have a negative effect
                (trimWhiteSpaceAndRemoveLastPunctuation(str: textView.text!.lowercased())
                != nil &&
                trimWhiteSpaceAndRemoveLastPunctuation(str: textView.text!.lowercased())!
                == DEFAULT_NO_DESCRIPTION_TEXT.lowercased()))
            {
                textView.text = DEFAULT_NO_DESCRIPTION_TEXT
                textView.textColor = EditCoinInformationViewController.DEFAULT_TEXT_VIEW_COLOR_PLACEHOLDER
            }
            else
            {
                //we do not have empty or default information in this text field...
                //meaning that we want to have the field to have the text color needed for regular usage
                textView.textColor = EditCoinInformationViewController.DEFAULT_TEXT_VIEW_COLOR_USAGE
            }
        }
        else if textView == self.commentField
        {
            if ((trimWhiteSpaceAndRemoveLastPunctuation(str: textView.text!)?.isEmpty)! ||
                //we remove any leading or trailing whitespace so that an extra
                //space entered by the user doesn't have a negative effect
                (trimWhiteSpaceAndRemoveLastPunctuation(str: textView.text!.lowercased()) != nil &&
                trimWhiteSpaceAndRemoveLastPunctuation(str: textView.text!.lowercased())!
                == DEFAULT_NO_COMMENTS_TEXT.lowercased()))
            {
                textView.text = DEFAULT_NO_COMMENTS_TEXT
                textView.textColor = EditCoinInformationViewController.DEFAULT_TEXT_VIEW_COLOR_PLACEHOLDER
            }
            else
            {
                textView.textColor = EditCoinInformationViewController.DEFAULT_TEXT_VIEW_COLOR_USAGE
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath.section == 0 && indexPath.row == 0 && self.canEdit == true) || (indexPath.section == 1 && indexPath.row == 0 && self.canEdit == true)
        {
            //the user is either going to edit the obverse or the reverse of the coin
            //we want the user to be able to select an image of the coin.
            //the user can either use the camera or the photo library
            var sideTitle = ""
            if (indexPath.section == 0 && indexPath.row == 0)
            {
                //we are going to get the title for the obverse side of a coin
                sideTitle = Coin.OBVERSE_IMAGE_STRING as String
            }
            else
            {
                //we are going to get the title for the reverse side of a coin
                sideTitle = Coin.REVERSE_IMAGE_STRING as String
            }
            
        
            let optionsMenu = UIAlertController(title: "New \(sideTitle) Image", message: "Select Image Source", preferredStyle: (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone ? .actionSheet : .alert))
            
            //we offer a few options to the user
            optionsMenu.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (nil) -> Void in self.presentCamera(indexPath: indexPath)}))
            optionsMenu.addAction(UIAlertAction(title: "Album", style: .default, handler: { (nil) -> Void in self.presentAlbum(indexPath: indexPath)}))
            optionsMenu.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            //AND WE PRESENT.
            present(optionsMenu, animated: true, completion: nil)
        }
        
        else if (indexPath.section == 0 && indexPath.row == 0 && self.canEdit == false) || (indexPath.section == 1 && indexPath.row == 0 && self.canEdit == false)
        {
            //the user clicked the obverse or the reverse images and he wants to 
            //look at the image in close detail. He is just viewing
            if indexPath.section == 0 && indexPath.row == 0
            {
                //the user selected the obverse image view
                //we display the image for the user's enjoyment and analysis
                performSegue(withIdentifier: "presentCoinObverse", sender: self)
            }
            else if indexPath.section == 1 && indexPath.row == 0
            {
                //the user selected the reverse image view
                //we display the image for the user's enjoyment and analysis
                performSegue(withIdentifier: "presentCoinReverse", sender: self)
            }
        }
        
        //Regardless of what row is clicked, we deselect it
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func presentCamera(indexPath: IndexPath)
    {
        //the user wants to take a photograph of a coin
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.title = "Camera"
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            
            //we bind the imagePicker to this class so we can control it
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
            
            //we now save let this viewcontroller know what type of image we are going to change (for future reference)
            if (indexPath.section == 0 && indexPath.row == 0)
            {
                //the user had selected the imageView in the very first row
                //so the user had selected the obverseImageView
                selectedObverseImageView = true
            }
            else
            {
                //the user had selected the imageView in the second row
                //so the user had selected the reverseImageView
                selectedObverseImageView = false
            }
        }
    }
    
    func presentAlbum(indexPath: IndexPath)
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.title = "Photos"
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            
            //we bind the imagePicker to this class so we can control it
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
            
            //we now save let this viewcontroller know what type of image we are going to change (for future reference)
            if (indexPath.section == 0 && indexPath.row == 0)
            {
                //the user had selected the imageView in the very first row
                //so the user had selected the obverseImageView
                selectedObverseImageView = true
            }
            else
            {
                //the user had selected the imageView in the second row
                //so the user had selected the reverseImageView
                selectedObverseImageView = false
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        //the user picked a photo from the photo library
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            if selectedObverseImageView == true
            {
                //the user had selected the obverse image view
                obverseImageView.image = selectedImage
                obverseImageView.contentMode = .scaleAspectFill
                obverseImageView.clipsToBounds = true
            }
            else
            {
                //the user had selected the reverse image view
                reverseImageView.image = selectedImage
                reverseImageView.contentMode = .scaleAspectFill
                reverseImageView.clipsToBounds = true
            }
        }
        
        //we now resize the image with the appropriate constraints
        //the expression "selectedObverseImageView ? obverseImageView : reverseImageView" is used to select the appropriate imageView
        //and it is used throughout the code for the constraints
        setImageViewConstraints(imageView: (selectedObverseImageView ? self.obverseImageView: self.reverseImageView) )
        
        dismiss(animated: true, completion: nil)
    }

    func setImageViewConstraints(imageView: UIImageView)
    {
        //this function resizes a selected imageView to the appropriate 
        //constraints so that the image is properly constrained within 
        //the superview that is holding the image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let leadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: imageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: imageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: imageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: imageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
    }
    
    func allFieldsEmpty() -> Bool
    {
        //we check if the user did not enter ANY input into any of the textfields or text views
        for field in self.textFields
        {
            if !(field.text == nil || (field.text !=  nil && field.text == ""))
            {
                //we have non-empty text in the field
                return false
            }
        }
        
        if self.commentField.text != self.DEFAULT_NO_COMMENTS_TEXT
        {
            return false
        }
        
        if self.descriptionField.text != self.DEFAULT_NO_DESCRIPTION_TEXT
        {
            return false
        }
        
        //all fields are either empty or have their default placeholder text
        return true
    }
    
    func validateUserInput() -> Bool
    {
        //this function checks if all the input fields have data
        //that is entered by the user in the proper format.
        //
        //if the data is invalid, then the user gets notified of the problem.
        //the function returns a boolean representing whether valid data has
        //been entered by the user. 
        //the function returns false if at least one input field has invalid data
        var noInputErrors: Bool = true      //this will be made false if an error is detected
        
        //we have a possibility that the user did not input anything into the fields... need to check
        if allFieldsEmpty() == true
        {
            //the user did not enter any valid input
            displayAlertToUserOfInvalidInput(title: "No Input Entered",
                                             message: "You have not entered any information about the coin in any field.")
            noInputErrors = false 
        }
        
        //we consider the values of all text fields that have some text (inputted data)
        //if the field is empty, then it is not a problem as the user may not know certain things
        //
        //It is understood that some text fields have a numbers-only keyboard. While this works
        //on an iPhone and restricts user input to numbers, the iPad version has the user pull
        //up a keyboard that has characters that we do not want. Thus, we need to check and 
        //notify the user of invalid input
        
        //first we check that there was an appropriate inputted number for the coin's grade
        //within the valid range (as specified by static variables of the Coin class)
        if gradeField.text != nil && gradeField.text! != ""
        {
            //we have some non-empty text whose values we need to consider
            if !(Coin.GRADING_LOWER_LIMIT.intValue <= Int(gradeField.text!)! && Int(gradeField.text!)! <= Coin.GRADING_UPPER_LIMIT.intValue)
            {
                //the user entered a grade that does not fall into the valid range
                displayAlertToUserOfInvalidInput(title: "Invalid Grade Entered",
                                                 message: "The entered grade does not fall into the valid range of values [\(Coin.GRADING_LOWER_LIMIT)-\(Coin.GRADING_UPPER_LIMIT)].")
                noInputErrors = false
            }
        }
        
        if yearField.text != nil && yearField.text! != ""
        {
            //we have some non-empty text in the year field whose value we need to consider
            //we obviously do not want to allow the user to enter in a year that is greater
            //than this current year [if he selects the "CE" period]. 
            //In case you haven't already figured it out, we are
            //using the Gregorian Calendar as it is the calendar that most of the world runs on.
            //
            //
            //given that the textField delegate functions that this viewcontroller implements
            //restricts the user to entering numerical input only, we check if this input is valid.
            //Now, we do not place any limit on the values of the "BCE" years as we can discover a coin 
            //that is many thousands of years old and we do not know what the oldest coin in the world is
            //but we can make sure that the values of the coins for the
            if (self.beforeOrAfterZeroADChooser.selectedSegmentIndex == 1)
            {
                //this means that we have selected the button on the right which is the "CE" field
                
                //Here I’m creating the calendar instance that we will operate with
                let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
                
                //Now asking the calendar what year are we in today’s date:
                let currentYearInt = (calendar?.component(NSCalendar.Unit.year, from: Date()))!
                
                if Int(yearField.text!) == nil || Int(yearField.text!)! > currentYearInt
                {
                    //this is an invalid year as the coin is said to have been minted
                    //in a later year than this current year OR the year is too large for the Int type in Swift
                    let selectedSegmentTitle = beforeOrAfterZeroADChooser.titleForSegment(at: beforeOrAfterZeroADChooser.selectedSegmentIndex)!
                    noInputErrors = false
                    displayAlertToUserOfInvalidInput(title: "Invalid Year Entered",
                                                     message:
                        "The year entered is " + yearField.text! + " " + selectedSegmentTitle  + ", which is greater than this current year (\(currentYearInt) \(selectedSegmentTitle)).")
                }
            }
            else
            {
                //we have sellected the button on the left which is the "BCE" field
                //now we can not check exactly if the year entered by the user exceeds all valid limits
                //as we do not know what the earliest coin minted in ALL OF HUMAN HISTORY possibly is...
                //But we do know that the coin must have been minted after the age of the universe... unless the coin was minted by G-d
                
                //Here I’m creating the calendar instance that we will operate with
                let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
                
                //Now asking the calendar what year are we in today’s date:
                let currentYearInt = (calendar?.component(NSCalendar.Unit.year, from: Date()))!
                
                //we have some text in the yearField but the number is either so large that it is invalid for
                //the Int type in swift or... it is bigger than the age of the universe
                if Int(yearField.text!) == nil || Int(yearField.text!)! > (13800000000 - currentYearInt)  //the number of years that the universe existed before 0 CE
                {
                    noInputErrors = false
                    
                    displayAlertToUserOfInvalidInput(title: "Invalid Year Entered",
                                                     message:
                                                     "The year inputted is makes the coin older than the entire universe (13800000000 years)!")
                }
            }
        }
        
        //we have checked all the possibilities of invalid user input.
        //It is important to understand that some of the textField and textView delegate methods
        //restricted user input to only the appropriate values, making the need to check more posibilities non-existent
        return noInputErrors
    }
    
    func displayAlertToUserOfInvalidInput(title: String,message: String)
    {
        let alertToDisplay = UIAlertController(title: title, message: message+"\n\nPlease try again with the appropriate input.", preferredStyle: .alert)
        alertToDisplay.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertToDisplay, animated: true, completion: nil)
    }
    
    func getCoinFromInputtedData() -> Coin?
    {
        //this function returns a brand-new coin object created with information entered 
        //by the user in the various text fields and textviews
        
        if validateUserInput() == true
        {
            //we have valid input from the user that allow for the creation of
            //a new coin object without any significant problems
            //we load a coin objectwith the default parameters
            //so if there is an empty textfield, we do not need 
            //to exert any effort in setting the default value for the coin's data
            let coin = Coin()
            
            if valueField.text != nil && valueField.text! != ""
            {
                //we have some valid valueField text representing the coin's value
                coin.setValue(newValue: NSNumber(value: Int(valueField.text!)!))
            }
            
            if countryField.text != nil && countryField.text! != ""
            {
                //we have some valid countryField text representing the country 
                //that the coin was minted in
                coin.setCountry(c: trimWhiteSpaceAndRemoveLastPunctuation(str: countryField.text!)! as NSString)
            }
            
            if denominationField.text != nil && denominationField.text! != ""
            {
                //we have some valid denominationField text representing
                //the denomination/currency of the coin
                coin.setDenomination(newValue: trimWhiteSpaceAndRemoveLastPunctuation(str: denominationField.text!)! as NSString)
            }
            
            if mintField.text != nil && mintField.text! != ""
            {
                //we have some valid mintField text representing the 
                //mint that produced this coin
                coin.setMint(newMint: trimWhiteSpaceAndRemoveLastPunctuation(str:mintField.text!)! as NSString)
            }
            
            if yearField.text != nil && yearField.text! != ""
            {
                //we have some valid yearField text representing
                //the year that the coin was made in...
                //Of course, the year can be CE or BCE
                if beforeOrAfterZeroADChooser.titleForSegment(at:
                    beforeOrAfterZeroADChooser.selectedSegmentIndex) ==  TimePeriods.BCE.rawValue
                {
                    //the user has selected a BCE year
                    let result = -1 * Int(yearField.text!)!
                    coin.setYear(newValue: result as NSNumber)
                }
                else
                {
                    //the user has selected a CE year
                    //the text of the selected segment should equal the TimePeriods.CE.rawValue string
                    let result = Int(yearField.text!)!
                    coin.setYear(newValue: result as NSNumber)
                }
            }
            
            if gradeField.text != nil && gradeField.text! != ""
            {
                //we have some valid gradeField text representing
                //the coin's grade [we know that it is in a valid range]
                coin.setGrade(newValue: NSNumber(value: Int(gradeField.text!)!))
            }
            
            if commentField.text != nil && commentField.text! != "" && commentField.text! != DEFAULT_NO_COMMENTS_TEXT
            {
                //we have some valid commentField text that is
                //composed of the user's comments about the coin...
                coin.setComments(newComments: trimWhiteSpaceAndRemoveLastPunctuation(str: commentField.text!)! as NSString)
            }
            
            if numberField.text != nil && numberField.text! != ""
            {
                //we have some valid numberField text that is 
                //a number representing how many instances of this coin a user has
                coin.setNumInstances(newValue: NSNumber(value: Int(numberField.text!)!))
            }
            
            if descriptionField.text != nil && commentField.text! != "" && descriptionField.text! != DEFAULT_NO_DESCRIPTION_TEXT
            {
                //we have valid descriptionField text that is
                //a description of what is engraved onto the coin
                coin.setDescriptiveName(newValue: trimWhiteSpaceAndRemoveLastPunctuation(str: descriptionField.text!)! as NSString)
            }
            
            //we now set the images for the coin
            if obverseImageView.image != nil && obverseImageView.image! != #imageLiteral(resourceName: "photoalbum")
            {
                coin.setObverseImage(newImage: obverseImageView.image!)
            }
            
            if reverseImageView.image != nil && reverseImageView.image! != #imageLiteral(resourceName: "photoalbum")
            {
                coin.setReverseImage(newImage: reverseImageView.image!)
            }
            
            //ok now since we have saved all the appropriate information from the fields into the coin
            return coin
            
        }
        else
        {
            return nil
        }
    }
    
    private func trimWhiteSpaceAndRemoveLastPunctuation(str: String?) -> String?
    {
        //this function removes leading and trailing whitespace from an entered
        //string and also removes any punctuation from the last character in the string
        if str != nil
        {
            var toReturn = str!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
            if toReturn.characters.count > 0 &&
                CharacterSet.punctuationCharacters.contains(UnicodeScalar("\(toReturn.characters.last!)")!)
            {
                //in other words, the last character in the string is a punctuation character
                toReturn = toReturn.substring(to: toReturn.index(before: toReturn.endIndex))
            }
        
            return toReturn
        }
        
        else
        {
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "presentCoinObverse"
        {
            let destination = segue.destination as! CoinImageScrollViewController
            let destinationTitle = Coin.OBVERSE_IMAGE_STRING
            destination.modalPresentationStyle = .overCurrentContext
            
            if self.coinToEdit!.getObverseImage() != nil
            {
                destination.imageToPresent = self.coinToEdit!.getObverseImage()!
                destination.titleOfNavigationItem = destinationTitle as String!
            }
            else
            {
                destination.imageToPresent = #imageLiteral(resourceName: "photoalbum")
                destination.titleOfNavigationItem = destinationTitle as String!
            }
        }
        else if segue.identifier == "presentCoinReverse"
        {
            let destination = segue.destination as! CoinImageScrollViewController
            let destinationTitle: String = Coin.REVERSE_IMAGE_STRING as String
            
            destination.modalPresentationStyle = .overCurrentContext
            if self.coinToEdit!.getReverseImage() != nil
            {
                destination.imageToPresent = self.coinToEdit!.getReverseImage()!
                destination.titleOfNavigationItem = destinationTitle
            }
            else
            {
                destination.imageToPresent = #imageLiteral(resourceName: "photoalbum")
                destination.titleOfNavigationItem = destinationTitle
            }
        }
    }
}
