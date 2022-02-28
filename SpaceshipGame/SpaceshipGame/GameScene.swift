//
//  GameScene.swift
//  SpaceshipGame
//
//  Created by Nathan Pavlovsky on 8/4/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

extension SKView
{
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension Double
{
    private static let arc4randomMax = Double(UInt32.max)
    
    static func random0to1() -> Double
    {
        //generate a random decimal in between 0 and 1
        return Double(arc4random()) / arc4randomMax
    }
}
/*
CREATE A LIMITED NUMBER OF TROPEDOS THAT ARE RECHARGABLE
NOW FOR THE GAME, create rechargable torpedos*/

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var levelSelected : Levels = Levels.EASY //default level is "EASY"
    
    static var BACKGROUND_MUSIC_NAME = "background_music"
    
    var starField : SKEmitterNode!
    var player : SKSpriteNode!
    
    var timeElapsedLabel : SKLabelNode!
    var timeElasped : Float = 0.000
    {
        didSet
        {
            timeElapsedLabel.text = "Score: " + String.localizedStringWithFormat("%.3f", timeElasped)
        }
    }
    
    //this is used to deliniate the start of the game
    var startTime : Date!
    
    var score : Int = 0
    
    var torpedoCount : Int = 0
    
    //we give the spaceship a limited number of torpedos and we allow them to regenerate over a certain period of time
    var numTorpedosAvailable : Int = 0
    {
        didSet
        {
            self.torpedoAvailableLabel.text = "Torpedos: " + String.init(repeating: "◉ ", count: numTorpedosAvailable)
        }
    }
    var maximumNumberOfTorpedosAvailable : Int = 5  //that is the upper limit of the number of torpedos we can add
    var torpedoAvailableLabel : SKLabelNode!
    var addTorpedoTimer : Timer!
    
    var gameTimer : Timer!
    
    //this is the timer responsible for allowing the time changes to update
    var timeIncrementTimer : Timer!
    var currentTime : Date = Date() //this is the time that is "now" which is later than the startTime
    var timeInterval : TimeInterval!
    {
        didSet
        {
            self.timeElapsedLabel.text = "Score: " + String.localizedStringWithFormat("%.3f", timeInterval)

        }
    }//measures the time difference between the start and end times
    
    //array of the different alien types possible
    //we repeat each of the aliens a different number of times to ensure that we have some aliens that are more common and some that are less common
    var possibleAliens = ["alien","alien2","alien3","rocket"]
    
    let alienCategory : UInt32 = 0x1 << 1
    let photonTorpedoCategory : UInt32 = 0x1 << 0
    let spaceshipCategory : UInt32 = 0x1 << 2
    
    var motionManager = CMMotionManager()
    var xAcceleration: CFloat = 0
    
    static var isShowingSettings : Bool = false
    
    override func didMove(to view: SKView)
    {
        //we initialize everything...
        self.levelSelected = GameViewController.levelSelected
        
        //first we configure whether the background music should be played
        if UserDefaults.standard.object(forKey: GameViewController.SHOULD_BACKGROUND_MUSIC_KEY) == nil
        {
            //if this is the first time that we are opening this scene, we start playing music by default
            UserDefaults.standard.set(true, forKey: GameViewController.SHOULD_BACKGROUND_MUSIC_KEY)
        }
        
        //configure the sound effects
        if UserDefaults.standard.object(forKey: GameViewController.SOUND_EFFECTS_KEY) == nil
        {
            UserDefaults.standard.set(true, forKey: GameViewController.SOUND_EFFECTS_KEY)
        }
        
        //we then configure the star field
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: 0, y: self.frame.size.height/2)
        
        //we speed up the starField's motion
        starField.advanceSimulationTime(10)
        self.addChild(starField)
        
        //we set the starField behind every other sprite now!
        starField.zPosition = -1
        
        //we now create the player
        //we do not add a physics body to the player since it is not supposed to interact with any other objects in the game
        player = SKSpriteNode(imageNamed: "shuttle")
        let playerTexture = SKTexture(imageNamed: "shuttle")
        player.position = CGPoint(x: 0, y: -1 * (self.frame.height/2 - self.player.size.height))
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = spaceshipCategory
        player.physicsBody?.contactTestBitMask = alienCategory
        player.physicsBody?.collisionBitMask = 0
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        //we create the labels
        
        //time elapsed label
        timeElapsedLabel = SKLabelNode(text: "Time Elasped: 0.000")
        timeElapsedLabel.position = CGPoint(x: (-1 * self.frame.width/2) + 5, y: self.frame.height/2 - (timeElapsedLabel.frame.height/2) - 5)
        timeElapsedLabel.fontName = "AmericanTypewriter-Bold"
        timeElapsedLabel.fontSize = 20
        timeElapsedLabel.fontColor = UIColor.white
        timeElapsedLabel.horizontalAlignmentMode = .left
        timeElapsedLabel.zPosition = 1
        timeElasped = 0.000
        self.addChild(timeElapsedLabel)
       
