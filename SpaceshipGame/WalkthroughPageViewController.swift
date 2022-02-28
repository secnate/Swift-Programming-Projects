//
//  WalkthroughPageViewController.swift
//  SpaceshipGame
//
//  Created by Nathan Pavlovsky on 8/16/17.
//  Copyright © 2017 NathanPavlovsky. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource
{
    var pageImages = ["Intro","Avoid Enemies","Score","Torpedo-1","Settings-1","Collision"]
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        dataSource = self
        
        //create first walkthrough screen 
        if let startingViewController = contentViewController(at: 0)
        {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        
        return contentViewController(at: index)
    }
    
    //helper method
    func contentViewController(at index : Int) -> WalkthroughContentViewController?
    {
        if index < 0 || index >= pageImages.count
        {
            return nil
        }
        
        //we create a new view controller and pass the needed information
        if let pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController
        {
            pageContentViewController.index = index
            pageContentViewController.imageFile = pageImages[index]
            
            return pageContentViewController
        }
        
        //nothing happened
        return nil
    }
    
    func forward(index : Int)
    {
        if let nextViewController = contentViewController(at: index + 1)
        {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}
