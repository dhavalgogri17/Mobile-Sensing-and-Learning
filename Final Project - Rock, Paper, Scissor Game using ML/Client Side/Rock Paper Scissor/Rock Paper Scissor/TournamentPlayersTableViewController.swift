//
//  TournamentPlayersTableViewController.swift
//  Rock Paper Scissor
//
//  Created by Dhaval Gogri on 12/8/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit

// PLayer List shown when player enters 8-player tournament mode
class TournamentPlayersTableViewController: UITableViewController, URLSessionDelegate, SocketManagerDelegate {
    
    // variable declarations
    private let defaults = UserDefaults.standard
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let socketManager: SocketManager = SocketManager.getSharedInstanceSocket()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.tournamentPlayers.removeAll()
        self.title = "List Of Tournament Players"
        
        // custom back button in navigation bar
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ListOfAvailablePlayersTableViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // If the view controller is visible to the player then connect to socket
        if(self.isViewLoaded && ((self.view?.window) != nil)){
            socketManager.delegate = self
            socketManager.socket.connect()
        }
        
    }
    
    // back button implementation for Navigation bar
    @objc func back(sender: UIBarButtonItem) {
        self.showAlertBox(message: "If you go back, you will go out of tournament mode and also lose your coins. Do you want to go back?")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return appDelegate.tournamentPlayers.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentListPlayerCell", for: indexPath)
        // Show all the players who wanted to join the tournament. It shows the game name and user name
        cell.backgroundColor = appColor
        cell.textLabel?.text = "GameName : \(appDelegate.tournamentPlayers[indexPath.row].getGameName())"
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.text = "UserName : \(appDelegate.tournamentPlayers[indexPath.row].getUserName())"
        cell.detailTextLabel?.textColor = UIColor.white
        return cell
    }
    
    
    
    // Below are all Delegate methods for socket connection, disconnection, get message and get data
    func getData(data: Data) {
        print("Delegate Data = \(data)")
    }
    
    // Get a string message from the server which would be in JSON format
    func getmessage(message: String) {
        print("Delegate M = \(message)")
        if(!message.contains("Echo")){
            let data = message.data(using: .utf8)!
            let jsonDictionary = Utils.convertDataToDictionary(with: data)
            let task = (jsonDictionary["task"] as! String).utf8
            print("Task = \(task)")
            
            // If task is "tournamentPlayerList" then server has returned all the players that have joined the tournament
            if(String(task).elementsEqual("tournamentPlayerList")){
                appDelegate.tournamentPlayers.removeAll()
                let playersDict:NSArray = (jsonDictionary["players"] as! NSArray)
                print(playersDict)
                for eachDict in playersDict{
                    let di = (eachDict as! NSDictionary)
                    let gameName = (di["gameName"] as! String).utf8
                    let userName = (di["userName"] as! String).utf8
                    print(gameName)
                    print(userName)
                    appDelegate.tournamentPlayers.append(AvailablePlayerList(gameName: String(gameName), userName: String(userName)))
                }
                self.tableView.reloadData()
            }
            // Get Tournament summary i.e. each game's info from the tournament reaching from Quearters to Semis to Finals
            else if(String(task).elementsEqual("tournamentSummary")){
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TournamentDashboardViewController") as? TournamentDashboardViewController {
                    appDelegate.golbalTournamentId = (jsonDictionary["tournamentId"] as! Int)
                    if let navigator = navigationController {
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            }
        }
    }
    
    
    // If we connect to server, we send server a message to mark an acknowledgement
    func connectionSuccessful(isConnected: Bool) {
        print("Delegate C = \(isConnected)")
        let test:NSDictionary = ["task": "enterTournamentGame","tournamentId" : appDelegate.golbalTournamentId, "userName":defaults.string(forKey: "USER_NAME") ?? "", "gameName":defaults.string(forKey: "GAME_NAME") ?? ""]
        let jsonData = try? JSONSerialization.data(withJSONObject: test, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        socketManager.socket.write(string: jsonString!)
    }
    
    func connectionDisconnected(isDisConnected: Bool) {
        print("Delegate D = \(isDisConnected)")
    }
    
    
    
    
    
    
    // Show warning message to players if they are about to leave the tournament by pressing the back button
    private func showAlertBox(message: String){
        let alertController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Go Back", style: .default) { (_) in
            self.socketManager.disconnectFromSocket()
            _ = self.navigationController?.popViewController(animated: true)
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let declineAction = UIAlertAction(title: "Stay", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(acceptAction)
        alertController.addAction(declineAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
