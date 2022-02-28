//
//  CopyrightStatementTableViewController.swift
//  CoinCollection
//
//  Created by Nathan Pavlovsky on 7/16/17.
//  Copyright © 2017 1A Pavlovsky, N. All rights reserved.
//
//  This view controller is responsible for presenting the copyright statement for this app

import UIKit

class CopyrightStatementTableViewController: UITableViewController
{
   private let copyrightStatementText = ["Copyright © Nathan Pavlovsky 2017. All rights Reserved.","This iOS app and its content is the copyright of Nathan Pavlovsky.","Any redistribution or reproduction of part or all of the contents in any form is prohibited.","You may not, except with Nathan Pavlovsky's express written permission, distribute or commercially exploit the content, nor may you transmit it or store it in any other website or other form of electronic retrieval system.","You have been warned."]

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Copyright"
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        cell.textLabel?.text = copyrightStatementText[indexPath.row]
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       return copyrightStatementText.count
    }
}
