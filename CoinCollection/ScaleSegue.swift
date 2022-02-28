//
//  ScaleSegue.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 6/11/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This is a custom segue responsible for a vertical transition

import UIKit

class ScaleSegue: UIStoryboardSegue
{
    override func perform()
    {
        //we animate the segue
        scale()
    }
    
    func scale()
    {
        //this function deals with a scale animation
        let toViewController = self.destination
        let fromViewController = self.source
        
        //we add needed viewcotnrollers to this container view
        //so that we get a nice transition
        let containerView = fromViewController.view.superview
        
        //point from which we zoom or scale our second view controller
        let originalCenter = fromViewController.view.center
        
        //we now shrink the destination viewcontroller
        toViewController.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        toViewController.view.center = originalCenter
        
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            
            //we scale the destination controller to its original size
            toViewController.view.transform = CGAffineTransform.identity
        }, completion: { success in
            
            //we have the completion closure
            fromViewController.present(toViewController,animated: false, completion: nil)
        })
    }
}

class UnwindScaleSegue: UIStoryboardSegue
{
    override func perform()
    {
        //we animate the segue
        scale()
    }
    
    func scale()
    {
        //this function deals with a scale animation
        let toViewController = self.destination
        let fromViewController = self.source
        
        fromViewController.view.superview?.insertSubview(toViewController.view, at: 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            
            //we scale the destination controller to its original size
            fromViewController.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }, completion: { success in
            
            //we have the completion closure
            fromViewController.dismiss(animated: false, completion: nil)
        })
    }
}
