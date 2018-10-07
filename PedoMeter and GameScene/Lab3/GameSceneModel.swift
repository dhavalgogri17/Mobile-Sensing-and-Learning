//
//  GameSceneModel.swift
//  Lab3
//
//  Created by Dhaval Gogri on 9/29/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

// This class has all the game information
class GameSceneModel: SKScene, SKPhysicsContactDelegate {
    
    // Variable declaration
    var startGame = false;
    var hasCompletedYesterdayStepGoal = false
    var currentXPosition = 0.0
    var count:Int16 = 0
    let defaults = UserDefaults.standard
    var highestScore = 0
    let node1 = SKSpriteNode()
    let node2 = SKSpriteNode()
    let node3 = SKSpriteNode()
    
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    
    // Starts motion updates if the device motion is available.
    // Device motion wont be available on Simulators
    func startMotionUpdates(){
        if self.motion.isDeviceMotionAvailable{
            // Checks device motion for new data every 0.05 seconds
            self.motion.deviceMotionUpdateInterval = 0.05
            // Starts device motion updates and Gyro updates
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
            self.motion.startGyroUpdates()
        }
    }
    
    // All motion related activity is handled here
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        // Checks for motion with gravity
        if let gravity = motionData?.gravity {
            // If the user has completed yesterday's step goal then the gravity is reduced by half to help him in the
            // game to collect more sticks as he would have more time.
            if(self.hasCompletedYesterdayStepGoal){
                self.physicsWorld.gravity = CGVector(dx: CGFloat(0.0), dy: CGFloat(-4.9))
            }
            else{
                self.physicsWorld.gravity = CGVector(dx: CGFloat(0.0), dy: CGFloat(-9.8))
            }
        }
        
