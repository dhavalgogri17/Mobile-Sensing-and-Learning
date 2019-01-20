//
//  ViewController.swift
//  Rock Paper Scissor
//
//  Created by Dhaval Gogri on 12/2/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit

class SignInRegisterUpdateViewController: UIViewController, UITextFieldDelegate, URLSessionDelegate, PedoMeterDelegate {
    
    
    // Variable declarations
    private var session = URLSession()
    private let operationQueue = OperationQueue()
    private let defaults = UserDefaults.standard
    
    // Below are UIViews which are created programmatically
    private var viewContainer: UIView = UIView()
    private var imageAppIcon: UIImageView = UIImageView()
    private var textfieldGameName: UITextField = UITextField()
    private var textfieldUserName: UITextField = UITextField()
    private var textfieldPassword: UITextField = UITextField()
    
    private var buttonSignIn: UIButton = UIButton()
    private var viewSeparater: UIView = UIView()
    private var viewSeparater2: UIView = UIView()
    private var buttonRegister: UIButton = UIButton()
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    
    private var click = 0
    
    // Check for condition
    private var isSignIn = false
    private var isRegister = false
    private var steps: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegate method to UITextField
        self.textfieldGameName.delegate = self
        self.textfieldUserName.delegate = self
        self.textfieldPassword.delegate = self
        
        // No autocorrect in UITextField
        self.textfieldUserName.autocorrectionType = .no
        self.textfieldGameName.autocorrectionType = .no
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        //Setting up session, Delegate, setting default values
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.session = URLSession(configuration: sessionConfig,
                                  delegate: self,
                                  delegateQueue:self.operationQueue)
        
        
        
        // Main view controller which would hold all other views
        viewContainer.frame = CGRect(x: Utils.getXPosition(x: 8, error: 0,0,0), y: STATUS_BAR_HEIGHT + getNavigationControllerHeight() + Utils.getYPosition(y: 8, error: 0,0,0), width: UIScreen.main.bounds.width - Utils.getXPosition(x: 16, error: 0,0,0), height: UIScreen.main.bounds.height - (STATUS_BAR_HEIGHT + getNavigationControllerHeight() + Utils.getYPosition(y: 16, error: 0,0,0)))
        self.view.addSubview(viewContainer)
        