        //set up the score
        score = 0
        
        //torpedo available label
        torpedoAvailableLabel = SKLabelNode(text: "Torpedos: ")
        torpedoAvailableLabel.position = CGPoint(x: self.timeElapsedLabel.position.x, y: self.timeElapsedLabel.position.y - self.timeElapsedLabel.frame.height - 10)
        torpedoAvailableLabel.fontName = "AmericanTypewriter-Bold"
        torpedoAvailableLabel.fontSize = 20
        torpedoAvailableLabel.fontColor = UIColor.white
        torpedoAvailableLabel.horizontalAlignmentMode = .left
        torpedoAvailableLabel.zPosition = 1
        self.addChild(torpedoAvailableLabel)
        numTorpedosAvailable = self.maximumNumberOfTorpedosAvailable    //we initially start with a full load
        
        //we now create a timer for regenerating a torpedo
        //and we vary the times based on
        var theTimeInterval : TimeInterval = 0
        switch self.levelSelected
        {
        case .EASY:
            theTimeInterval = 5
            break
        case .MEDIUM:
            theTimeInterval = 10
            break
        case .HARD:
            theTimeInterval = 15
            break
        }
        self.addTorpedoTimer = Timer.scheduledTimer(timeInterval: theTimeInterval, target: self, selector: #selector(addTorpedo), userInfo: nil, repeats: true)
        
        //we now monitor the changes in time
        self.startTime = Date()
        self.timeIncrementTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimeInterval), userInfo: nil, repeats: true)
        
        //create enemies for the game
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        //we now initialize the motion manager to move the spaceship
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!)
        {
            (data : CMAccelerometerData?,error : Error?) in
            if let accelerometerData = data
            {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = Float(CGFloat(acceleration.x) * 0.75) + self.xAcceleration * 0.25
            }
        }
        
        
        //we start playing the background background music
        startOrStopBackgroundMusic()
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        // Called before each frame is rendered
    }
    
    func startOrStopBackgroundMusic()
    {
        if UserDefaults.standard.bool(forKey: GameViewController.SHOULD_BACKGROUND_MUSIC_KEY) == true
        {
            //we play the music
            if let musicURL = Bundle.main.url(forResource: "background", withExtension: "mp3")
            {
                let backgroundMusic = SKAudioNode(url: musicURL)
                backgroundMusic.name = GameScene.BACKGROUND_MUSIC_NAME
                addChild(backgroundMusic)
            }
        }
        else
        {
            if let backgroundMusic = self.childNode(withName: GameScene.BACKGROUND_MUSIC_NAME) as? SKAudioNode
            {
                //we stop playing the music if it had been already playing
                backgroundMusic.removeFromParent()
            }
        }
    }
    
    func addTorpedo()
    {
        if self.numTorpedosAvailable < self.maximumNumberOfTorpedosAvailable
        {
            self.numTorpedosAvailable += 1
        }
    }
    
    func updateTimeInterval()
    {
        //we update the time interval
        self.currentTime = Date()
        
        self.timeInterval = self.currentTime.timeIntervalSince(self.startTime)  //difference in seconds
        
    }
    
    func addAlien()
    {
        //we add an alien
        
        //we choose a random alien
        if GameScene.isShowingSettings == false
        {
            possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
            let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
            let randomAlienPosition = GKRandomDistribution(lowestValue: Int(-1 * self.frame.width/2.0 + alien.size.width), highestValue: Int(self.frame.width/2.0 - alien.size.width))
            let position = CGFloat(randomAlienPosition.nextInt())
        
            alien.position = CGPoint(x: position,y: self.frame.size.height/2 + alien.size.height)
            alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
            alien.physicsBody?.isDynamic = true
            
            alien.physicsBody?.categoryBitMask = alienCategory
            alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
            alien.physicsBody?.collisionBitMask = 0
            
            //we make sure that the alien is behind the spaceship
            alien.zPosition = 0
            
            self.addChild(alien)
            
            //we make each alien have a random animation time
            //we can actually vary the times depending on the level that we want the user to play and make the speeds of the aliens smaller or greater
            var animationDuration : TimeInterval
            
            switch self.levelSelected
            {
            case .EASY:
                animationDuration = TimeInterval(1 + arc4random()%4) //random number 1-4
                break
            case .MEDIUM:
                animationDuration = TimeInterval(0.5 + Double(arc4random()%2) + Double.random0to1()) //random number 0-1 + 0.5 + random decimal end
                break
            case .HARD:
                animationDuration = TimeInterval(Double.random0to1() + 0.5) //random number 0-1 + 0.5
                break
            }
            //////////////////////////////////////////////////
            
            var actionArray = [SKAction]()
            actionArray.append(SKAction.move(to: CGPoint(x: position,y: (-1 * self.frame.height/2) - alien.size.height), duration: animationDuration))
            actionArray.append(SKAction.removeFromParent())
            
            alien.run(SKAction.sequence(actionArray))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        fireTorpedo()
    }
    
    func fireTorpedo()
    {
        if self.numTorpedosAvailable > 0
        {
            if UserDefaults.standard.bool(forKey: GameViewController.SOUND_EFFECTS_KEY) == true
            {
                self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
            }
        
            let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
            torpedoNode.position = player.position
            torpedoNode.position.y -= 5
            torpedoNode.zPosition = 0
            
            torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width/2)
            torpedoNode.physicsBody?.isDynamic = true
            
            torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
            torpedoNode.physicsBody?.contactTestBitMask = alienCategory
            torpedoNode.physicsBody?.collisionBitMask = 0
        
            torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
            self.addChild(torpedoNode)
        
            //we update the torpedo count and the torpedo label
            torpedoCount += 1
        
            let animationDuration : TimeInterval = 0.3
        
            var actionArray = [SKAction]()
            actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height/2 + 10), duration: animationDuration))
            actionArray.append(SKAction.removeFromParent())
        
            torpedoNode.run(SKAction.sequence(actionArray))
            
            //we decrement the number of torpedos available
            self.numTorpedosAvailable -= 1
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        //we assign the respective bodies to the variables
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0
        {
            //we check to make sure that we can actually cast bodyOne and bodyTwo as the SKSprite nodes
            //so we can call the torpedoDidCollideWithAlien without crashing
            let bodyOne = (firstBody.node as? SKSpriteNode)
            let bodyTwo = (secondBody.node as? SKSpriteNode)
            if bodyOne != nil && bodyTwo != nil
            {
                torpedoDidCollideWithAlien(torpedoNode: bodyOne!, alien: bodyTwo!)
            }
        }
        else if (secondBody.categoryBitMask & spaceshipCategory) != 0 && (firstBody.categoryBitMask & alienCategory) != 0
        {
            //the player's spaceship and the alien have collided
            let bodyOne = firstBody.node as? SKSpriteNode
            let bodyTwo = secondBody.node as? SKSpriteNode
            
            if bodyOne != nil && bodyTwo != nil
            {
                spaceshipDidCollideWithAlien(spaceshipNode: bodyTwo!, alienNode: bodyOne!)
            }
        }
    }
    
    func spaceshipDidCollideWithAlien(spaceshipNode: SKSpriteNode, alienNode: SKSpriteNode)
    {
        //we kill off the spaceship and the alien and leave only the explosion
        spaceshipNode.removeFromParent()
        alienNode.removeFromParent()
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")
        explosion?.position = alienNode.position
        self.addChild(explosion!)
        
        if UserDefaults.standard.bool(forKey: GameViewController.SOUND_EFFECTS_KEY) == true
        {
            self.run(SKAction.playSoundFileNamed("megaExplosion.mp3", waitForCompletion: false))
        }
        
        self.run(SKAction.wait(forDuration: 1), completion:
        {
            explosion?.removeFromParent()
            
            self.endGame()
        })
    }
    
    func endGame()
    {
        //we pause the game and then display a game over message
        self.view?.isPaused = true
        
        let gameVC = (self.view?.parentViewController as? GameViewController)
        if gameVC != nil
        {
            //we take the user to the game over screen from that view controller and display their stats!
            gameVC!.tupleToPass = (self.score,self.torpedoCount)
            gameVC!.timeInterval = self.timeInterval
            gameVC!.performSegue(withIdentifier: "showGameOver", sender: gameVC)
        }
    }
    
    func torpedoDidCollideWithAlien(torpedoNode: SKSpriteNode, alien: SKSpriteNode)
    {
        let explosion = SKEmitterNode(fileNamed: "Explosion")
        explosion?.position = alien.position
        self.addChild(explosion!)
        
        if UserDefaults.standard.bool(forKey: GameViewController.SOUND_EFFECTS_KEY) == true
        {
            self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        }
        
        //we kill off the torpedo and the alien
        torpedoNode.removeFromParent()
        alien.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2), completion: {
            explosion?.removeFromParent()
        })
        
        score += 1
    }
    
    override func didSimulatePhysics()
    {
        player.position.x += CGFloat(xAcceleration * 50)
        
        if player.position.x < -self.size.width/2 - 20
        {
            player.position = CGPoint(x: self.size.width/2 + 20, y: player.position.y)
        }
        else if player.position.x > self.size.width/2 + 20
        {
            player.position = CGPoint(x: -self.size.width/2 - 20, y: player.position.y) 
        }
    }
}
