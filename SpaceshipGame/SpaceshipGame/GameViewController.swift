//
//  GameViewController.swift
//  SpaceshipGame
//
//  Created by Nathan Pavlovsky on 8/4/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

enum Levels
{
    //an enumeration of all the possible levels of the game
    case EASY
    case MEDIUM
    case HARD
}

class GameViewController: UIViewController
{
    static let SHOULD_BACKGROUND_MUSIC_KEY = "backgroundMUSIC"
    static let SOUND_EFFECTS_KEY = "soundEffects"
    
    static let EASY_LEVEL_HIGH_SCORE_KEY = "easyHighScore"
    static let MEDIUM_LEVEL_HIGH_SCORE_KEY = "mediumHighScore"
    static let HARD_LEVEL_HIGH_SCORE_KEY = "highHighScore"
    
    private var theScene : GameScene!
    
    static public var levelSelected : Levels = .EASY    //just a dummy value that will be replaced when we start the game
    
    //this is the tuple of the data that we will pass from the game scene to the game over view controller
    //The format is this: [ NUMBER_OF_ALIENS_SHOT, NUMBER_OF_TORPEDOS ]
    var tupleToPass : (Int, Int) = (0,0)
    
    //this is how long the game has lasted
    var timeInterval : TimeInterval = TimeInterval()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let view = self.view as! SKView?
        {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene")
            {
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                //we make the game adaptable to devices of all screen sizes
                scene.size = view.bounds.size
                
                self.theScene = scene as! GameScene
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            /*view.showsFPS = true
            view.showsNodeCount = true*/ //we do not want these statistics to show up during game play, only debugging
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
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
    
    //MARK: - Segues
    
    @IBAction func returnToGameVC(segue : UIStoryboardSegue)
    {
        //we resume the game
        (self.view as! SKView).isPaused = false
        GameScene.isShowingSettings = false
        
        self.theScene.startOrStopBackgroundMusic()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "presentSettingsMenu"
        {
            //we pause the game
            (self.view as! SKView).isPaused = true
            GameScene.isShowingSettings = true
        }
        
        else if segue.identifier == "showGameOver"
        {
             let destination = segue.destination as! GameOverViewController
            
            destination.numberAliensKilled = tupleToPass.0
            destination.numberTorpedosFired = tupleToPass.1
            destination.timeElapsed = self.timeInterval
        }
    }
}