        createViewsProgrammatically()
        addActionListenersForButton()
        
        
        
    }
    
    private func getNavigationControllerHeight() -> (CGFloat){
        return 0.0
    }

    // Create views programmatically so teh UI is elegant and is consistent in all the devices of various sizes
    private func createViewsProgrammatically(){
        if(click == 0){
            
            imageAppIcon.frame = CGRect(
                x: viewContainer.frame.width/2 - viewContainer.frame.width * 0.3,
                y: Utils.getYPosition(y: 8.0, error: 0,0,0),
                width: viewContainer.frame.width * 0.6,
                height: viewContainer.frame.width * 0.6
            )
            imageAppIcon.image = UIImage(named: "app_icon")
            viewContainer.addSubview(imageAppIcon)
            
            
            viewSeparater.frame = CGRect(
                x: 0,
                y: viewContainer.frame.height/2 + viewContainer.frame.height/4,
                width: viewContainer.frame.width,
                height: Utils.getYPosition(y: 0.01, error: 0,0,0)
            )
            viewSeparater.backgroundColor = UIColor.gray
            viewContainer.addSubview(viewSeparater)
            
            buttonSignIn.frame = CGRect(
                x: viewContainer.frame.width * 0.1,
                y: viewSeparater.frame.minY - Utils.getYPosition(y: 40, error: 0,0,0) - Utils.getYPosition(y: 16, error: 0,0,0),
                width: viewContainer.frame.width * 0.8,
                height: Utils.getYPosition(y: 40, error: 0,0,0)
            )
            buttonSignIn.backgroundColor = appColor
            buttonSignIn.setTitle("Sign In", for: UIControl.State.normal)
            viewContainer.addSubview(buttonSignIn)
            
            
            buttonRegister.frame = CGRect(
                x: viewContainer.frame.width * 0.1,
                y: viewSeparater.frame.maxY + Utils.getYPosition(y: 16, error: 0,0,0),
                width: viewContainer.frame.width * 0.8,
                height: Utils.getYPosition(y: 40, error: 0,0,0)
            )
            buttonRegister.backgroundColor = appColor
            buttonRegister.setTitle("Register", for: UIControl.State.normal)
            viewContainer.addSubview(buttonRegister)
        }
        else if(click == 1){
            if(isSignIn){
                //viewSeparater.alpha = 0
                buttonRegister.alpha = 0
                
                textfieldUserName.frame = CGRect(
                    x: viewContainer.frame.width * 0.1,
                    y: viewContainer.frame.height * 0.6,
                    width: viewContainer.frame.width * 0.8,
                    height: viewContainer.frame.width * 0.1//Utils.getYPosition(y: 30, error: 0,0,0)
                )
                textfieldUserName.placeholder = "Enter User Name"
                //textfieldUserName.backgroundColor = UIColor.green
                viewContainer.addSubview(textfieldUserName)
                
                viewSeparater.frame = CGRect(
                    x: 0,
                    y: textfieldUserName.frame.maxY + Utils.getYPosition(y: 8.0, error: 0,0,0),
                    width: viewContainer.frame.width,
                    height: Utils.getYPosition(y: 1.0, error: 0,0,0)
                )
                viewSeparater.backgroundColor = appColor
                
                textfieldPassword.frame = CGRect(
                    x: viewContainer.frame.width * 0.1,
                    y: viewSeparater.frame.maxY + Utils.getYPosition(y: 8.0, error: 0,0,0),
                    width: viewContainer.frame.width * 0.8,
                    height: viewContainer.frame.width * 0.1//Utils.getYPosition(y: 30, error: 0,0,0)
                )
                textfieldPassword.placeholder = "Enter Password"
                textfieldPassword.isSecureTextEntry = true
                viewContainer.addSubview(textfieldPassword)
                
                
                buttonSignIn.frame = CGRect(
                    x: viewContainer.frame.width * 0.1,
                    y: textfieldPassword.frame.maxY + viewContainer.frame.height * 0.1,
                    width: viewContainer.frame.width * 0.8,
                    height: Utils.getYPosition(y: 40, error: 0,0,0)
                )
                
            }
            else{
                buttonSignIn.alpha = 0
                
                textfieldGameName.frame = CGRect(
                    x: viewContainer.frame.width * 0.1,
                    y: viewContainer.frame.height * 0.5,
                    width: viewContainer.frame.width * 0.8,
                    height: viewContainer.frame.width * 0.1//Utils.getYPosition(y: 30, error: 0,0,0)
                )
                textfieldGameName.placeholder = "Enter Your Game Name"
                //textfieldUserName.backgroundColor = UIColor.green
                viewContainer.addSubview(textfieldGameName)
                
                
                viewSeparater2.frame = CGRect(
                    x: 0,
                    y: textfieldGameName.frame.maxY + Utils.getYPosition(y: 8.0, error: 0,0,0),
                    width: viewContainer.frame.width,
                    height: Utils.getYPosition(y: 1.0, error: 0,0,0)
                )
                viewSeparater2.backgroundColor = appColor
                viewContainer.addSubview(viewSeparater2)
                
                
                textfieldUserName.frame = CGRect(
                    x: viewContainer.frame.width * 0.1,
                    y: viewSeparater2.frame.maxY + Utils.getYPosition(y: 8.0, error: 0,0,0),
                    width: viewContainer.frame.width * 0.8,
                    height: viewContainer.frame.width * 0.1//Utils.getYPosition(y: 30, error: 0,0,0)
                )
                textfieldUserName.placeholder = "Enter User Name"
                //textfieldUserName.backgroundColor = UIColor.green
                viewContainer.addSubview(textfieldUserName)
                
                viewSeparater.frame = CGRect(
                    x: 0,
                    y: textfieldUserName.frame.maxY + Utils.getYPosition(y: 8.0, error: 0,0,0),
                    width: viewContainer.frame.width,
                    height: Utils.getYPosition(y: 1.0, error: 0,0,0)
                )
                viewSeparater.backgroundColor = appColor
                
                textfieldPassword.frame = CGRect(
                    x: viewContainer.frame.width * 0.1,
                    y: viewSeparater.frame.maxY + Utils.getYPosition(y: 8.0, error: 0,0,0),
                    width: viewContainer.frame.width * 0.8,
                    height: viewContainer.frame.width * 0.1//Utils.getYPosition(y: 30, error: 0,0,0)
                )
                textfieldPassword.placeholder = "Enter Password"
                textfieldPassword.isSecureTextEntry = true
                viewContainer.addSubview(textfieldPassword)
                
                
                buttonRegister.frame = CGRect(
                    x: viewContainer.frame.width * 0.1,
                    y: textfieldPassword.frame.maxY + viewContainer.frame.height * 0.1,
                    width: viewContainer.frame.width * 0.8,
                    height: Utils.getYPosition(y: 40, error: 0,0,0)
                )
            }
            
            self.activityIndicator.center = self.view.center
            self.activityIndicator.startAnimating()
            self.activityIndicator.alpha = 0
            viewContainer.addSubview(self.activityIndicator)
            
            // Show a message to user about the permission we'd be asking to access steps
            showAlertBoxMessage("We would need your permission to access your step count to add them as an incentive in the game in the form of coins. If you have not allowed the permission previously, please allow for the permision in the next screen when you click 'GOT IT!'", isPedometer: true)
            
        }
        
    }
    
    
    // Add action listerner for button
    private func addActionListenersForButton(){
        buttonSignIn.addTarget(self, action: #selector(self.signIn), for: .touchUpInside)
        buttonRegister.addTarget(self, action: #selector(self.register), for: .touchUpInside)
    }
    
    // Method for sign in click
    @objc private func signIn() {
        if(click == 0){
            click = click + 1
            isSignIn = true
            createViewsProgrammatically()
        }
        else{
            // Check if all the fields have data in it
            if((textfieldUserName.text?.isEmpty)! || (textfieldPassword.text?.isEmpty)!){
                showAlertBoxMessage("Enter the required information")
            }
            else{
                
                signInRegister()
            }
        }
    }
    
    // Method for register click
    @objc private func register() {
        if(click == 0){
            click = click + 1
            isRegister = true
            createViewsProgrammatically()
        }
        else{
            // Check if all the fields have data in it
            if((textfieldUserName.text?.isEmpty)! || (textfieldPassword.text?.isEmpty)! || (textfieldGameName.text?.isEmpty)!){
                showAlertBoxMessage("Enter the required information")
            }
            else{
                signInRegister()
            }
        }
    }
    
    
    // return key in keyboard should close the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    // API call for SignIn and Register
    func signInRegister(){
        viewContainer.isUserInteractionEnabled = false
        // data to send in body of post request (send arguments as json)
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        var baseURL = ""
        var jsonUpload:NSDictionary = NSDictionary()
        if(isRegister){
            baseURL = "\(SERVER_URL)/Register"
            jsonUpload = ["gameName": self.textfieldGameName.text, "userName": self.textfieldUserName.text, "password": self.textfieldPassword.text, "step": steps, "stepDate": dateString]
        }
        else if(isSignIn){
            baseURL = "\(SERVER_URL)/SignIn"
            jsonUpload = ["userName": self.textfieldUserName.text, "password": self.textfieldPassword.text, "step": steps, "stepDate": dateString]
        }
        else{
            
        }
        
        //Creating a base and post URL
        
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
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
                                                                        }
                                                                        else{
                                                                            //Get data from server and store it in dictionary
                                                                            let jsonDictionary = Utils.convertDataToDictionary(with: data)
                                                                            //If there is some data present, it means success
                                                                            if(jsonDictionary.count > 0){
                                                                                // into a utf-8 string format
                                                                                let status = (jsonDictionary["status"]! as! String).utf8
                                                                                // Check if suucess or failure
                                                                                if(String(status).elementsEqual("success")){
                                                                                    let coins = (jsonDictionary["coins"]! as! Int64)
                                                                                    self.defaults.set(String(coins), forKey: "COINS")
                                                                                    print("Success has occured")
                                                                                    print(coins)
                                                                                    
                                                                                    // Save all information about users in defauls.
                                                                                    self.defaults.set((jsonDictionary["gameName"]! as! String), forKey: "GAME_NAME")
                                                                                    self.defaults.set(String(self.textfieldUserName.text!), forKey: "USER_NAME")
                                                                                    self.defaults.set(String(self.textfieldPassword.text!), forKey: "PASSWORD")
                                                                                    if(self.isRegister){
                                                                                        self.showAlertBoxMessage("Thank you for registering. You will get 2000 coins as a bonus which can be used to enter tournament mode in the app", isPedometer: false)
                                                                                    }
                                                                                    else{
                                                                                        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                                                        let vc : DashBoardViewController = storyboard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                                                                        let navigationController = UINavigationController(rootViewController: vc)
                                                                                        
                                                                                        self.present(navigationController, animated: true, completion: nil)
                                                                                    }
                                                                                    
                                                                                }
                                                                                else{
                                                                                    // failure cases for register and sign in
                                                                                    if(self.isRegister){
                                                                                        self.showAlertBoxMessage("UserName is already registered. Please choose a different one")
                                                                                    }
                                                                                    else{
                                                                                        self.showAlertBoxMessage("Could not login. Please check whether you entered username and password are correct")
                                                                                    }
                                                                                }
                                                                                print(status)
                                                                                
                                                                            }
                                                                            else{
                                                                                
                                                                            }
                                                                        }
                                                                        self.viewContainer.isUserInteractionEnabled = true
                                                                        
                                                                    }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    
    // Move views up so we can see what is being entered in UITextField
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    // Move views down when return is hit on keyboard
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    

    // delegate method to get steps from pedometer
    func getSteps(steps: Int) {
        self.steps = steps
        print(steps)
    }
    
    // Used to get permission for pedometer and show message to him if he registers, so he gets 2000 coins
    func showAlertBoxMessage(_ message: String?, isPedometer: Bool) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        
        // Only when the user presses the 'GOT IT!' button, the game scene is created
        let okButton = UIAlertAction(title: "GOT IT!", style: .default, handler: { action in
            if(isPedometer){
                let pedometer = PedoMeterInfo.getSharedInstancePedoMeter()
                pedometer.delegate = self
            }
            else{
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : DashBoardViewController = storyboard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                let navigationController = UINavigationController(rootViewController: vc)
                
                self.present(navigationController, animated: true, completion: nil)
            }
            alert.dismiss(animated: true)
        })
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    // Show normal messages to user about some information
    func showAlertBoxMessage(_ message: String?) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        
        // Only when the user presses the 'GOT IT!' button, the game scene is created
        let okButton = UIAlertAction(title: "GOT IT!", style: .default, handler: { action in
            
            alert.dismiss(animated: true)
        })
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    // Acceptable characters in the UITextField for Game name, username and password
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        
        return (string == filtered)
    }
    
}