        // Checking for device rotation or Gyro updates
        // The bucket will move to right if the below condition is satisfied
        if (motionData!.attitude.roll > 0.0 && CGFloat(currentXPosition + 10) + size.width*0.2 + 10 < self.size.width){
            // Reassigns all the physics body in the game to their new location
            // CurrentXPosition is updated based on the roll we get.
            self.physicsWorld.removeAllJoints()
            self.removeChildren(in: [node1, node2, node3])
            currentXPosition = currentXPosition + 10
            self.addBucketAtPoint(0.0, current: currentXPosition)
            
        }
        // The bucket will move to left is the below condition is satisfied
        else if(motionData!.attitude.roll < 0.0 && CGFloat(currentXPosition - 10) - size.width*0.2 - 10 > 0){
            self.physicsWorld.removeAllJoints()
            self.removeChildren(in: [node1, node2, node3])
            currentXPosition = currentXPosition - 10
            self.addBucketAtPoint(0.0, current: currentXPosition)
        }
        
        
        
    }
    
    // Shows the score label at the bottom of the screen
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    // Score is updated when certain conditions are met
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                // Updates the highest score if score > highest score
                if(newValue > self.highestScore){
                    self.highestScore = newValue
                }
                // Assignes score to the Score Label
                self.scoreLabel.text = "Score: \(newValue)  ||  Highest: \(self.highestScore)"
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        // delegates are assigned
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        // mid screen is given as the currentXPosition
        currentXPosition = Double(size.width * 0.5)
        
        // Checks for the highest score form UserDefaults.
        // If there is a score present, the variable is assigned the same.
        if(defaults.integer(forKey: "HIGHEST_SCORE") != 0){
            self.highestScore = defaults.integer(forKey: "HIGHEST_SCORE")
        }
        
        // Checks for the target steps and the total steps walked yesterday.
        // If the total steps for yesterday is more, the user can get some benefit in the game.
        // For this a boolean variable is assigned by checking the below condition
        if(defaults.float(forKey: "TARGET_STEPS") < defaults.float(forKey: "TOTAL_STEPS_FOR_YESTERDAY"))
        {
            self.hasCompletedYesterdayStepGoal = true
        }
        
        
        // start motion for gravity
        self.startMotionUpdates()
        
        // make sides to the screen
        self.addSidesAndTop()
        
        // Created a bucket shaped physics body which is used to cathcing the sticks falling from above
        self.addBucketAtPoint(0.0, current: currentXPosition)
        
        // The function to add score in UI
        self.addScore()

        // Score set to 0 before start of the game
        self.score = 0
    }
    
    // The score label is added on the UI to get new score updates each time the condition is met
    func addScore(){
        
        scoreLabel.text = "Score: 0  ||  Highest: \(highestScore)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.minY)
        
        addChild(scoreLabel)
    }
    
    
    // Function to add the stick on the screen.
    // The stick would be added randomly on the X axis on the screen and woudl fall down
    func addStick(){
        // Create the SKSpriteNode
        let stick = SKSpriteNode()
        // Give size, color, bounciness, position and shape of the object
        stick.size = CGSize(width:size.width*0.01,height:size.height * 0.1)
        stick.color = UIColor.brown
        let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        stick.position = CGPoint(x: size.width * randNumber, y: size.height * 0.75)
        stick.physicsBody = SKPhysicsBody(rectangleOf:stick.size)
        stick.physicsBody?.restitution = random(min: CGFloat(0), max: CGFloat(0.5))
        stick.physicsBody?.isDynamic = true
        // Useful for getting a callback when we have a collision or a contact etc
        stick.physicsBody?.contactTestBitMask = 0x00000001
        stick.physicsBody?.collisionBitMask = 0x00000001
        stick.physicsBody?.categoryBitMask = 0x00000001
        // Adding the stick to the game scene
        self.addChild(stick)
    }
    
    
    // Code to create a bucket where we would catch all the sticks
    func addBucketAtPoint(_ base:Double, current:Double){
        
        // Create the Base of the bucket
        let xPosition:CGFloat = CGFloat(current + base)
        node1.color = UIColor.red
        node1.size = CGSize(width:size.width*0.3,height:size.height * 0.015)
        node1.position = CGPoint(x: xPosition, y: size.height * 0.1)
        
        node1.physicsBody = SKPhysicsBody(rectangleOf:node1.size)
        node1.physicsBody?.pinned = true
        node1.physicsBody?.affectedByGravity = false
        node1.physicsBody?.allowsRotation = false
        
        self.addChild(node1)
        
        
        
        // Create the Left hand side of the bucket
        node2.color = UIColor.red
        node2.size = CGSize(width:size.width*0.02,height:size.height * 0.15)
        node2.position = CGPoint(x: node1.frame.minX, y: node1.frame.minY + size.height*0.15/2)
        
        node2.physicsBody = SKPhysicsBody(rectangleOf:node2.size)
        node2.physicsBody?.affectedByGravity = false
        node2.physicsBody?.allowsRotation = false
        self.addChild(node2)
        
        
        
        
        // Create the right hand side of the bucket
        node3.color = UIColor.red
        node3.size = CGSize(width:size.width*0.02,height:size.height * 0.15)
        node3.position = CGPoint(x: node1.frame.maxX, y: node1.frame.minY + size.height*0.15/2)
        
        node3.physicsBody = SKPhysicsBody(rectangleOf:node3.size)
        node3.physicsBody?.affectedByGravity = false
        node3.physicsBody?.allowsRotation = false
        self.addChild(node3)
        
        
        // Creating a joint so 2 objects behave as one
        let joint = SKPhysicsJointFixed.joint(withBodyA: node2.physicsBody!, bodyB: node1.physicsBody!, anchor: CGPoint(x: node1.frame.minX, y: node1.frame.minY))
        self.physicsWorld.add(joint)
        
        
        // Creating a joint so 2 objects behave as one
        let joint2 = SKPhysicsJointFixed.joint(withBodyA: node3.physicsBody!, bodyB: node1.physicsBody!, anchor: CGPoint(x: node1.frame.minX, y: node1.frame.minY))
        self.physicsWorld.add(joint2)
        
    }
    
    
    
    
    // Create left and right barrier on the screen
    func addSidesAndTop(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.1,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.1)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        for obj in [left,right,top]{
            obj.color = UIColor.red
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    
    // MARK: =====Delegate Functions=====
    
    // Function to start the game
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Allows to start teh game only once
        if(!startGame){
            startGame = true
            // Checks if user has completed yesterday's step goal. If he has completed the goal 600 stcks would fall instead of
            // 300 sticks. Also the gravity is reduced to 4.9 instead of 9.8, so it would be much easier for user to get to
            // his highest score.
            // Huge Benefits
            if(self.hasCompletedYesterdayStepGoal){
                // Shows 10 sticks every 1 second
                _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.keepAddingSticks(timer:)), userInfo: nil, repeats: true)
            }
            else{
                // Shows 5 sticks every 1 second
                _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.keepAddingSticks(timer:)), userInfo: nil, repeats: true)
            }
        }
        else{

        }
    }
    
    // Timer to keep track of sticks falling
    @objc func keepAddingSticks(timer: Timer){
        self.addStick()
        self.count = self.count + 1
        // If sticks reaches a particular count, the game stops.
        // User can then review his score after all the hard work done to collect the sticks
        if(self.hasCompletedYesterdayStepGoal){
            if(count == Int16(60/0.1)){
                timer.invalidate()
                if(score >= highestScore){
                    self.defaults.set(highestScore, forKey: "HIGHEST_SCORE")
                }
            }
        }
        else{
            if(count == Int16(30/0.1)){
                timer.invalidate()
                if(score >= highestScore){
                    self.defaults.set(highestScore, forKey: "HIGHEST_SCORE")
                }
            }
        }
        
    }
    
    // When the stick have went in the bucket.
    // Increase the score by 1
    // Remove the stick from the game scene
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == node1 {
            self.removeChildren(in: [(contact.bodyB.node)!])
            self.score += 1
        }
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
