//
//  GameScene.swift
//  Pong
//
//  Created by Nathan Pavlovsky on 8/2/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var ball = SKSpriteNode()
    var enemy = SKSpriteNode()
    var main = SKSpriteNode()
    
    var topLabel = SKLabelNode()
    var bottomLabel = SKLabelNode()
    
    var score = [Int]() //array of the scores [MY SCORE, ENEMY SCORE]
    
    private let ballHitsPaddleSound = SKAction.playSoundFileNamed("ballHit.wav", waitForCompletion: false)
        
    override func didMove(to view: SKView)
    {
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        enemy = self.childNode(withName: "enemy") as! SKSpriteNode
        main = self.childNode(withName: "main") as! SKSpriteNode
        
        topLabel = self.childNode(withName: "topLabel") as! SKLabelNode
        bottomLabel = self.childNode(withName: "bottomLabel") as! SKLabelNode
        
        //we adjust the positions of the sprites
        enemy.position.y = (self.frame.height/2) - 50
        main.position.y = (-self.frame.height/2) + 50
        
        //we add the border to physics to limit the ball
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        self.physicsWorld.contactDelegate = self
        
        startGame()
    }
    
    func startGame()
    {        score = [0,0]
        topLabel.text = "\(score[1])"
        bottomLabel.text = "\(score[0])"
        
        //we launch the ball!
        ball.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
    }
    
    func addScore(playerWhoWon : SKSpriteNode)
    {
        //we update the players' scores, reset ball position, and we send the ball rollin' with a different impulse!
        
        //we reset the ball to the center and we do not have it moving before we give it an impulse
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        //we randomize the velocities of the ball so things will not stay boring
        if playerWhoWon == main
        {
            score[0] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: randRange(lower: 10, upper: 15), dy: randRange(lower: 10, upper: 15)))
        }
        else if playerWhoWon == enemy
        {
            score[1] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: -1 * randRange(lower: 10, upper: 15), dy: -1 * randRange(lower: 10, upper: 15)))
        }
        
        topLabel.text = "\(score[1])"
        bottomLabel.text = "\(score[0])"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        //we move the main paddle in response to the user moving/touching his finger
        for touch in touches
        {
            let location = touch.location(in: self)
            
            if currentGameType == GameTypes.Player2
            {
                //we move the paddles for each player respectively
                if location.y > 0 //the finger is above the center of the screen
                {
                    enemy.run(SKAction.moveTo(x: location.x, duration: 0.01))
                }
                if location.y < 0 //the finger is below the center of the screen
                {
                    main.run(SKAction.moveTo(x: location.x, duration: 0.01))
                }
            }
            else
            {
                //any other game type
                main.run(SKAction.moveTo(x: location.x, duration: 0.01))
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        //we move the main paddle in response to the user moving/touching his finger
        self.touchesBegan(touches, with: event)
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        //we move the enemy paddle to follow the ball's motion (with a slight delay)
        switch currentGameType
        {
        case .Easy:
            enemy.run(SKAction.moveTo(x: ball.position.x, duration: 1.3))
            break
            
        case .Medium:
            enemy.run(SKAction.moveTo(x: ball.position.x, duration: 1.0))
            break
            
        case .Hard:
            enemy.run(SKAction.moveTo(x: ball.position.x, duration: 0.7))
            break
            
        case .Player2:
            break
            
        }
        
        //we test the ball's positions for score updating
        if ball.position.y <= main.position.y - 30
        {
            addScore(playerWhoWon: enemy)
        }
        else if ball.position.y >= enemy.position.y + 30
        {
            addScore(playerWhoWon: main)
        }
        
        //we prevent the ball from moving only horizontally
        if abs(Double((ball.physicsBody?.velocity.dy)!)) < 5
        {
            if ball.position.y > 0
            {
                //the ball is on the "enemy side"
                ball.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
            }
            else
            {
                //the ball is on the "main side"
                ball.physicsBody?.applyImpulse(CGVector(dx: -10, dy: -10))
            }
        }
    }
    
    func didBegin(_ contact : SKPhysicsContact)
    {
        let firstBody: SKPhysicsBody! = contact.bodyA
        let secondBody: SKPhysicsBody! = contact.bodyB
        
        // An SKPhysicsContact object is created when 2 physics bodies make contact,
        // and those bodies are referenced by its bodyA and bodyB properties.
        // We want to sort these bodies by their bitmasks so that it's easier
        // to identify which body belongs to which sprite.
        
        if (firstBody == ball.physicsBody)
        {
            if secondBody == self.main.physicsBody || secondBody == self.enemy.physicsBody
            {
                //the ball and the a paddle have collided
                playContactSound()
            }
        }
        else if (secondBody == ball.physicsBody)
        {            if firstBody == self.main.physicsBody || firstBody == self.enemy.physicsBody
            {
                //the ball and a paddle have collided
                playContactSound()
            }
        }
    }
    
    func playContactSound()
    {
        if UserDefaults.standard.bool(forKey: GameViewController.KEY_FOR_SOUND_PLAY) == true
        {
            self.run(ballHitsPaddleSound)
        }
    }
    
    private func randRange (lower: Int , upper: Int) -> Int
    {
        //we return a random number within the specified
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}
