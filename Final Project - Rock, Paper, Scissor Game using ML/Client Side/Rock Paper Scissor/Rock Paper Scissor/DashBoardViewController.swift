//
//  MainViewController.swift
//  Rock Paper Scissor
//
//  Created by Dhaval Gogri on 12/4/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit

class DashBoardViewController: UIViewController {

    
    // Variable declaration
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var viewContainer: UIView = UIView()
    private var viewCoinView: UIView = UIView()
    private var imageCoin: UIImageView = UIImageView()
    private var labelCoin: UILabel = UILabel()
    
    private var labelPersonalDetails: UILabel = UILabel()
    
    private var viewButtonView: UIView = UIView()
    private var button2Player: UIButton = UIButton()
    private var buttonTournament: UIButton = UIButton()
    private let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        //If the view is visible, connect to socket
        if(SocketManager.getSharedInstanceSocket().socket.isConnected){
           SocketManager.getSharedInstanceSocket().socket.disconnect()
        }
        labelCoin.text = "\(self.defaults.string(forKey: "COINS")!) coins"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DashBoard"
        NSLog("Data = \(UIScreen.main.bounds.height)")
        NSLog("Data = \(UIScreen.main.bounds.height - (STATUS_BAR_HEIGHT + (self.navigationController?.navigationBar.frame.height)! + Utils.getYPosition(y: 16, error: 0,0,0)))")
        NSLog("Data = \(STATUS_BAR_HEIGHT + (self.navigationController?.navigationBar.frame.height)! + Utils.getYPosition(y: 8, error: 0,0,0))")
        
        // Main view conatiner in which all other views would be added
        viewContainer.frame = CGRect(x: Utils.getXPosition(x: 0, error: 0,0,0), y: STATUS_BAR_HEIGHT + (self.navigationController?.navigationBar.frame.height)!, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (STATUS_BAR_HEIGHT + (self.navigationController?.navigationBar.frame.height)!))
        viewContainer.backgroundColor = appColor
        self.view.addSubview(viewContainer)
        
        createViewsProgrammatically()
        addActionListenersForButton()
    }
    
    
    // Views created programmatically so that the UI looks elegant in all app device sizes
    private func createViewsProgrammatically(){
        
        let topSpaces = (viewContainer.frame.height * 0.3 - (viewContainer.frame.height * 0.05 + viewContainer.frame.height * 0.15))/3
        
        viewCoinView.frame = CGRect(
            x: viewContainer.frame.width * 0.1,
            y: topSpaces,
            width: viewContainer.frame.width * 0.8,
            height: viewContainer.frame.height * 0.05
        )
        viewContainer.addSubview(viewCoinView)
        
        
        
        imageCoin.frame = CGRect(
            x: (viewCoinView.frame.width - viewCoinView.frame.height - Utils.getYPosition(y: 90, error: 0,0,0))/2,
            y: 0,
            width: viewCoinView.frame.height,
            height: viewCoinView.frame.height
        )
        imageCoin.image = UIImage(named: "coin.png")
        viewCoinView.addSubview(imageCoin)
        
        
        labelCoin.frame = CGRect(
            x: imageCoin.frame.maxX + Utils.getXPosition(x: 8, error: 0,0,0),
            y: 0,
            width: Utils.getYPosition(y: 90, error: 0,0,0),
            height: viewCoinView.frame.height
        )
        labelCoin.text = "\(self.defaults.string(forKey: "COINS")!) coins"
        labelCoin.textColor = UIColor.white
        labelCoin.textAlignment = .center
        viewCoinView.addSubview(labelCoin)
        
        
        
        
        
        labelPersonalDetails.frame = CGRect(
            x: viewContainer.frame.width * 0.1,
            y: viewCoinView.frame.maxY + topSpaces,
            width: viewContainer.frame.width * 0.8,
            height: viewContainer.frame.height * 0.15
        )
        labelPersonalDetails.numberOfLines = 3
        labelPersonalDetails.textColor = UIColor.white
        labelPersonalDetails.text = "Game Name : \(self.defaults.string(forKey: "GAME_NAME")!)\nUser Name : \(self.defaults.string(forKey: "USER_NAME")!)"
        labelPersonalDetails.textAlignment = .center
        viewContainer.addSubview(labelPersonalDetails)
        
        
        let spaceHeight:Double = 36.0
        let buttonHeight = (viewContainer.frame.height * 0.7 - Utils.getYPosition(y: spaceHeight*4, error: 0,0,0))/2
        
        viewButtonView.frame = CGRect(
            x: 0,
            y: viewContainer.frame.height * 0.3,
            width: viewContainer.frame.width,
            height: viewContainer.frame.height * 0.7
        )
        viewButtonView.backgroundColor = UIColor.white
        viewContainer.addSubview(viewButtonView)
        
        button2Player.frame = CGRect(
            x: viewButtonView.frame.width * 0.1,
            y: Utils.getYPosition(y: spaceHeight, error: 0,0,0),
            width: viewButtonView.frame.width * 0.8,
            height: CGFloat(buttonHeight)
        )
        button2Player.backgroundColor = appColor
        button2Player.setTitle("2 Player Game", for: UIControl.State.normal)
        viewButtonView.addSubview(button2Player)
        
        buttonTournament.frame = CGRect(
            x: viewButtonView.frame.width * 0.1,
            y: Utils.getYPosition(y: spaceHeight, error: 0,0,0) + button2Player.frame.maxY,
            width: viewButtonView.frame.width *  0.8,
            height: CGFloat(buttonHeight)
        )
        buttonTournament.backgroundColor = appColor
        buttonTournament.setTitle("Tournament Mode", for: UIControl.State.normal)
        viewButtonView.addSubview(buttonTournament)
        
        
    }
    
    
    private func addActionListenersForButton(){
        button2Player.addTarget(self, action: #selector(self.playerFight), for: .touchUpInside)
        buttonTournament.addTarget(self, action: #selector(self.tournament), for: .touchUpInside)
    }

    @objc private func playerFight() {
        //Do something when 2 player clicked
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListOfAvailablePlayersTableViewController") as? ListOfAvailablePlayersTableViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @objc private func tournament() {
        //Do something when TOURNAMENT clicked
        if(defaults.integer(forKey: "COINS") > 200){
            showAlertBoxWithAction(message: "Entering the tournament requires 200 coins. Do you want to enter?", title: "Message")
        }
        else{
            self.showAlertBoxMessage("You do not have enough coins to enter the tournament")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(self.isViewLoaded && ((self.view?.window) != nil)){
            self.appDelegate.golbalTournamentId = -1
        }
    }
    
    
    private func showAlertBoxWithAction(message: String, title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "accept", style: .cancel) { (_) in
            // If the player want to enter the tournament mode, he needsto pay some value i.e. 200 coins as a fee
            self.defaults.set(self.defaults.integer(forKey: "COINS") - 200, forKey: "COINS")
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TournamentPlayersTableViewController") as? TournamentPlayersTableViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let declineAction = UIAlertAction(title: "reject", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(declineAction)
        alertController.addAction(acceptAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // SHow normal message to players
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
