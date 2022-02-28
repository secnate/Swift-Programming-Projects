//
//  AboutTableViewController.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 7/9/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This is the file responsible for running the viewcontroller class

import UIKit
import SafariServices

class AboutTableViewController: UITableViewController {

    var sectionTitles = ["Leave Feedback","Legalese"]
    var sectionContent = [["Rate the App on the App Store","Give Us Direct Feedback"],["Copyright Statement"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        //we do not want the navigation item's back button in a
        //presented View Controller the title of this view controller
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sectionContent[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //we configure the cell...
        cell.textLabel?.text = sectionContent[indexPath.section][indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section
        {
            //Leave us feedback section
        case 0:
            if indexPath.row == 0
            {
                if let url = URL(string: "http://www.apple.com/itunes/charts/paid-apps/")
                {
                    UIApplication.shared.open(url)
                }
            }
            else if indexPath.row == 1
            {
                performSegue(withIdentifier: "showWebView", sender: self)
            }
            
            //Legal section
        case 1:
            if indexPath.row == 0
            {
                performSegue(withIdentifier: "showCopyrightStatement", sender: self)
            }
            
        default:
            break
        }
        
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
