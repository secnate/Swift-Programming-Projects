//
//  MenuVC.swift
//  Pong
//
//  Created by Nathan Pavlovsky on 8/2/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//
//  This view controller controlls the menu!

import Foundation
import UIKit

enum GameTypes
{
    case Player2
    case Easy
    case Medium
    case Hard
}

class MenuVC : UIViewController
{
    
    @IBAction func Player2(_ sender: Any)
    {
        moveToGame(gameType: .Player2)
    }
    
    @IBAction func Easy(_ sender: Any)
    {
        moveToGame(gameType: .Easy)
    }
    
    @IBAction func Medium(_ sender: Any)
    {
        moveToGame(gameType: .Medium)
    }
    
    @IBAction func Hard(_ sender: Any)
    {
        moveToGame(gameType: .Hard)
    }
    
    func moveToGame(gameType : GameTypes)
    {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "GameVC") as! GameViewController
        currentGameType = gameType
        
        self.navigationController?.pushViewController(gameVC, animated: true)
    }
}
