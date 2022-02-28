//
//  WalkthroughPageViewController.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 7/6/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This is the viewcontroller that is responsible 
//  for running the walkthrough for the user
//  opening the app for the first time.

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource
{

    var pageHeadings = ["Personalize","Review","Share","Search","Get Started"]
    
    var pageImages = ["coincollection-intro-1","coincollection-intro-2","coincollection-intro-3","coincollection-intro-4","coincollection-intro-5"]
    
    var pageContent = ["Add Coins and Curate Your Expanding Collection","Review the Coins' Data and Any Recorded Comments With Ease","Share Your Favorite Coins With Friends and the World","Search for More Information About Your Coins Effortlessly","Click DONE and Get Started!"]
                       
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        
        //We create the first walkthrough screen
        if let startingViewController = contentViewController(at: 0)
        {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func contentViewController(at index: Int) -> WalkthroughContentViewController?
    {
        if index  < 0 || index >= pageHeadings.count
        {
            return nil
        }
        
        //Create a new viewcontroller and pass suitable data
        if let pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController
        {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.content = pageContent[index]
            pageContentViewController.index = index
            
            //we also set this view controller's background color so when the user swipes
            //either to the left of the first or the right of the last view controllers,
            //an ugly black bar won't appear.
            self.view.backgroundColor = pageContentViewController.view.backgroundColor
            
            return pageContentViewController
        }
        
        return nil
    }
    
    func forward(index: Int)
    {
        if let nextViewController = contentViewController(at: index+1)
        {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}
