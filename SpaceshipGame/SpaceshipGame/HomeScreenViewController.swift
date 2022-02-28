//
//  HomeScreenViewController.swift
//  SpaceshipGame
//
//  Created by Nathan Pavlovsky on 8/7/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This class is responsible for running the HomeScreenViewController

import UIKit
import AVFoundation

class HomeScreenViewController: UIViewController
{
    @IBOutlet var torpedoImageView : UIImageView!
    @IBOutlet var levelsWindow : UIView!
    @IBOutlet var messageLabel : UILabel!
    @IBOutlet var playSoundButton : UIButton!
    
    
    var shouldAnimateLevelsWindow : Bool = true //the default value is true
    private var showingLevelsWindow : Bool = false
    var selectedLevel : Levels = Levels.EASY    //the default level that we have selected is easy
    
    var audioPlayer : AVAudioPlayer!
    
    override func viewDidAppear(_ animated: Bool)
    {
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough")
        {
            return
        }

        if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughController") as? WalkthroughPageViewController
        {
            present(pageViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //we hide the levels window so that it is not seen
        if self.shouldAnimateLevelsWindow == true
        {
            levelsWindow.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
        else
        {
            //we don't do anything
            self.showingLevelsWindow = true
        }
        
        let path = Bundle.main.url(forResource: "homeScreenMusic", withExtension: "mp3")
        
        do
        {
              audioPlayer = try AVAudioPlayer(contentsOf: path!)
        }
        catch
        {
            print("Error when playing background music: ")
            print(error)
        }
        
        //we make play loop infinitely long until we stop it
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
    
    override var prefersStatusBarHidden : Bool
    {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleSound(_ sender : UIButton)
    {
        //if the sound has been stopped, then we start playing again, and vice versa
        if sender.imageView?.image == #imageLiteral(resourceName: "playingSound")
        {
            //we are going to stop playing sound
            audioPlayer.stop()
            sender.setImage(#imageLiteral(resourceName: "noSound"), for: .normal)
        }
        else if sender.imageView?.image == #imageLiteral(resourceName: "noSound")
        {
            //we are going to start playing sound again
            audioPlayer.play()
            sender.setImage(#imageLiteral(resourceName: "playingSound"), for: .normal)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
      
       let firstTouch = touches.first!
        
       if firstTouch.view?.tag != 100 && self.showingLevelsWindow == false && self.shouldAnimateLevelsWindow
       {
            //the user has not clicked the cancel button, meaning that we want to show the levels selector
            messageLabel.isHidden = true
            torpedoImageView.isHidden = true 
            UIView.animate(withDuration: 1, animations:
            {
                self.levelsWindow.transform = CGAffineTransform.identity
            }, completion:
            { (Bool) in
                self.showingLevelsWindow = true
            })
       }
    }
    
    @IBAction func selectedLevel(_ sender : UIButton)
    {
        if sender.titleLabel?.text == "Easy"
        {
            self.selectedLevel = Levels.EASY
        }
        else if sender.titleLabel?.text == "Medium"
        {
            self.selectedLevel = Levels.MEDIUM
        }
        else if sender.titleLabel?.text == "Hard"
        {
            self.selectedLevel = Levels.HARD
        }
        
        //we start the game
        self.performSegue(withIdentifier: "startGame", sender: self)
    }
    
    @IBAction func showScoreboard()
    {
        self.performSegue(withIdentifier: "showScoreboard", sender: self)
    }
    
    @IBAction func returnToHomeVC(segue : UIStoryboardSegue)
    {
        //we continue playing the sound if the appropriate setting is toggled....
        if self.playSoundButton.imageView?.image == #imageLiteral(resourceName: "playingSound")
        {
            self.audioPlayer.play()
        }
        else
        {
            self.audioPlayer.pause()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //before we transition to another view controller, we stop playing the music there
        self.audioPlayer.stop()
        
        if segue.identifier == "startGame"
        {
            GameViewController.levelSelected = self.selectedLevel
        }
    }
}
