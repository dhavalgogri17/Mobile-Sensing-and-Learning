//
//  PlayGameViewController.swift
//  Rock Paper Scissor
//
//  Created by Dhaval Gogri on 12/4/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit

class PlayGameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SocketManagerDelegate, URLSessionDelegate {
    

    //Main container and supporting variables needed
    private var viewContainer: UIView = UIView()
    var isTournamentMode = false
    private let round = 6
    private var isImageCaptured = false
    private var isImageUploading = false
    private var labelTitleRoundInfo: UILabel = UILabel()
    private var labelTournamentTitleRoundInfo: UILabel = UILabel()
    private let dsid: Int = 50
    private var currentRound: Int = 0;
    private var maxRound:Int = 5;
    var gameId:Int = 0
    private var myPoints:Int = 0
    private var opponentPoint:Int = 0
    private var myUserName:String = ""
    private var opponentUserName: String = ""
    private var gameOver = false
    var gameNameInfoTournament = ""
    private var isMyGame = false
    
    
    // All views below would be created programmatically
    private var labelPlayer1Label: UILabel = UILabel()
    private var labelPlayer2Label: UILabel = UILabel()
    

    private var viewGameViews:[UIView]=[]
    
    //var labelPlayer1GameInfo:[UILabel]=[]
    private var imagePlayer1GameInfo:[UIImageView] = []
    
    private var labelGameStatus:[UILabel]=[]
    
    //var labelPlayer2GameInfo:[UILabel]=[]
    private var imagePlayer2GameInfo:[UIImageView] = []
    
    
    
    
    private var viewButtonView: UIView = UIView()
    private var buttonStartGame: UIButton = UIButton()
    
    
    private let defaults = UserDefaults.standard
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let socketManager: SocketManager = SocketManager.getSharedInstanceSocket()

    private var session = URLSession()
    private let operationQueue = OperationQueue()
    
    // Back button for Navigation bar
    @objc func back(sender: UIBarButtonItem) {
        showAlertBox(message: "Do you want to leave the game?", title: "Warning")
    }
    
