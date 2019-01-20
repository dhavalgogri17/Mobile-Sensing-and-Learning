//
//  PedoMeterInfo.swift
//  Rock Paper Scissor
//
//  Created by Dhaval Gogri on 12/6/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import Foundation
import CoreMotion
import HealthKit

// Access pedometer data in other classes
protocol PedoMeterDelegate {
    func getSteps(steps: Int)
}

// This class gives yesterday's step so that could be added to the coins. The more steps the player walks,
// the more coins he gets which can be used in the game
class PedoMeterInfo{
    private static var sharedInstance: PedoMeterInfo! = nil
    private var stepsYesterday:Int = 0
    let pedometer = CMPedometer()
    let defaults = UserDefaults.standard
    let healthStore = HKHealthStore()
    var count = 0
    var delegate: PedoMeterDelegate? = nil
    
    static func getSharedInstancePedoMeter() -> PedoMeterInfo{
        if(sharedInstance == nil){
            return PedoMeterInfo()
        }
        return sharedInstance!
    }
    
    init(){
        
        // Trying to get the data from healthKit of past 1 days for step counts.
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
        
        //self.startPedometerMonitoring()
    }
    
//    func startPedometerMonitoring(){
//        // We need to get data for the whole day starting from mid-night
//        var calendar = NSCalendar.current
//        calendar.timeZone = NSTimeZone.local
//        let dateAtMidnight = calendar.startOfDay(for: NSDate() as Date)
//        // Start monitoring for step count
//        if CMPedometer.isStepCountingAvailable(){
//            pedometer.startUpdates(from: dateAtMidnight,
//                                   withHandler: handlePedometer)
//        }
//    }
//
//    //ped handler
//    func handlePedometer(_ pedData:CMPedometerData?, error:Error?)->(){
//        if let steps = pedData?.numberOfSteps {
//            // When we get an updated step count, we update the steps and steps remaining to complete goal
//            defaults.set(steps.floatValue, forKey: "TOTAL_STEPS_FOR_TODAY")
//            //self.totalSteps = steps.floatValue
//        }
//    }
    
    
    //Getting step count for last 7 days.
    func getStepsCountForLastSevenDays(){
        
        // Query to get step count for 7 days from HealthStore
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        // Getting the date which is 7 days ago
        let exactlySevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -1), to: now)!
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
                    // Also save the yesterdays step count so we can use it in the game
                    // After we get all the data we reload the table in the Main Queue
                    var stepValue:Int = 0
                    stepValue = Int(quantity.doubleValue(for: HKUnit.count()))
                    if(self.count == 0){
                        self.stepsYesterday = stepValue
                        self.delegate?.getSteps(steps: stepValue)
                    }
                    self.count = self.count + 1
                }
            }
        }
        
        // Execute the query to get the result
        healthStore.execute(query)
    }
    
    
    public func getYesterdaysStep() -> Int{
        return stepsYesterday
    }
}
