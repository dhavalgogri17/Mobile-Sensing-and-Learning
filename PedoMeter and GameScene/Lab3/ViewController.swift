//
//  ViewController.swift
//  Lab3
//
//  Created by Dhaval Gogri on 9/29/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit
import CoreMotion
import HealthKit

// This class handles all the work related to Pedometer
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Variable declarations and bindings
    @IBOutlet weak var labelTitleUserActivity: UILabel!
    @IBOutlet weak var labelUserActivityInformation: UILabel!
    @IBOutlet weak var labelTitleNoOfSteps: UILabel!
    @IBOutlet weak var labelRemainingSteps: UILabel!
    @IBOutlet weak var labelNoOfStepsWalkedToday: UILabel!
    var stepsInformationForLastSevenDays : Array<Int> = Array()
    let healthStore = HKHealthStore()
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let motion = CMMotionManager()
    let defaults = UserDefaults.standard
    @IBOutlet weak var tableViewShowSteps7days: UITableView!
    var targetSteps:Float = 0
    
    // This signifies the number of steps the user has walked today.
    var totalSteps: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
                self.labelNoOfStepsWalkedToday.text = "Steps: \(newtotalSteps)"
            }
        }
    }
    
    // This shows the remaining steps for the day
    var totalStepsRemaining: Float = 0.0 {
        willSet(newtotalSteps){
            DispatchQueue.main.async{
                if(newtotalSteps > 0){
                    self.labelRemainingSteps.text = "Step Remaining : \(newtotalSteps)"
                }
                else{
                    self.labelRemainingSteps.text = "Step Goal Completed"
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Assigning delegate and datasource to tableview for showing data
        self.tableViewShowSteps7days.delegate = self
        self.tableViewShowSteps7days.dataSource = self
        
        // Trying to get the data from healthKit of past 7 days for step counts.
        // We want to inform the user what would we want from them, so we are quering the healthStore
        // For this we need to get autorization from Health Store.
        //Below code helps us in getting Authorization.
        let typesToShare = Set([
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            ])
        // We are asking healthKit what we want to read from User's healthStore data
        let typesToRead = Set([
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
            ])
        
        //Requesting Authorization from HealthStore and user to access the step count data
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) {
            success, error in
            // If success, get step count from user.
            self.getStepsCountForLastSevenDays()
            print("ask!")
        }
        
        // If we have saved the previous steps of users, then we sassign it to the variable
        if(defaults.integer(forKey: "TOTAL_STEPS_FOR_TODAY") == 0){
            self.totalSteps = 0.0
        }
        else{
            self.totalSteps = defaults.float(forKey: "TOTAL_STEPS_FOR_TODAY")
        }
        
        
        
        // This gets the target steps. With the help of target steps, we can get the remaining
        // steps needed by the user to complete his daily goal
        if(defaults.float(forKey: "TARGET_STEPS") == 0){
            self.defaults.set(100, forKey: "TARGET_STEPS")
            self.targetSteps = 100
            if(totalSteps > 100){
                self.labelRemainingSteps.text = "Step Goal Completed"
            }
            else{
                self.labelRemainingSteps.text = "Step Remaining : \(100 - totalSteps)"
            }
        }
        else{
            self.targetSteps = defaults.float(forKey: "TARGET_STEPS")
            if(self.totalSteps > self.targetSteps){
                self.labelRemainingSteps.text = "Step Goal Completed"
            }
            else{
                self.labelRemainingSteps.text = "Step Remaining : \(targetSteps - totalSteps)"
            }
        }
        
        // Starting activity monitoring which includes Walking, Cycling, Running, Still, Driving, Unknown
        self.startActivityMonitoring()
        
        // Get Step count for today using Pedometer and update as we get steps information
        self.startPedometerMonitoring()
        
    }
    
    
    //Getting step count for last 7 days.
    func getStepsCountForLastSevenDays(){
        
        // Query to get step count for 7 days from HealthStore
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        // Getting the date which is 7 days ago
        let exactlySevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: now)!
        // Start of that date i.e. 7th dat ago
        let startOfSevenDaysAgo = Calendar.current.startOfDay(for: exactlySevenDaysAgo)
        // Query to get steps count for 7 days each
        let predicate = HKQuery.predicateForSamples(withStart: startOfSevenDaysAgo, end: now, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery.init(quantityType: stepsQuantityType,
                                                     quantitySamplePredicate: predicate,
                                                     options: .cumulativeSum,
                                                     anchorDate: startOfSevenDaysAgo,
                                                     intervalComponents: DateComponents(day: 1))
        
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else {
                return
            }
            
            statsCollection.enumerateStatistics(from: startOfSevenDaysAgo, to: now) { statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    // Store the steps in an array
                    // Also save the yesterdays step count so we can use it in the game
                    // After we get all the data we reload the table in the Main Queue
                    var stepValue:Int = 0
                    stepValue = Int(quantity.doubleValue(for: HKUnit.count()))
                    self.stepsInformationForLastSevenDays.append(stepValue)
                    if(self.stepsInformationForLastSevenDays.count == 7){
                        self.defaults.set(stepValue, forKey: "TOTAL_STEPS_FOR_YESTERDAY")
                    }
                    if(self.stepsInformationForLastSevenDays.count == 8){
                        DispatchQueue.main.async { [unowned self] in
                            self.tableViewShowSteps7days.reloadData()
                        }
                    }
                }
            }
        }
        
        // Execute the query to get the result
        healthStore.execute(query)
    }
    
    
    // MARK: =====Activity Methods=====
    func startActivityMonitoring(){
        // Check if the activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // We get updates from activity the user is doing
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
        }
    }
    
    func handleActivity(_ activity:CMMotionActivity?)->Void{
        // unwrap the activity and display on the screen
        if let unwrappedActivity = activity {
            // Use the main as we are going to print the value on the screen.
            DispatchQueue.main.async{
                // Check for each activity status that the user may be performing
                // which includes walking, cycling, running, still, driving, unknown
                
                if(unwrappedActivity.walking){
                    self.labelUserActivityInformation.text = "User is : Walking";
                }
                else if (unwrappedActivity.cycling){
                    self.labelUserActivityInformation.text = "User is : Cycling";
                }
                else if (unwrappedActivity.running){
                    self.labelUserActivityInformation.text = "User is : Running";
                }
                else if (unwrappedActivity.stationary){
                    self.labelUserActivityInformation.text = "User is : Still";
                }
                else if (unwrappedActivity.automotive){
                    self.labelUserActivityInformation.text = "User is : Driving";
                }
                else{
                    self.labelUserActivityInformation.text = "User Status : Unknown";
                }
                
            }
        }
    }
    
    // MARK: =====Pedometer Methods=====
    // start the pedometer monitoring for today only.
    // We'll keep on getting updates from the user as we get from the motion sensors
    func startPedometerMonitoring(){
        // We need to get data for the whole day starting from mid-night
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone.local
        let dateAtMidnight = calendar.startOfDay(for: NSDate() as Date)
        // Start monitoring for step count
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: dateAtMidnight,
                                   withHandler: handlePedometer)
        }
    }
    
    //ped handler
    func handlePedometer(_ pedData:CMPedometerData?, error:Error?)->(){
        if let steps = pedData?.numberOfSteps {
            // When we get an updated step count, we update the steps and steps remaining to complete goal
            defaults.set(steps.floatValue, forKey: "TOTAL_STEPS_FOR_TODAY")
            self.totalSteps = steps.floatValue
            totalStepsRemaining = targetSteps - totalSteps
        }
    }
    
    
    // MARK: =====Table View Methods=====
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stepsInformationForLastSevenDays.count - 1
    }
    
    // We show the step count for last 7 days.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepsInformationCell", for: indexPath)
        
        let myViews = cell.subviews.filter{$0 is UILabel}
        if(myViews.count == 0){
            // Creating a UILabel if the cell doesn't have one. It would only be created once.
            let cellLabel = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
            cellLabel.textColor = UIColor.black
            cell.addSubview(cellLabel)
        }
        let myViews1 = cell.subviews.filter{$0 is UILabel}
        let cellLabel = myViews1[0] as! UILabel
        // Show the step count for each previous 7 days
        if (indexPath.row == 0){
            cellLabel.text = "Steps Count For Yesterday : \(stepsInformationForLastSevenDays[7 - indexPath.row - 1])"
        }
        else{
            cellLabel.text = "Steps Count For Day \(indexPath.row + 1) ago : \(stepsInformationForLastSevenDays[7 - indexPath.row - 1])"
        }
        
        return cell
    }
    
}

