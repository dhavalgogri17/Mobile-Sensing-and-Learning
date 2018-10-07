//
//  GameViewController.swift
//  Lab3
//
//  Created by Dhaval Gogri on 9/29/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Keep orientation Potrait for Game
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableAllOrientation = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This alert box shows instructions for the game
        self.showAlertBox("This is a very simple game, where you have to collect the sticks in the basket. The more you collect the more score you will get. You can collect a total of 300 sticks. You will get 60 seconds to collect them. Collect as much as possible. \n\n If you had exceeded your target step goal for yesterday, you will get to collect a total number of 600 sticks in 60 seconds. Try to increase your high score. Enjoy.\n\n Touch the screen to start the game")
        
    }
    
    // Function to create an alery box
    func showAlertBox(_ message: String?) {
        let alert = UIAlertController(title: "INSTRUCTIONS FOR GAME", message: message, preferredStyle: .alert)
        
        // Only when the user presses the 'GOT IT!' button, the game scene is created
        let okButton = UIAlertAction(title: "GOT IT!", style: .default, handler: { action in
            
            let scene = GameSceneModel(size: self.view.bounds.size)
            let skView = self.view as! SKView // the view in storyboard must be an SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)
            
            alert.dismiss(animated: true)
        })
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    
}
