//
//  GameViewController.swift
//  Pong
//
//  Created by Nathan Pavlovsky on 8/2/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

var currentGameType = GameTypes.Medium

class GameViewController: UIViewController {

    //this is the key used to determine if the app can play sound effects
    static let KEY_FOR_SOUND_PLAY = "playsSound"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                scene.size = view.bounds.size
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
            
            if UserDefaults.standard.object(forKey: GameViewController.KEY_FOR_SOUND_PLAY) == nil
            {
                //if this is the the first time opening the app, we set the "playsSounds" to "true" across the app
                UserDefaults.standard.set(true, forKey: GameViewController.KEY_FOR_SOUND_PLAY)
            }
        }
    }

    override var shouldAutorotate: Bool
    {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.portrait
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func showPopoverMenu()
    {
        //we show the menu for the different options that the user has during gameplay
        (self.view as! SKView).isPaused = true
        
        self.performSegue(withIdentifier: "showPopoverMenu", sender: self)
    }
    
    // MARK: - Unwind Segues 
    @IBAction func returnToGame(segue : UIStoryboardSegue)
    {
        //we returnt o the game and continue gameplay
        (self.view as! SKView).isPaused = false
    }
}
