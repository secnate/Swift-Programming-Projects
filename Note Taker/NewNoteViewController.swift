//
//  NewNoteViewController.swift
//  Note Taker
//
//  Created by Nathan Pavlovsky on 7/25/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This view controller is responsible for the user entering a new note

import UIKit
import AVFoundation

class NewNoteViewController: UIViewController, UITextViewDelegate, AVSpeechSynthesizerDelegate
{

    @IBOutlet weak var heightConstraintOfNavBar : NSLayoutConstraint!
    var heightConstraintConstant : CGFloat = 50
    
    var masterViewController : MasterViewController?
    
    @IBOutlet var cancelButton : UIBarButtonItem!
    
    @IBOutlet var doneButton : UIBarButtonItem!
    
    @IBOutlet var inputField : UITextView!
    
    //this is for the speech-to-text feature of the app
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    @IBOutlet var messageLabel : UILabel!
    
    private static let DEFAULT_INPUT_FIELD_TEXT = "Type Your Note Here..."
    private static let REGULAR_INPUT_FIELD_TEXT_COLOR = UIColor.black
    private static let UNSELECTED_INPUT_FIELD_TEXT_COLOR = UIColor.lightGray
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //We graphically configure the view controller
        self.heightConstraintOfNavBar.constant = heightConstraintConstant
        
        //we configure the input field
        inputField.text = NewNoteViewController.DEFAULT_INPUT_FIELD_TEXT
        setDefaultInputFieldText()
        
        self.inputField.delegate = self
        
        //we configure the message label
        self.messageLabel.text = ""
        
        
        //we configure the synthesizer
        synth.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //we have the possibility that the user clicked the "Edit" button before he clicked the add new button, so we rectify that by setting the editing to false
        //we do not want the animation of the changing of the editing session to be visible while this view controller is appearing [so that is why we do not put it into viewDidLoad()]
        self.masterViewController?.setEditing(false, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TEXT VIEW DELEGATE
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        //we start editing
        if textView.text == NewNoteViewController.DEFAULT_INPUT_FIELD_TEXT
        {
            //we had the default text.. and we start typing!
            textView.text = ""
            textView.textColor = NewNoteViewController.REGULAR_INPUT_FIELD_TEXT_COLOR
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        let clearedStringOfWhitespace = String(textView.text!.characters.filter { $0 != " "})
        if clearedStringOfWhitespace == "" || textView.text == NewNoteViewController.DEFAULT_INPUT_FIELD_TEXT
        {
            setDefaultInputFieldText()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n"
        {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    private func setDefaultInputFieldText()
    {
        inputField.text = NewNoteViewController.DEFAULT_INPUT_FIELD_TEXT
        inputField.textColor = NewNoteViewController.UNSELECTED_INPUT_FIELD_TEXT_COLOR
    }
    
    // MARK: - Button Actions
    
    @IBAction func cancel()
    {
        close()
    }
    
    @IBAction func save()
    {
        //the user wants to (apparently) save the note!
        
        //we need to check if the note can be saved
        let clearedStringOfWhitespace = String(inputField.text!.characters.filter { $0 != " "})
        
        if clearedStringOfWhitespace == "" || inputField.text == NewNoteViewController.DEFAULT_INPUT_FIELD_TEXT
        {
            //the in the input field is whitespace only or the default text.
            //the user did not type anything original for it to be a savable note.
            //we thus need to let the user know of the issue
            let alertToUser = UIAlertController(title: "No Text Entered", message: "You have not entered any non-whitespace text to create a new note.", preferredStyle: UIAlertControllerStyle.alert)
            alertToUser.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertToUser, animated: true, completion: nil)
        }
        else
        {
            self.masterViewController?.resetDetailVC()
            
            //we save the note!!!
            self.masterViewController!.insertNewObject(theNoteText: inputField.text)
            
            self.close()
        }
    }
    
    @IBAction func textToSpeech(sender : UIBarButtonItem)
    {
        myUtterance = AVSpeechUtterance(string: self.inputField.text)
        myUtterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        myUtterance.rate = 0.3
        synth.speak(myUtterance)
    }
    
    private func close()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Synthesizer Delegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance)
    {
        //we wait a bit before presenting a message about the sound
        self.messageLabel.text = "WARNING: This Note is Spoken in the Current Language of Your Device. If You Have Typed the Note in a Different Language, It Might Sound Funny."
        self.messageLabel.backgroundColor = UIColor.yellow
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
    {
        Thread.sleep(forTimeInterval: 0.5)
        self.messageLabel.text = ""
        self.messageLabel.backgroundColor = UIColor.clear
    }
}