    //If view is visible to user, then connect to socket
    override func viewDidAppear(_ animated: Bool) {
        if(self.isViewLoaded && ((self.view?.window) != nil)){
            socketManager.delegate = self
            socketManager.socket.connect()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Rock - Paper - Scissor"
        
        // Set a custom button to Navigation Bar
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ListOfAvailablePlayersTableViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        
        //Setting up session, Delegate, setting default values
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.session = URLSession(configuration: sessionConfig,
                                  delegate: self,
                                  delegateQueue:self.operationQueue)
        
        // Main view container which would hold all the other views
        viewContainer.frame = CGRect(x: Utils.getXPosition(x: 8, error: 0,0,0), y: STATUS_BAR_HEIGHT + (self.navigationController?.navigationBar.frame.height)! + Utils.getYPosition(y: 8, error: 0,0,0), width: UIScreen.main.bounds.width - Utils.getXPosition(x: 16, error: 0,0,0), height: UIScreen.main.bounds.height - (STATUS_BAR_HEIGHT + (self.navigationController?.navigationBar.frame.height)! + Utils.getYPosition(y: 16, error: 0,0,0)))
        viewContainer.backgroundColor = UIColor.white
        self.view.addSubview(viewContainer)
        
        createViewsProgrammatically()
        addActionListenersForButton()
    }
    
    
    // Create views programmatically to remain consistent for all device sizes
    private func createViewsProgrammatically(){
    
        var yStart: CGFloat = 0
        if(self.isTournamentMode){
            self.buttonStartGame.isUserInteractionEnabled = false
            labelTournamentTitleRoundInfo.frame = CGRect(
                x: 0,
                y: 0,
                width: viewContainer.frame.width,
                height: viewContainer.frame.height * 0.05
            )
            labelTournamentTitleRoundInfo.textAlignment = .center
            labelTournamentTitleRoundInfo.numberOfLines = 1
            labelTournamentTitleRoundInfo.text = "\(gameNameInfoTournament)"
            viewContainer.addSubview(labelTournamentTitleRoundInfo)
            yStart = labelTournamentTitleRoundInfo.frame.maxY + Utils.getYPosition(y: 8, error: 0,0,0)
        }
        
        labelTitleRoundInfo.frame = CGRect(
            x: 0,
            y: yStart,
            width: viewContainer.frame.width,
            height: viewContainer.frame.height * 0.05
        )
        labelTitleRoundInfo.textAlignment = .center
        labelTitleRoundInfo.numberOfLines = 1
        labelTitleRoundInfo.text = "Best of 5 for Rock - Paper - Scissor"
        viewContainer.addSubview(labelTitleRoundInfo)
        var yValueView: CGFloat = labelTournamentTitleRoundInfo.frame.maxY + Utils.getYPosition(y: 8, error: 0,0,0) + viewContainer.frame.height * 0.05 + Utils.getYPosition(y: 8, error: 0,0,0)

        for i in 0...round {
            if(i == 0){
                
                let viewTemp: UIView = UIView()
                let labelPlayer1Temp: UILabel = UILabel()
                let labelStatusTemp: UILabel = UILabel()
                let labelPlayer2Temp: UILabel = UILabel()
                
                // View Container
                viewTemp.frame = CGRect(
                    x: 0,
                    y: yValueView,
                    width: viewContainer.frame.width,
                    height: viewContainer.frame.height * 0.05
                )
                viewContainer.addSubview(viewTemp)
                
                // PLayer 1
                labelPlayer1Label.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: viewTemp.frame.width*0.35,
                    height: viewTemp.frame.height
                )
                labelPlayer1Label.textAlignment = .center
                labelPlayer1Label.numberOfLines = 1
                labelPlayer1Label.text = "You"
                
                viewTemp.addSubview(labelPlayer1Label)
                
                // Status
                labelStatusTemp.frame = CGRect(
                    x: viewTemp.frame.width*0.35,
                    y: 0,
                    width: viewTemp.frame.width*0.3,
                    height: viewTemp.frame.height
                )
                labelStatusTemp.textAlignment = .center
                labelStatusTemp.numberOfLines = 1
                labelStatusTemp.text = "Status"
                viewTemp.addSubview(labelStatusTemp)
                
                // Player 2
                labelPlayer2Label.frame = CGRect(
                    x: viewTemp.frame.width*0.65,
                    y: 0,
                    width: viewTemp.frame.width*0.35,
                    height: viewTemp.frame.height
                )
                labelPlayer2Label.textAlignment = .center
                labelPlayer2Label.numberOfLines = 1
                labelPlayer2Label.text = "Opponent"
                viewTemp.addSubview(labelPlayer2Label)
                
                
                yValueView = viewTemp.frame.maxY + Utils.getYPosition(y: 4, error: 0,0,0)
            }
            else{
                
                
                let viewTemp: UIView = UIView()
                let imagePlayer1Temp: UIImageView = UIImageView()
                let labelStatusTemp: UILabel = UILabel()
                let imagePlayer2Temp: UIImageView = UIImageView()
                
                // View Container
                viewTemp.frame = CGRect(
                    x: 0,
                    y: yValueView,
                    width: viewContainer.frame.width,
                    height: viewContainer.frame.height * 0.1
                )
                viewContainer.addSubview(viewTemp)
                
                // PLayer 1
                imagePlayer1Temp.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: viewTemp.frame.width*0.35,
                    height: viewTemp.frame.height
                )
                imagePlayer1Temp.image = UIImage(named:"question_mark.png")
                imagePlayer1Temp.contentMode = .scaleAspectFit;
                viewTemp.addSubview(imagePlayer1Temp)
                
                // Status
                labelStatusTemp.frame = CGRect(
                    x: viewTemp.frame.width*0.35,
                    y: 0,
                    width: viewTemp.frame.width*0.3,
                    height: viewTemp.frame.height
                )
                labelStatusTemp.textAlignment = .center
                labelStatusTemp.backgroundColor = appColor
                labelStatusTemp.text = "Pending"
                viewTemp.addSubview(labelStatusTemp)
                
                // Player 2
                imagePlayer2Temp.frame = CGRect(
                    x: viewTemp.frame.width*0.65,
                    y: 0,
                    width: viewTemp.frame.width*0.35,
                    height: viewTemp.frame.height
                )
                
                imagePlayer2Temp.image = UIImage(named:"question_mark.png")
                imagePlayer2Temp.contentMode = .scaleAspectFit;
                viewTemp.addSubview(imagePlayer2Temp)
                
                
                viewGameViews.append(viewTemp)
                imagePlayer1GameInfo.append(imagePlayer1Temp)
                labelGameStatus.append(labelStatusTemp)
                imagePlayer2GameInfo.append(imagePlayer2Temp)
                
                yValueView = viewTemp.frame.maxY + Utils.getYPosition(y: 4, error: 0,0,0)
                
                // View conatiner
                viewGameViews[i-1].layer.borderWidth = 1
                viewGameViews[i-1].layer.borderColor = UIColor.black.cgColor
                
                // Image of rock, paper, scissor for player 1
                imagePlayer1GameInfo[i-1].layer.borderWidth = 1
                imagePlayer1GameInfo[i-1].layer.borderColor = UIColor.black.cgColor
                
                // Status about who won, lost or drawn
                labelGameStatus[i-1].layer.borderWidth = 1
                labelGameStatus[i-1].layer.borderColor = UIColor.black.cgColor
                
                // Image of rock, paper, scissor for player 2
                imagePlayer2GameInfo[i-1].layer.borderWidth = 1
                imagePlayer2GameInfo[i-1].layer.borderColor = UIColor.black.cgColor
                
            }
            
            
        }
        // If Round 6 needed
        viewGameViews[5].alpha = 0
        imagePlayer1GameInfo[5].alpha = 0
        labelGameStatus[5].alpha = 0
        imagePlayer2GameInfo[5].alpha = 0
        
