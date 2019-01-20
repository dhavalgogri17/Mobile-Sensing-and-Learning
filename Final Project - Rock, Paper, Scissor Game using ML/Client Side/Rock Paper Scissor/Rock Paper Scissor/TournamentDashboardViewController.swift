//
//  TournamentDashboardViewController.swift
//  Rock Paper Scissor
//
//  Created by Dhaval Gogri on 12/8/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit

// Tournament dashboard shows the information about the tournament and all its level
// i.e. Quarters, Semis and Finals
class TournamentDashboardViewController: UIViewController, SocketManagerDelegate {

    private let defaults = UserDefaults.standard
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let socketManager: SocketManager = SocketManager.getSharedInstanceSocket()
    
    // All below views are created programtically to help it achieve a flawless look on all mobile devices of varying sizes
    private var viewContainer: UIView = UIView()
    
    private var viewFinalContainerView: UIView = UIView()
    private var viewSemiFinalContainerView: UIView = UIView()
    private var viewQuarterFinalContainerView: UIView = UIView()
    
    
    private var labelFinal: UILabel = UILabel()
    private var labelSemiFinal: UILabel = UILabel()
    private var labelQuarterFinal: UILabel = UILabel()
    
    
    private var buttonFinal1: UIButton = UIButton()
    
    private var buttonSemiFinal2: UIButton = UIButton()
    private var buttonSemiFinal1: UIButton = UIButton()
    
    
    private var buttonQuarter4: UIButton = UIButton()
    private var buttonQuarter3: UIButton = UIButton()
    private var buttonQuarter2: UIButton = UIButton()
    private var buttonQuarter1: UIButton = UIButton()
    
    private var message = ""
    private var gameArray: NSArray = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tournament Dashboard"
        
        // Custom back button for navigation bar
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ListOfAvailablePlayersTableViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        // Main viewcontroller where all other views would be added in
        viewContainer.frame = CGRect(x: UIScreen.main.bounds.width * 0.1 + Utils.getXPosition(x: 0, error: 0,0,0), y: STATUS_BAR_HEIGHT + (self.navigationController?.navigationBar.frame.height)!, width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height - (STATUS_BAR_HEIGHT + (self.navigationController?.navigationBar.frame.height)!))
        //viewContainer.backgroundColor = UIColor.yellow
        self.view.addSubview(viewContainer)
        
