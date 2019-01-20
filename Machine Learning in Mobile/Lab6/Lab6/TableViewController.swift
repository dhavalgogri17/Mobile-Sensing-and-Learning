//
//  TableViewController.swift
//  lab6
//
//  Created by Dhaval Gogri on 10/8/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit

// This class only shows Module for Lab 6
class TableViewController: UITableViewController {
    
    @IBOutlet var tableViewModule: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewModule.delegate = self;
        self.tableViewModule.dataSource = self;
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // Shows 3 options - Module A, B and Settings
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        
        if(indexPath.row == 0){
            cell.textLabel?.text = "Module A - Training";
        }
        else if(indexPath.row == 1){
            cell.textLabel?.text = "Module B - Predition";
        }

        
        return cell
    }
    
    // Navigation on cell click to a particular Module
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == 0){
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "TrainingStoryboard") as! ViewController
            self.navigationController?.pushViewController(viewController, animated: true);
        }
        else if(indexPath.row == 0){
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Keep orientation as per the screen orientation
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.enableAllOrientation = true
    }
    
    
}
