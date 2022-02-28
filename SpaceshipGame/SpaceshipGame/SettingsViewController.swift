//
//  SettingsViewController.swift
//  SpaceshipGame
//
//  Created by Nathan Pavlovsky on 8/7/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This view controller is responsible for configuring the settings of the game

import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet var playBackgroundMusicSwitch : UISwitch!
    
    @IBOutlet var soundEffectsSwitch : UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.playBackgroundMusicSwitch.isOn = UserDefaults.standard.bool(forKey: GameViewController.SHOULD_BACKGROUND_MUSIC_KEY)
        self.soundEffectsSwitch.isOn = UserDefaults.standard.bool(forKey: GameViewController.SOUND_EFFECTS_KEY)
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToGame()
    {
        //first we need to save changes
        UserDefaults.standard.set(playBackgroundMusicSwitch.isOn, forKey: GameViewController.SHOULD_BACKGROUND_MUSIC_KEY)
        UserDefaults.standard.set(soundEffectsSwitch.isOn, forKey: GameViewController.SOUND_EFFECTS_KEY)
        
        self.performSegue(withIdentifier: "returnToGame", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