        createViewsProgrammatically()
        addActionListenersForButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // If the view is visible to the user the socket to the socket
        if(self.isViewLoaded && ((self.view?.window) != nil)){
            socketManager.delegate = self
            socketManager.socket.connect()
        }
    }
    
    // Navigation bar back button implementation
    @objc func back(sender: UIBarButtonItem) {
        self.showAlertBox(message: "If you go back, you will go out of tournament mode and also lose your coins. Do you want to go back?")
    }
    
    
    // Action listers for all button in the DashBoard Page
    // 1 Button for Final
    // 2 Button for SemiFinal
    // 4 Button for Quarter Final
    private func addActionListenersForButton(){
        // Setting to button so I can retrieve theri gameId for later use
        buttonFinal1.addTarget(self, action: #selector(self.openGame), for: .touchUpInside)
        buttonFinal1.tag = 6
        
        buttonSemiFinal2.addTarget(self, action: #selector(self.openGame), for: .touchUpInside)
        buttonSemiFinal1.addTarget(self, action: #selector(self.openGame), for: .touchUpInside)
        buttonSemiFinal1.tag = 4
        buttonSemiFinal2.tag = 5
        
        buttonQuarter4.addTarget(self, action: #selector(self.openGame), for: .touchUpInside)
        buttonQuarter3.addTarget(self, action: #selector(self.openGame), for: .touchUpInside)
        buttonQuarter2.addTarget(self, action: #selector(self.openGame), for: .touchUpInside)
        buttonQuarter1.addTarget(self, action: #selector(self.openGame), for: .touchUpInside)
        buttonQuarter1.tag = 0
        buttonQuarter2.tag = 1
        buttonQuarter3.tag = 2
        buttonQuarter4.tag = 3
    }
    
    @objc private func openGame(sender: UIButton){
        // When a button is clicked, check for which button and proceed to the game
        var tag = 0
        var tournamentName = ""
        if(sender.tag == 0){
            tag = 0
            tournamentName = "Quarter Final - 1"
        }
        if(sender.tag == 1){
            tag = 1
            tournamentName = "Quarter Final - 2"
        }
        if(sender.tag == 2){
            tag = 2
            tournamentName = "Quarter Final - 3"
        }
        if(sender.tag == 3){
            tag = 3
            tournamentName = "Quarter Final - 4"
        }
        if(sender.tag == 4){
            tag = 4
            tournamentName = "Semi Final - 1"
        }
        if(sender.tag == 5){
            tag = 5
            tournamentName = "Semi Final - 2"
        }
        if(sender.tag == 6){
            tag = 6
            tournamentName = "Final"
        }
        
        // Open the PlayGameViewController which is same as 2-player
        // Only difference is, this would be tournament mode, so there would be few changes in implementation
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayGameViewController") as? PlayGameViewController {
            viewController.gameId = tag
            viewController.isTournamentMode = true
            viewController.gameNameInfoTournament = tournamentName
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    
    private func createViewsProgrammatically(){
        // Create all the views programmatically for better UI look and consistent UI across all devices
        let outsideSpaceHeight = (viewContainer.frame.height * 0.1)/4
        let labelHeight = (viewContainer.frame.height * 0.05)
        let buttonHeight = (viewContainer.frame.height * 0.05)
        
        
        // GUI for Final
        
        viewFinalContainerView.frame = CGRect(
            x: 0,
            y: outsideSpaceHeight,
            width: viewContainer.frame.width,
            height: viewContainer.frame.height * 0.15
        )
        //viewFinalContainerView.backgroundColor = UIColor.red
        viewContainer.addSubview(viewFinalContainerView)
        let internalSpaceHeightFinal = (viewContainer.frame.height * 0.15 - viewContainer.frame.height * 0.05 - buttonHeight)/2
        
        viewFinalContainerView.layer.borderWidth = 1
        viewFinalContainerView.layer.borderColor = UIColor.black.cgColor
        
        labelFinal.frame = CGRect(
            x: 0,
            y: 0,
            width: viewFinalContainerView.frame.width,
            height: labelHeight
        )
        labelFinal.text = "Finals"
        labelFinal.textAlignment = .center
        labelFinal.backgroundColor = UIColor.black
        labelFinal.textColor = UIColor.white
        viewFinalContainerView.addSubview(labelFinal)
        
        buttonFinal1.frame = CGRect(
            x: 0,
            y: labelFinal.frame.maxY + internalSpaceHeightFinal,
            width: viewFinalContainerView.frame.width,
            height: buttonHeight
        )
        buttonFinal1.setTitle("Final Game", for: UIControl.State.normal)
        buttonFinal1.backgroundColor = appColor
        viewFinalContainerView.addSubview(buttonFinal1)
        
        
        
        // GUI for Semi-Final
        
        viewSemiFinalContainerView.frame = CGRect(
            x: 0,
            y: viewFinalContainerView.frame.maxY + outsideSpaceHeight,
            width: viewContainer.frame.width,
            height: viewContainer.frame.height * 0.25
        )
        viewContainer.addSubview(viewSemiFinalContainerView)
        let internalSpaceHeightSemiFinal = (viewContainer.frame.height * 0.25 - viewContainer.frame.height * 0.05 - 2*buttonHeight)/3
        
        viewSemiFinalContainerView.layer.borderWidth = 1
        viewSemiFinalContainerView.layer.borderColor = UIColor.black.cgColor
        
        labelSemiFinal.frame = CGRect(
            x: 0,
            y: 0,
            width: viewSemiFinalContainerView.frame.width,
            height: labelHeight
        )
        labelSemiFinal.text = "Semi Finals"
        labelSemiFinal.textAlignment = .center
        labelSemiFinal.backgroundColor = UIColor.black
        labelSemiFinal.textColor = UIColor.white
        viewSemiFinalContainerView.addSubview(labelSemiFinal)
        
        buttonSemiFinal2.frame = CGRect(
            x: 0,
            y: labelSemiFinal.frame.maxY + internalSpaceHeightSemiFinal,
            width: viewSemiFinalContainerView.frame.width,
            height: buttonHeight
        )
        buttonSemiFinal2.setTitle("Semi Final Game - 2", for: UIControl.State.normal)
        buttonSemiFinal2.backgroundColor = appColor
        viewSemiFinalContainerView.addSubview(buttonSemiFinal2)
        
        
        buttonSemiFinal1.frame = CGRect(
            x: 0,
            y: buttonSemiFinal2.frame.maxY + internalSpaceHeightSemiFinal,
            width: viewSemiFinalContainerView.frame.width,
            height: buttonHeight
        )
        buttonSemiFinal1.setTitle("Semi Final Game - 1", for: UIControl.State.normal)
        buttonSemiFinal1.backgroundColor = appColor
        viewSemiFinalContainerView.addSubview(buttonSemiFinal1)
        
        
        
        
        
        // GUI for Quarter-Final
        viewQuarterFinalContainerView.frame = CGRect(
            x: 0,
            y: viewSemiFinalContainerView.frame.maxY + outsideSpaceHeight,
            width: viewContainer.frame.width,
            height: viewContainer.frame.height * 0.5
        )
        viewContainer.addSubview(viewQuarterFinalContainerView)
        
        viewQuarterFinalContainerView.layer.borderWidth = 1
        viewQuarterFinalContainerView.layer.borderColor = UIColor.black.cgColor
        
        let internalSpaceHeightQuarterFinal = (viewContainer.frame.height * 0.5 - viewContainer.frame.height * 0.05 - 4 * buttonHeight)/5
        
        
        labelQuarterFinal.frame = CGRect(
            x: 0,
            y: 0,
            width: viewQuarterFinalContainerView.frame.width,
            height: labelHeight
        )
        labelQuarterFinal.text = "Quarter Finals"
        labelQuarterFinal.textAlignment = .center
        labelQuarterFinal.backgroundColor = UIColor.black
        labelQuarterFinal.textColor = UIColor.white
        viewQuarterFinalContainerView.addSubview(labelQuarterFinal)
        
        
        buttonQuarter4.frame = CGRect(
            x: 0,
            y: labelQuarterFinal.frame.maxY + internalSpaceHeightQuarterFinal,
            width: viewQuarterFinalContainerView.frame.width,
            height: buttonHeight
        )
        buttonQuarter4.setTitle("Quarter Final Game - 4", for: UIControl.State.normal)
        buttonQuarter4.backgroundColor = appColor
        viewQuarterFinalContainerView.addSubview(buttonQuarter4)
        
        
        buttonQuarter3.frame = CGRect(
            x: 0,
            y: buttonQuarter4.frame.maxY + internalSpaceHeightQuarterFinal,
            width: viewQuarterFinalContainerView.frame.width,
            height: buttonHeight
        )
        buttonQuarter3.setTitle("Quarter Final Game - 3", for: UIControl.State.normal)
        buttonQuarter3.backgroundColor = appColor
        viewQuarterFinalContainerView.addSubview(buttonQuarter3)
        
        
        buttonQuarter2.frame = CGRect(
            x: 0,
            y: buttonQuarter3.frame.maxY + internalSpaceHeightQuarterFinal,
            width: viewQuarterFinalContainerView.frame.width,
            height: buttonHeight
        )
        buttonQuarter2.setTitle("Quarter Final Game - 2", for: UIControl.State.normal)
        buttonQuarter2.backgroundColor = appColor
        viewQuarterFinalContainerView.addSubview(buttonQuarter2)
        
        
        buttonQuarter1.frame = CGRect(
            x: 0,
            y: buttonQuarter2.frame.maxY + internalSpaceHeightQuarterFinal,
            width: viewQuarterFinalContainerView.frame.width,
            height: buttonHeight
        )
        buttonQuarter1.setTitle("Quarter Final Game - 1", for: UIControl.State.normal)
        buttonQuarter1.backgroundColor = appColor
        viewQuarterFinalContainerView.addSubview(buttonQuarter1)
        
        
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
            // Task tournamentSummary gives information about each game going in the tournament
            if(String(task).elementsEqual("tournamentSummary")){
                let gameDict:NSArray = (jsonDictionary["games"] as! NSArray)
                self.gameArray = gameDict
                // Dictionary which contains all the game running in the tournament
                for eachGame in gameDict{
                    let eachGameDict = (eachGame as! NSDictionary)
                    let gameId: Int = (eachGameDict["gameId"]! as! Int)
                    let winner = String((eachGameDict["winner"]! as! String).utf8)

                    var name1 = ""
                    var name2 = ""
                    let playersDict:NSArray = (eachGameDict["players"] as! NSArray)
                    for eachDict in playersDict{
                        let di = (eachDict as! NSDictionary)
                        let gameName = String((di["gameName"] as! String).utf8)
                        let userName = String((di["userName"] as! String).utf8)
                        if(name1 == ""){
                            name1 = gameName
                        }
                        else{
                            name2 = gameName
                        }
                    }
                    // Each Game players name would be associated in the games belonging to
                    // Quarters, Semis or Finals
                    if(gameId == 0){
                        buttonQuarter1.setTitle("\(name1) vs \(name2)", for: .normal)
                    }
                    if(gameId == 1){
                        buttonQuarter2.setTitle("\(name1) vs \(name2)", for: .normal)
                    }
                    if(gameId == 2){
                        buttonQuarter3.setTitle("\(name1) vs \(name2)", for: .normal)
                    }
                    if(gameId == 3){
                        buttonQuarter4.setTitle("\(name1) vs \(name2)", for: .normal)
                    }
                    if(gameId == 4){
                        buttonSemiFinal1.setTitle("\(name1) vs \(name2)", for: .normal)
                    }
                    if(gameId == 5){
                        buttonSemiFinal2.setTitle("\(name1) vs \(name2)", for: .normal)
                    }
                    if(gameId == 6){
                        buttonFinal1.setTitle("\(name1) vs \(name2)", for: .normal)
                    }
                }
            }
        }
    }
    
    // Socket connection is connected to server, send an acknowledgement to server by sending a message
    func connectionSuccessful(isConnected: Bool) {
        print("Delegate C = \(isConnected)")
        let test:NSDictionary = ["task": "enterTournamentGame", "tournamentId" : appDelegate.golbalTournamentId ,"userName":defaults.string(forKey: "USER_NAME") ?? "", "gameName":defaults.string(forKey: "GAME_NAME") ?? ""]
        let jsonData = try? JSONSerialization.data(withJSONObject: test, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        socketManager.socket.write(string: jsonString!)
    }
    
    // Socket disconncted
    func connectionDisconnected(isDisConnected: Bool) {
        print("Delegate D = \(isDisConnected)")
    }
    
    // Alert box for user wanting to leave the tournament by clicking the back button
    private func showAlertBox(message: String){
        let alertController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Go Back", style: .default) { (_) in
            self.socketManager.disconnectFromSocket()
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
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
