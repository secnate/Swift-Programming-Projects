//
//  GameOverViewController.swift
//  SpaceshipGame
//
//  Created by Nathan Pavlovsky on 8/8/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This is the view controller responsible for presenting a "Game Over"
//  message to the user and displaying certain game-related statistics
import UIKit

class GameOverViewController: UIViewController
{
    @IBOutlet var aliensKilledLabel : UILabel!
    @IBOutlet var torpedosFiredLabel : UILabel!
    @IBOutlet var aliensKilledPerTorpedoLabel : UILabel!
    @IBOutlet var timeElapsedLabel : UILabel!
    
    @IBOutlet var highScoreView : UIView!
    @IBOutlet var timeElapsedHighScoreLabel : UILabel!
    
    @IBOutlet var scoreboardEasyLevelLabel : UILabel!
    @IBOutlet var scoreboardMediumLevelLabel : UILabel!
    @IBOutlet var scoreboardHardLevelLabel : UILabel!
    
    ////////////////////////////////////////
    var levelPlayed : Levels!
    var numberAliensKilled : Int = 0
    var numberTorpedosFired : Int = 0
    var timeElapsed : TimeInterval = TimeInterval()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        aliensKilledLabel.text = "Aliens Killed: \(self.numberAliensKilled)"
        torpedosFiredLabel.text = "Torpedos Fired: \(numberTorpedosFired)"
        timeElapsedLabel.text = "Time Elapsed: " + String.localizedStringWithFormat("%.3f", timeElapsed)
        
        //we want to prevent situations where we have 0 divided by 0 or any such division by 0 and then having a "null" [or such] result appear in the label
        let calculatedRatio = (numberTorpedosFired == 0 || numberAliensKilled == 0) ? 0 : Float(numberTorpedosFired) / Float(numberAliensKilled)
        aliensKilledPerTorpedoLabel.text =  "Torpedos Per Alien: " + String.localizedStringWithFormat("%.3f", calculatedRatio)
        
        
        //we now present the high score if needed
        var shouldPresentHighScoreWindow : Bool = false
        
        //we now find the key for the appropriate level
        var keyToSaveScore : String = ""
        switch GameViewController.levelSelected
        {
        case Levels.EASY:
            keyToSaveScore = GameViewController.EASY_LEVEL_HIGH_SCORE_KEY
            break
            
        case Levels.MEDIUM:
            keyToSaveScore = GameViewController.MEDIUM_LEVEL_HIGH_SCORE_KEY
            break
            
        case Levels.HARD:
            keyToSaveScore = GameViewController.HARD_LEVEL_HIGH_SCORE_KEY
            break
        }
        
        //we now configure the scores
        if UserDefaults.standard.object(forKey: keyToSaveScore) == nil
        {
            //we haven't saved a high score
            //this score [which is the time elapsed] is the new value
            UserDefaults.standard.set(timeElapsed, forKey: keyToSaveScore)
            shouldPresentHighScoreWindow = true
        }
        else
        {
            //we have saved a high score... we now need to compare this current game's score to the high score and decide if this game broke the record
            if self.timeElapsed > UserDefaults.standard.double(forKey: keyToSaveScore)
            {
                //we update the score
                UserDefaults.standard.set(timeElapsed, forKey: keyToSaveScore)
                shouldPresentHighScoreWindow = true
            }
        }
        
        //now we hide the high score window if we don't need to show it, or we configure it if we we do
        if shouldPresentHighScoreWindow == true
        {
            self.timeElapsedHighScoreLabel.text = "Score: " + String.localizedStringWithFormat("%.3f", timeElapsed)
        }
        else
        {
            //we hide the view
            self.highScoreView.isHidden = true
        }
        
        //now we configure the scoreboard
        configureScoreboard()
    }
    
    func configureScoreboard()
    {
        //we configure the scoreboard
        if UserDefaults.standard.object(forKey: GameViewController.EASY_LEVEL_HIGH_SCORE_KEY) == nil
        {
            scoreboardEasyLevelLabel.text = "・Easy: Level Not Played"
        }
        else
        {
            scoreboardEasyLevelLabel.text = "・Easy: " + String.localizedStringWithFormat("%.3f", UserDefaults.standard.double(forKey: GameViewController.EASY_LEVEL_HIGH_SCORE_KEY))
        }
        
        if UserDefaults.standard.object(forKey: GameViewController.MEDIUM_LEVEL_HIGH_SCORE_KEY) == nil
        {
            scoreboardMediumLevelLabel.text = "・Medium: Level Not Played"
        }
        else
        {
            scoreboardMediumLevelLabel.text = "・Medium: " + String.localizedStringWithFormat("%.3f", UserDefaults.standard.double(forKey: GameViewController.MEDIUM_LEVEL_HIGH_SCORE_KEY))
        }
        
        if UserDefaults.standard.object(forKey: GameViewController.HARD_LEVEL_HIGH_SCORE_KEY) == nil
        {
            scoreboardHardLevelLabel.text = "・Hard: Level Not Played"
        }
        else
        {
            scoreboardHardLevelLabel.text = "・Hard: " + String.localizedStringWithFormat("%.3f", UserDefaults.standard.double(forKey: GameViewController.HARD_LEVEL_HIGH_SCORE_KEY))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    @IBAction func returnToHomeScreen()
    {
        self.performSegue(withIdentifier: "goToHomeMenu", sender: self)
    }
}
