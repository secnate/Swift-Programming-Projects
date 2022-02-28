//
//  WebViewController.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 7/9/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  It is responsible for presenting a website inside the app

import UIKit
import WebKit

class WebViewController: UIViewController
{
    var webView : WKWebView!
    
    override func loadView()
    {
        //this function is called before viewDidLaod and we load the webview
        webView = WKWebView()
        webView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        webView.allowsLinkPreview = true
        
        view = webView
        
        //we do not want a black background if the user is zooming in/out
        //of the webView
        self.view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // This is the google docs form for getting the user's feedback
        // currently, it is linked to Nathan Pavlovsky's personal email
        if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSci0zSOsYtpjumH3ePjhLBXqctrVQAAFROr7VyQlLslxWzWXw/viewform?usp=sf_link")
        {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation)
    {
        //when we rotate the device, we need to ensure that the 
        //webview is displayed fully on the screen at the minimum scale
        //as we do not want a rotation to zoom into the website... 
        //with a rotation, we zoom out!!!
        self.webView.scrollView.setZoomScale(self.webView.scrollView.minimumZoomScale, animated: true)
    }
}