        viewButtonView.frame = CGRect(
            x: 0,
            y: viewContainer.frame.height * 0.8,
            width: viewContainer.frame.width,
            height: viewContainer.frame.height * 0.2
        )
        viewContainer.addSubview(viewButtonView)


        buttonStartGame.frame = CGRect(
            x: 0,
            y: viewButtonView.frame.height/2 + Utils.getYPosition(y: 4, error: 0,0,0),
            width: viewButtonView.frame.width,
            height: viewButtonView.frame.height/2 - Utils.getYPosition(y: 4, error: 0,0,0)
        )
        buttonStartGame.setTitle("Play Round", for: UIControl.State.normal)
        buttonStartGame.backgroundColor = appColor
        viewButtonView.addSubview(buttonStartGame)
        
    }
    
    // action listener for start game
    private func addActionListenersForButton(){
        buttonStartGame.addTarget(self, action: #selector(self.startRound), for: .touchUpInside)
    }
    
    // button click for each round from 1-5 or 1-6 if there is a tie
    @objc private func startRound() {
        if(currentRound < maxRound){
            //Initialize an ImagePickerController which would help in selecting an image using a camera
            let vc = UIImagePickerController()
            // apply delegate, source type and editing
            vc.delegate = self
            //vc.sourceType = .camera
            vc.sourceType = .camera
            vc.allowsEditing = true
            present(vc, animated: true)
        }
        
    }
    
    // After picking the image, belowmethod is called
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        // If image not present, error and return
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        //If image image present. Apply that into the image view
        isImageCaptured = true;
        //If the prediction tab is ON, then send the image to the server for prediction
        if(isImageCaptured && !isImageUploading){
            //Convert the image data into a base64 string before sending it to the server
            let imageData:NSData = image.jpegData(compressionQuality: 100)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            //Get prediction from the server
            self.getPrediction(strBase64)
        }
    }
    
    
    // Get prediction from server for Rock, Paper or Scissor
    func getPrediction(_ array:String){
        
        //Creating a base and post URL
        let baseURL = "\(SERVER_URL)/PredictOne"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        //
        let jsonUpload:NSDictionary = ["feature":array, "dsid":self.dsid]
        
        let requestBody:Data? = Utils.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    DispatchQueue.main.async {
                                                                        if(error != nil){
                                                                            if let res = response{
                                                                                print("Response:\n",res)
                                                                            }
                                                                            self.isImageCaptured = false
                                                                        }
                                                                        else{
                                                                            //Get data from server and store it in dictionary
                                                                            let jsonDictionary = Utils.convertDataToDictionary(with: data)
                                                                            //If there is some data present, it means success
                                                                            if(jsonDictionary.count > 0){
                                                                                
                                                                                // Get the prediction data from the dictionary and convert it
                                                                                // into a utf-8 string format
                                                                                let prediction = (jsonDictionary["prediction"]! as! String).utf8
                                                                                print(prediction)
                                                                                // Change can be made if the prediction result is not equal to the image you captured on the camera
                                                                                self.showAlertBoxToChangePrediction(message: "Prediction you received was \n \(String(prediction))", title: "Change Your Prediction", predictionReceived: String(prediction))
                                                                                
                                                                            }
                                                                            else{
                                                                                
                                                                            }
                                                                        }
                                                                        
                                                                    }
        })
        
        postTask.resume() // start the task
    }
    
    
    
    // MEthods for Socket
    func getData(data: Data) {
        print("Delegate Data = \(data)")
    }
    
    // Get string message from server
    func getmessage(message: String) {
        print("Delegate M = \(message)")
        if(!message.contains("Echo")){
            let data = message.data(using: .utf8)!
            let jsonDictionary = Utils.convertDataToDictionary(with: data)
            let task = (jsonDictionary["task"] as! String).utf8
            print("Task = \(task)")
            
            // Below code for 2-player game handling
            if(String(task).elementsEqual("gameSummary")){
                let winner = (jsonDictionary["winner"] as! String).utf8
                let playersDict:NSArray = (jsonDictionary["players"] as! NSArray)
                // Check data for each game
                for eachDict in playersDict{
                    let di = (eachDict as! NSDictionary)
                    let gameName = (di["gameName"] as! String).utf8
                    let userName = (di["userName"] as! String).utf8
                    // Get who is the player playing on that particular mobile phone
                    // and set the other as opponent
                    if(String(userName) == defaults.string(forKey: "USER_NAME")){
                        myPoints = (di["points"]! as! Int)
                        myUserName = String(userName);
                        labelPlayer1Label.text = String(gameName)
                    }
                    else{
                        opponentPoint = (di["points"]! as! Int)
                        opponentUserName = String(userName);
                        labelPlayer2Label.text = String(gameName)
                    }
                }
                
                // Get round information of each game
                let roundDict:NSArray = (jsonDictionary["rounds"] as! NSArray)
                var x = 0
                for eachRoundDict in roundDict{
                    let di = (eachRoundDict as! NSDictionary)
                    let result = String((di["result"] as! String).utf8)
                    // If other player has selcted the formation, then dont show it to this user
                    if(String((di[self.defaults.string(forKey: "USER_NAME")!] as! String).utf8) == "pending"){
                        imagePlayer1GameInfo[x].image = UIImage(named:"question_mark.png")
                        imagePlayer2GameInfo[x].image = UIImage(named:"question_mark.png")
                        labelGameStatus[x].text = "Pending"
                        labelGameStatus[x].backgroundColor = UIColor.yellow
                    }
                    else{
                        // If this user has selected his formation, show him his formation
                        // If oppoent has also selected his formation, show his label to username
                        let mylabel = String((di[self.defaults.string(forKey: "USER_NAME")!] as! String).utf8).lowercased()
                        let opponentlabel = String((di[opponentUserName] as! String).utf8).lowercased()
                        imagePlayer1GameInfo[x].image = UIImage(named:"\(mylabel).png")
                        if(opponentlabel == "pending"){
                            imagePlayer2GameInfo[x].image = UIImage(named:"question_mark.png")
                            labelGameStatus[x].text = "Pending"
                            labelGameStatus[x].backgroundColor = UIColor.yellow
                        }
                        else{
                            imagePlayer2GameInfo[x].image = UIImage(named:"\(opponentlabel).png")
                        }
                    }
                    // If the current round is draw, won, lost or still pending
                    if(result == "draw"){
                        labelGameStatus[x].text = "Draw"
                        labelGameStatus[x].backgroundColor = UIColor.yellow
                    }
                    else if(result == myUserName){
                        labelGameStatus[x].text = "Won"
                        labelGameStatus[x].backgroundColor = UIColor.green
                    }
                    else if(result == opponentUserName){
                        labelGameStatus[x].text = "Lost"
                        labelGameStatus[x].backgroundColor = UIColor.red
                    }
                    else if(result == "pending"){
                        labelGameStatus[x].text = "Pending"
                        labelGameStatus[x].backgroundColor = appColor
                    }
                    x = x + 1
                }
                // If the game is over and we have a winner
                if(String(winner) == myUserName){
                    showAlertBoxMessage("Hurray you won!! \nYou smashed your opponent")
                    self.gameOver = true
                }
                else if(String(winner) == opponentUserName){
                    showAlertBoxMessage("You lost the game. \nBetter luck next time")
                    self.gameOver = true
                }
                // If the game is draw i.e. after 5 round, both the players have the same points, then we have a tie-breaker
                // Whoever wins first, wins the game
                if(String(winner) == "draw"){
                    viewGameViews[5].alpha = 1
                    imagePlayer1GameInfo[5].alpha = 1
                    labelGameStatus[5].alpha = 1
                    imagePlayer2GameInfo[5].alpha = 1
                    if(self.maxRound == 5){
                        showAlertBoxMessage("Get Ready for a Tie Breaker. All Rounds would be updated in the 6th block until a winner is decided")
                    }
                    self.maxRound = 6
                }
            }
                
                
                
                
            // All code below for Tournament handling for all levels from Quarters, Semis to Finals
            else if(String(task).elementsEqual("tournamentSummary")){
                let gameDict:NSArray = (jsonDictionary["games"] as! NSArray)
                // Get each game information
                for eachGame in gameDict{
                    let eachGameDict = (eachGame as! NSDictionary)
                    let gameId: Int = (eachGameDict["gameId"]! as! Int)
                    let winner = String((eachGameDict["winner"]! as! String).utf8)
                    // If the game selected is the current one then,
                    if(self.gameId == gameId){
                        var name1 = ""
                        var name2 = ""
                        var game1 = ""
                        var game2 = ""
                        self.viewContainer.isUserInteractionEnabled = false
                        self.buttonStartGame.isUserInteractionEnabled = false
                        labelTournamentTitleRoundInfo.text = "\(gameNameInfoTournament) - View only"
                        let playersDict:NSArray = (eachGameDict["players"] as! NSArray)
                        // Get info of all players playing in that game
                        // also check if user is one the player assigned that game
                        // If assigned then he can play the game
                        // else user can only VIEW the game and not make any changes via camera
                        for eachDict in playersDict{
                            let di = (eachDict as! NSDictionary)
                            let gameName = (di["gameName"] as! String).utf8
                            let userName = (di["userName"] as! String).utf8
                            // Store info of both players
                            if(String(userName) == defaults.string(forKey: "USER_NAME")){
                                self.viewContainer.isUserInteractionEnabled = true
                                self.buttonStartGame.isUserInteractionEnabled = true
                                labelTournamentTitleRoundInfo.text = "\(gameNameInfoTournament)"
                                self.isMyGame = true
                                if(name1 != ""){
                                    name2 = name1
                                    game2 = game1
                                }
                                name1 = String(userName)
                                game1 = String(gameName)
                                myPoints = (di["points"]! as! Int)
                                myUserName = String(userName);
                            }
                            else{
                                if(name1 == ""){
                                    name1 = String(userName)
                                    game1 = String(gameName)
                                }
                                else{
                                    name2 = String(userName)
                                    game2 = String(gameName)
                                }
                                opponentPoint = (di["points"]! as! Int)
                                opponentUserName = String(userName);
                            }
                            
                        }
                        // Get info on each rounds
                        let roundDict:NSArray = (eachGameDict["rounds"] as! NSArray)
                        var x = 0
                        // if is my game
                        if(isMyGame){
                            // My Game in Rounds
                            // Follow same methods as we used in "gameSummary"
                            for eachRoundDict in roundDict{
                                let di = (eachRoundDict as! NSDictionary)
                                let result = String((di["result"] as! String).utf8)
                                if(String((di[self.defaults.string(forKey: "USER_NAME")!] as! String).utf8) == "pending"){
                                    imagePlayer1GameInfo[x].image = UIImage(named:"question_mark.png")
                                    imagePlayer2GameInfo[x].image = UIImage(named:"question_mark.png")
                                    labelGameStatus[x].text = "Pending"
                                    labelGameStatus[x].backgroundColor = UIColor.yellow
                                }
                                else{
                                    let mylabel = String((di[self.defaults.string(forKey: "USER_NAME")!] as! String).utf8).lowercased()
                                    let opponentlabel = String((di[opponentUserName] as! String).utf8).lowercased()
                                    imagePlayer1GameInfo[x].image = UIImage(named:"\(mylabel).png")
                                    if(opponentlabel == "pending"){
                                        imagePlayer2GameInfo[x].image = UIImage(named:"question_mark.png")
                                        labelGameStatus[x].text = "Pending"
                                        labelGameStatus[x].backgroundColor = UIColor.yellow
                                    }
                                    else{
                                        imagePlayer2GameInfo[x].image = UIImage(named:"\(opponentlabel).png")
                                    }
                                }
                                if(result == "draw"){
                                    labelGameStatus[x].text = "Draw"
                                    labelGameStatus[x].backgroundColor = UIColor.yellow
                                }
                                else if(result == myUserName){
                                    labelGameStatus[x].text = "Won"
                                    labelGameStatus[x].backgroundColor = UIColor.green
                                }
                                else if(result == opponentUserName){
                                    labelGameStatus[x].text = "Lost"
                                    labelGameStatus[x].backgroundColor = UIColor.red
                                }
                                else if(result == "pending"){
                                    labelGameStatus[x].text = "Pending"
                                    labelGameStatus[x].backgroundColor = appColor
                                }
                                x = x + 1
                            }
                            
                            if(String(winner) == myUserName){
                                showAlertBoxMessage("Hurray you won!! \nYou smashed your opponent")
                                self.gameOver = true
                            }
                            else if(String(winner) == opponentUserName){
                                showAlertBoxMessage("You lost the game. \nBetter luck next time")
                                self.gameOver = true
                            }
                            if(String(winner) == "draw"){
                                viewGameViews[5].alpha = 1
                                imagePlayer1GameInfo[5].alpha = 1
                                labelGameStatus[5].alpha = 1
                                imagePlayer2GameInfo[5].alpha = 1
                                if(self.maxRound == 5){
                                    showAlertBoxMessage("Get Ready for a Tie Breaker. All Rounds would be updated in the 6th block until a winner is decided")
                                }
                                self.maxRound = 6
                            }
                        }
                        else{
                            // Not My Game in Rounds
                            // Game would only be a VIEW-ONLY Game
                            // The viewer can get updates of each move from both the players
                            // All the updates are then shown in the UI for direct information
                            for eachRoundDict in roundDict{
                                let di = (eachRoundDict as! NSDictionary)
                                let result = String((di["result"] as! String).utf8)
                                
                                if(String((di[name1] as! String).utf8) == "pending"){
                                    imagePlayer1GameInfo[x].image = UIImage(named:"question_mark.png")
                                }
                                else{
                                    let label = String((di[name1] as! String).utf8).lowercased()
                                    imagePlayer1GameInfo[x].image = UIImage(named:"\(label).png")
                                }
                                
                                if(String((di[name2] as! String).utf8) == "pending"){
                                    imagePlayer1GameInfo[x].image = UIImage(named:"question_mark.png")
                                }
                                else{
                                    let label = String((di[name2] as! String).utf8).lowercased()
                                    imagePlayer1GameInfo[x].image = UIImage(named:"\(label).png")
                                }
                                
                                // Same case as in "gameSummary"
                                if(result == "draw"){
                                    labelGameStatus[x].text = "Draw"
                                    labelGameStatus[x].backgroundColor = UIColor.yellow
                                }
                                else if(result == name1){
                                    labelGameStatus[x].text = "Won"
                                    labelGameStatus[x].backgroundColor = UIColor.green
                                }
                                else if(result == name2){
                                    labelGameStatus[x].text = "Lost"
                                    labelGameStatus[x].backgroundColor = UIColor.red
                                }
                                else if(result == "pending"){
                                    labelGameStatus[x].text = "Pending"
                                    labelGameStatus[x].backgroundColor = appColor
                                }
                                x = x + 1
                            }
                            // The player is the VIEW-ONLY player, so he gets the message of who beats whom
                            // depending on teh condition
                            if(String(winner) == name1){
                                if(gameId == 6){
                                    showAlertBoxMessage("Hurray \(game1) won and smashed \(game2) and won the Tournament")
                                }
                                else{
                                    showAlertBoxMessage("Hurray \(game1) won and smashed \(game2)")
                                }
                                self.gameOver = true
                            }
                            else if(String(winner) == name2){
                                if(gameId == 6){
                                    showAlertBoxMessage("Hurray \(game2) won and smashed \(game1) and won the Tournament")
                                }
                                else{
                                    showAlertBoxMessage("Hurray \(game2) won and smashed \(game1)")
                                }
                                self.gameOver = true
                            }
                            if(String(winner) == "draw"){
                                viewGameViews[5].alpha = 1
                                imagePlayer1GameInfo[5].alpha = 1
                                labelGameStatus[5].alpha = 1
                                imagePlayer2GameInfo[5].alpha = 1
                                if(self.maxRound == 5){
                                    showAlertBoxMessage("Get Ready for a Tie Breaker. All Rounds would be updated in the 6th block until a winner is decided")
                                }
                                self.maxRound = 6
                            }
                            
                        }
                        
                    }
                }
            }
            
            
        }
    }
    

    // If connection is successful then send an acknowledgement message to the server via socket
    func connectionSuccessful(isConnected: Bool) {
        print("Delegate C = \(isConnected)")
        var test:NSDictionary = [:]
        if(isTournamentMode){
            test = ["task": "enterTournamentGame", "tournamentId" : appDelegate.golbalTournamentId ,"userName":defaults.string(forKey: "USER_NAME") ?? "", "gameName":defaults.string(forKey: "GAME_NAME") ?? ""]
        }
        else{
            test = ["task": "enterGame","userName":defaults.string(forKey: "USER_NAME") ?? "", "gameName":defaults.string(forKey: "GAME_NAME") ?? ""]
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: test, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        socketManager.socket.write(string: jsonString!)
    }
    
    // Socket disconncted
    func connectionDisconnected(isDisConnected: Bool) {
        print("Delegate D = \(isDisConnected)")
    }
    
    // Show basic informational messages to players
    func showAlertBoxMessage(_ message: String?) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        
        // Only when the user presses the 'GOT IT!' button, the game scene is created
        let okButton = UIAlertAction(title: "GOT IT!", style: .default, handler: { action in
            if(self.gameOver){
                self.socketManager.disconnectFromSocket()
                self.navigationController?.popViewController(animated: true)
                //self.dismiss(animated: true, completion: nil)
            }
            alert.dismiss(animated: true)
        })
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    
    // Alert box when user clicks back, which would end up being thrown out of tournament
    private func showAlertBox(message: String, title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
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
    
    
    
    // Change prediction if made wrong
    private func showAlertBoxToChangePrediction(message: String, title: String, predictionReceived: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var rockTitle = ""
        var paperTitle = ""
        var scissorTitle = ""
        // Get final labels to be shown to the user for selction
        if(predictionReceived == "Rock"){
            rockTitle = "Stay with Rock"
            paperTitle = "Choose Paper"
            scissorTitle = "Choose Scissor"
        }
        else if(predictionReceived == "Paper"){
            rockTitle = "Choose Rock"
            paperTitle = "Stay with Paper"
            scissorTitle = "Choose Scissor"
        }
        else if(predictionReceived == "Scissor"){
            rockTitle = "Choose Rock"
            paperTitle = "Choose Paper"
            scissorTitle = "Stay with Scissor"
        }
        
        // If changes to rock to be made
        let rockAction = UIAlertAction(title: rockTitle, style: .default) { (_) in
            var test:NSDictionary = [:]
            if(!self.isTournamentMode){
                //Send the value to the server via socket for updation
                test = ["task": "gameMove","userName": self.defaults.string(forKey: "USER_NAME")!, "gameId":self.gameId, "round": self.currentRound, "label": "Rock"]
            }
            else{
                test = ["task": "tournamentGameMove","userName": self.defaults.string(forKey: "USER_NAME")!, "tournamentId": self.appDelegate.golbalTournamentId, "gameId":self.gameId, "round": self.currentRound, "label": "Rock"]
            }
            if(self.maxRound == 5){
                self.currentRound = self.currentRound + 1
            }
            let jsonData = try? JSONSerialization.data(withJSONObject: test, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(self.socketManager.socket)
            print(self.socketManager.socket.isConnected)
            self.socketManager.socket.write(string: jsonString!)
            alertController.dismiss(animated: true, completion: nil)
        }
        
        // If changes to paper to be made
        let paperAction = UIAlertAction(title: paperTitle, style: .default) { (_) in
            var test:NSDictionary = [:]
            if(!self.isTournamentMode){
                //Send the value to the server via socket for updation
                test = ["task": "gameMove","userName": self.defaults.string(forKey: "USER_NAME")!, "gameId":self.gameId, "round": self.currentRound, "label": "Paper"]
            }
            else{
                test = ["task": "tournamentGameMove","userName": self.defaults.string(forKey: "USER_NAME")!, "tournamentId": self.appDelegate.golbalTournamentId, "gameId":self.gameId, "round": self.currentRound, "label": "Paper"]
            }
            if(self.maxRound == 5){
                self.currentRound = self.currentRound + 1
            }
            let jsonData = try? JSONSerialization.data(withJSONObject: test, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(self.socketManager.socket)
            print(self.socketManager.socket.isConnected)
            self.socketManager.socket.write(string: jsonString!)
            alertController.dismiss(animated: true, completion: nil)
        }
        
        // If changes to scissors to be made
        let scissorAction = UIAlertAction(title: scissorTitle, style: .default) { (_) in
            var test:NSDictionary = [:]
            //Send the value to the server via socket for updation
            if(!self.isTournamentMode){
                test = ["task": "gameMove","userName": self.defaults.string(forKey: "USER_NAME")!, "gameId":self.gameId, "round": self.currentRound, "label": "Scissor"]
            }
            else{
                test = ["task": "tournamentGameMove","userName": self.defaults.string(forKey: "USER_NAME")!, "tournamentId": self.appDelegate.golbalTournamentId, "gameId":self.gameId, "round": self.currentRound, "label": "Scissor"]
            }
            if(self.maxRound == 5){
                self.currentRound = self.currentRound + 1
            }
            let jsonData = try? JSONSerialization.data(withJSONObject: test, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(self.socketManager.socket)
            print(self.socketManager.socket.isConnected)
            self.socketManager.socket.write(string: jsonString!)
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(rockAction)
        alertController.addAction(paperAction)
        alertController.addAction(scissorAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
