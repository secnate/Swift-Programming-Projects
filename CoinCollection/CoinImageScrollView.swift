//
//  CoinImageScrollView.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 6/16/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This view was created to allow the user to examine a 
//  photographs of the coin while pinching in and out

import UIKit

class CoinImageScrollViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet var navigationBar: UINavigationItem!
    @IBOutlet var navigationBarHeightConstraint : NSLayoutConstraint!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var photoButton: UIBarButtonItem!
    
    var imageToPresent: UIImage! = #imageLiteral(resourceName: "photoalbum")    //this is the default image
    var titleOfNavigationItem: String!
    
    override func viewDidLoad()
    {
        self.navigationBar.title = titleOfNavigationItem
        scrollView.backgroundColor = .white
        imageView.image = imageToPresent
        imageView.contentMode = .scaleAspectFill
        scrollView.delegate = self
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return imageView
    }
    
    @IBAction func close()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getPhoto()
    {
        //we have activated the camera button.
        //the user wants to change the image
        let optionsMenu = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        //we offer a few options to the user
        optionsMenu.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (nil) -> Void in self.presentCamera()}))
        optionsMenu.addAction(UIAlertAction(title: "Album", style: .default, handler: { (nil) -> Void in self.presentAlbum()}))
            
        if optionsMenu.popoverPresentationController != nil
        {
            //we are presenting this options Menu modally
            //most likely it is on an iPad.
            //
            //We present it from the photoButton
            optionsMenu.popoverPresentationController?.barButtonItem = self.photoButton
        }
        else
        {
            //we are presenting this options menu over
            //the entire screen - most likely on iPhone
            optionsMenu.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        }
        
        //AND WE PRESENT.
        present(optionsMenu, animated: true, completion: nil)
    }
    
    func presentCamera()
    {
        //the user wants to take a photograph of a coin
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            
            //we bind the imagePicker to this class so we can control it
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func presentAlbum()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            
            //we bind the imagePicker to this class so we can control it
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        //we finished picking out the image
        //now we save everything!
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            self.imageView.image = selectedImage
            
            //we now save the change in image throughout the app
            let parent = self.presentingViewController as! SpecificCoinChecklistViewController
            let theCoin = parent.specificCoin!
            
            if self.navigationBar.title == Coin.OBVERSE_IMAGE_STRING as String
            {
                //we are saving an obverse image
                theCoin.setObverseImage(newImage: selectedImage)
                
                //we save the coin data throughout the app
                parent.updateCoinInformation(c: theCoin)
            }
            else if self.navigationBar.title == Coin.REVERSE_IMAGE_STRING as String
            {
                //we are saving a reverse image
                theCoin.setReverseImage(newImage: selectedImage)
                
                //we save the coin data throughout the app
                parent.updateCoinInformation(c: theCoin)
            }
        }
        
        //we dismiss the imagePicker controller
        dismiss(animated: true, completion: nil)
    }
}
