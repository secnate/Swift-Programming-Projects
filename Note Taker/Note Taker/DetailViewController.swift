//
//  DetailViewController.swift
//  Note Taker
//
//  Created by Nathan Pavlovsky on 7/25/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//

import UIKit
import AVFoundation

extension String
{
    //this extension gets the starting indices of the substring inside the larger string
    func indicesOf(subStr: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: subStr, options: .caseInsensitive,range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}

//////////////////////////////////////////////////////////////////////

class DetailViewController: UIViewController, UITextViewDelegate, AVSpeechSynthesizerDelegate, UISearchBarDelegate
{

    @IBOutlet weak var createdLabel : UILabel!
    @IBOutlet weak var modifiedLabel : UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet var searchBar : UISearchBar!
    
    private var currentlyEditing : Bool = false
    
    private var shareButton : UIBarButtonItem!
    private var listenButton : UIBarButtonItem!
    private var doneEditingButton : UIBarButtonItem!
    private var editButton : UIBarButtonItem!
    
    //the following group of variables is for the text-to-sound
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    @IBOutlet var messageLabel : UILabel!
    
    ///////////////////////////////////////////////////////
    private static let DEFAULT_TEXT = "No Note Currently Selected"
    private static let DEFAULT_INFORMATION = ""

    func configureView() {
        // Update the user interface for the detail item.
        noteTextView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        if let detail = detailItem
        {
            if let noteView = noteTextView
            {
                noteView.text = detail.noteText
                noteView.delegate = self
            }
            
            if let creationLabel = createdLabel
            {
                creationLabel.text = "Note Created " + MasterViewController.getDateAndTimeFromString(date: detailItem!.creationDate! as Date)
            }
            
            if let modifLabel = modifiedLabel
            {
                modifLabel.text = "Last Modified " + MasterViewController.getDateAndTimeFromString(date: detailItem!.modifiedDate! as Date)
            }
            
            messageLabel.text = ""
            messageLabel.backgroundColor = .clear
            
            self.navigationItem.setRightBarButtonItems([self.shareButton,self.editButton,self.listenButton], animated: false)
            
            //we now configure the search bar
            self.searchBar.isHidden = false
            self.searchBar.placeholder = "Search this Note..."
        }
        else
        {
            createdLabel.text = ""
            modifiedLabel.text = ""
            
            noteTextView.text = DetailViewController.DEFAULT_TEXT
            noteTextView.textAlignment = .center
            noteTextView.isEditable = false
            
            self.messageLabel.text = ""
            self.messageLabel.backgroundColor = .clear
            
            self.searchBar.isHidden = true
            
            self.navigationItem.setRightBarButtonItems(nil, animated: false)
        }
        
        //we tie the search bar to 'self'
        self.searchBar.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.title = "Selected Note"
        self.noteTextView.isEditable = false
        
        //we create the buttons
        self.shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        self.editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditing))
        self.doneEditingButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toggleEditing))
        
        self.listenButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Speaker"), style: .plain, target: self, action: #selector(textToSpeech))
        
        //we configure the synth
        synth.delegate = self
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Note?

    func reset()
    {
        self.detailItem = nil
        configureView()
    }
    
    // MARK: - UITextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        self.currentlyEditing = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if detailItem != nil
        {
            if detailItem!.noteText != textView.text
            {
                let clearedStringOfWhitespace = String(textView.text!.characters.filter { $0 != " "})
                detailItem!.noteText = clearedStringOfWhitespace != "" ? textView.text : "Type Your Note's Text Here..."
                detailItem!.modifiedDate = NSDate()
                
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
                {
                    appDelegate.saveContext()
                }
            
                configureView()
            }
        }
        
        //we set the editing to false
        self.toggleEditing()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        //we check if the user pressed "Enter" while editing the text inside this
        //text view. If he did, then we stop editing this particular text view
        if text == "\n"
        {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    //MARK: - Bar Button Actions
    func share()
    {
        if self.currentlyEditing == true
        {
            self.noteTextView.resignFirstResponder()
        }
        
        //we have a specific coin whose details are shown in this viewcontroller
        //the user wants to share this coin via social media
        
        let activityViewController = UIActivityViewController(activityItems: [self.noteTextView.text], applicationActivities: [])
        
        if activityViewController.popoverPresentationController != nil
        {
            //we have to present this modally with a popover presentation controller
            activityViewController.popoverPresentationController!.barButtonItem = shareButton
            activityViewController.popoverPresentationController!.permittedArrowDirections = [UIPopoverArrowDirection.up]
        }
    
        //we now present the viewcontroller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func toggleEditing()
    {
        self.noteTextView.isEditable = !self.noteTextView.isEditable
        
        if self.noteTextView.isEditable == true
        {
            self.noteTextView.becomeFirstResponder()
            self.navigationItem.setRightBarButtonItems([self.shareButton,self.doneEditingButton,self.listenButton], animated: false)
            
            self.searchBarCancelButtonClicked(self.searchBar)
        }
        else
        {
            self.noteTextView.resignFirstResponder()
            self.navigationItem.setRightBarButtonItems([self.shareButton,self.editButton,self.listenButton], animated: false)
        }
    }
    
    func textToSpeech()
    {
        myUtterance = AVSpeechUtterance(string: self.noteTextView.text)
        myUtterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        myUtterance.rate = 0.3
        synth.speak(myUtterance)
    }
    
    // MARK: - Synthesizer Delegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance)
    {
        //we wait a bit before presenting a message about the sound
        self.messageLabel.text = "WARNING: This Note is Spoken in the Current Language of Your Device. If You Have Typed this Note in a Different Language, It Might Sound Funny."
        self.messageLabel.backgroundColor = UIColor.yellow
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
    {
        //we finished speaking, and we stop presenting the message 
        Thread.sleep(forTimeInterval: 1)
        self.messageLabel.text = ""
        self.messageLabel.backgroundColor = UIColor.clear
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n"
        {
            searchBar.resignFirstResponder()
        }
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        //we changed the text in the search bar, and we highlight those words that we have in the note
        if searchBar.text != nil
        {
            highlight(toHighlight: searchBar.text!.components(separatedBy: " "))
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        unhighlight()
    }
    
    func highlight(toHighlight : [String])
    {
        //we highlight a certain word/phrase that the user has searched
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: noteTextView.text)
        
        var indices : [Int] = []
        var ranges : [NSRange] = []
        
        for word in toHighlight
        {
            indices = (noteTextView.text).indicesOf(subStr: word)
            
            //we check if the word that we are trying to find to highlight actually exists...
            ranges = indices.map{ NSMakeRange($0, word.characters.count) }
            
            for range in ranges
            {
                attrString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow, range: range)
            }
            
            ranges = []
        }
        attrString.addAttributes([NSFontAttributeName : noteTextView.font!], range: NSMakeRange(0, noteTextView.text.characters.count))
        
        noteTextView.attributedText = attrString
    }
    
    func unhighlight()
    {
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: noteTextView.text)
        attrString.addAttributes([NSFontAttributeName : noteTextView.font!], range: NSMakeRange(0, noteTextView.text.characters.count))
        
        noteTextView.attributedText = attrString
    }
}

