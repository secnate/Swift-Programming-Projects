//
//  SettingConfigureViewController.swift
//  Pong
//
//  Created by Nathan Pavlovsky on 8/3/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This view controller is responsible for allowing the user to configure certain settings
import UIKit

class SettingConfigureViewController: UIViewController {

    @IBOutlet var soundEffectSwitch : UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.soundEffectSwitch.setOn(UserDefaults.standard.bool(forKey: GameViewController.KEY_FOR_SOUND_PLAY), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveChanges()
    {
        //we save changes here
        UserDefaults.standard.set(soundEffectSwitch.isOn, forKey: GameViewController.KEY_FOR_SOUND_PLAY)
        self.performSegue(withIdentifier: "returnToPopoverMenu", sender: self)
    }

}
