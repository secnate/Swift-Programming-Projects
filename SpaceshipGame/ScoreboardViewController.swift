//
//  ScoreboardViewController.swift
//  SpaceshipGame
//
//  Created by Nathan Pavlovsky on 8/15/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This is the pop-up view controller that shows the top scores for each levels

import UIKit

class ScoreboardViewController: UIViewController
{
    @IBOutlet var easyScoreLabel : UILabel!
    @IBOutlet var mediumScoreLabel : UILabel!
    @IBOutlet var hardScoreLabel : UILabel!
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let easyScore : Double? = UserDefaults.standard.double(forKey: GameViewController.EASY_LEVEL_HIGH_SCORE_KEY)
        if easyScore != nil
        {
            easyScoreLabel.text = "・Easy Level: " + String.localizedStringWithFormat("%.3f", easyScore!)
        }
        else
        {
            easyScoreLabel.text = "・Easy Level: Level Was Not Played"
        }
        
        let mediumScore : Double?  = UserDefaults.standard.double(forKey: GameViewController.MEDIUM_LEVEL_HIGH_SCORE_KEY)
        if  mediumScore != nil
        {
            mediumScoreLabel.text = "・Medium Level: " + String.localizedStringWithFormat("%.3f", mediumScore!)
        }
        else
        {
            mediumScoreLabel.text = "・Medium Level: Level Was Not Played"

        }
        
        let hardScore : Double? = UserDefaults.standard.double(forKey: GameViewController.MEDIUM_LEVEL_HIGH_SCORE_KEY)
        if hardScore != nil
        {
            hardScoreLabel.text = "・Hard Level: " + String.localizedStringWithFormat("%.3f", hardScore!)
        }
        else
        {
            hardScoreLabel.text = "・Hard Level: Level Was Not Played"
        }
    }
}
