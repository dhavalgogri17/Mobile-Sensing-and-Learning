//
//  ListOfAvailablePlayersTableViewController.swift
//  Rock Paper Scissor
//
//  Created by Dhaval Gogri on 12/6/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit

// PLayer List shown when player enters 2-player mode
class ListOfAvailablePlayersTableViewController: UITableViewController, URLSessionDelegate, SocketManagerDelegate {

    //Variable declaration
    private let defaults = UserDefaults.standard
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let socketManager: SocketManager = SocketManager.getSharedInstanceSocket()
    private var gameId:Int = 0
    var shouldConnectAgain = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "List Of Online Players"
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ListOfAvailablePlayersTableViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    // Custom navigation bar Back button
    @objc func back(sender: UIBarButtonItem) {
        showAlertBox(message: "Do you want to leave the 2-player arena?", title: "Warning", userName: "", gameName: "", isAcceptReject: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // If view is visible to the player, then socket socket
        if(self.isViewLoaded && ((self.view?.window) != nil)){
            socketManager.delegate = self
            socketManager.socket.connect()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.availablePlayers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListOfPlayerCell", for: indexPath)
        //Set players game name and user name in the field for it to identifiable by othe players
        cell.backgroundColor = appColor
        cell.textLabel?.text = "GameName : \(appDelegate.availablePlayers[indexPath.row].getGameName())"
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.text = "UserName : \(appDelegate.availablePlayers[indexPath.row].getUserName())"
        cell.detailTextLabel?.textColor = UIColor.white
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When player decides to challenge a player, information is give to server via socket
        let test:NSDictionary = ["task": "challengeOpponent","userName": defaults.string(forKey: "USER_NAME")!, "opponent": appDelegate.availablePlayers[indexPath.row].getUserName()]
        let jsonData = try? JSONSerialization.data(withJSONObject: test, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        socketManager.socket.write(string: jsonString!)
        
    }
    
    // Below are all Delegate methods for socket connection, disconnection, get message and get data
    func getData(data: Data) {
        print("Delegate Data = \(data)")
    }
    
    // below method is caled when message is received from server via socket
    func getmessage(message: String) {
        print("Delegate M = \(message)")
        if(!message.contains("Echo")){
            let data = message.data(using: .utf8)!
            let jsonDictionary = Utils.convertDataToDictionary(with: data)
            let task = (jsonDictionary["task"] as! String).utf8
            print("Task = \(task)")
            
            // task to get players list from server who want to compete with other players
            if(String(task).elementsEqual("playerList")){
                appDelegate.availablePlayers.removeAll()
                let playersDict:NSArray = (jsonDictionary["players"] as! NSArray)
                print(playersDict)
                for eachDict in playersDict{
                    let di = (eachDict as! NSDictionary)
                    let gameName = (di["gameName"] as! String).utf8
                    let userName = (di["userName"] as! String).utf8
                    print(gameName)
                    print(userName)
                    appDelegate.availablePlayers.append(AvailablePlayerList(gameName: String(gameName), userName: String(userName)))
                }
                self.tableView.reloadData()
            }
            // If opponent sends you a challenge then you will be showed a pop-up, whether to accept or not.
            else if(String(task).elementsEqual("opponentRespond")){
                let opponentGameName = (jsonDictionary["gameName"] as! String).utf8
                let opponentUserName = (jsonDictionary["userName"] as! String).utf8
                showAlertBox(message: "\(opponentUserName) has challenged you for a dual. Do you want to accept the challenge", title: "Challenge Request", userName: String(opponentUserName), gameName: String(opponentGameName), isAcceptReject: true)
                
            }
            // If opponent accepts your challenge then you move to the main Game i.e. PlayGameViewcontroller
            // else you stay on the same page i.e. the player list 
            else if(String(task).elementsEqual("replyFromOpponent")){
                let responseFromOpponent = (jsonDictionary["response"] as! String).utf8
                if(String(responseFromOpponent) == "reject"){
                    let messageFromOpponent = (jsonDictionary["message"] as! String).utf8
                    self.showAlertBoxMessage(String(messageFromOpponent))
                }
                else if(String(responseFromOpponent) == "accept"){
                    gameId = (jsonDictionary["gameId"]! as! Int)
                    socketManager.disconnectFromSocket()
                    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayGameViewController") as? PlayGameViewController {
                        viewController.gameId = gameId
                        if let navigator = navigationController {
                            navigator.pushViewController(viewController, animated: true)
                        }
                    }
                }
                else if(String(responseFromOpponent) == "success"){
                    
                }
            }
        }
    }
    
    
    
    func connectionSuccessful(isConnected: Bool) {
        // When socket is connected, send server a confirmation message
        print("Delegate C = \(isConnected)")
        let test:NSDictionary = ["task": "enterGame","userName":defaults.string(forKey: "USER_NAME") ?? "", "gameName":defaults.string(forKey: "GAME_NAME") ?? ""]
        let jsonData = try? JSONSerialization.data(withJSONObject: test, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        socketManager.socket.write(string: jsonString!)
    }
    
    func connectionDisconnected(isDisConnected: Bool) {
        print("Delegate D = \(isDisConnected)")
        
    }
    
    
    // Alert box to handle Back button, Accept and Reject for opponent challenge
    private func showAlertBox(message: String, title: String, userName: String, gameName: String, isAcceptReject: Bool){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var acceptTitle = ""
        var rejectTitle = ""
        if(isAcceptReject){
            acceptTitle = "Accept"
            rejectTitle = "Decline"
        }
        else{
            acceptTitle = "Go to DashBoard"
            rejectTitle = "Stay"
        }
        let acceptAction = UIAlertAction(title: acceptTitle, style: .default) { (_) in
            if(isAcceptReject){
                // If opponent accepts, send message to server for confirmation to move forward to the game
                let test:NSDictionary = ["task": "opponentResponse","repsonse": "accept", "opponent":userName]
                let jsonData = try? JSONSerialization.data(withJSONObject: test, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                self.socketManager.socket.write(string: jsonString!)
            }
            else{
                self.socketManager.disconnectFromSocket()
                _ = self.navigationController?.popViewController(animated: true)
            }
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let declineAction = UIAlertAction(title: rejectTitle, style: .cancel) { (_) in
            if(isAcceptReject){
                // If opponent rejects, send message to server for confirmation about his rejection
                let test:NSDictionary = ["task": "opponentResponse","repsonse": "reject", "opponent":userName]
                let jsonData = try? JSONSerialization.data(withJSONObject: test, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                self.socketManager.socket.write(string: jsonString!)
            }
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(acceptAction)
        alertController.addAction(declineAction)
    
    
        self.present(alertController, animated: true, completion: nil)
    }
    
    // SHow normal message to user for information purposes
    func showAlertBoxMessage(_ message: String?) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        
        // Only when the user presses the 'GOT IT!' button alert is dismissed
        let okButton = UIAlertAction(title: "GOT IT!", style: .default, handler: { action in
            
            alert.dismiss(animated: true)
        })
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
}
