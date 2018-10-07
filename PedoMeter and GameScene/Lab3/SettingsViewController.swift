//
//  SettingsViewController.swift
//  Lab3
//
//  Created by Dhaval Gogri on 9/30/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit

// This class is only for setting the target goal for user step count
class SettingsViewController: UIViewController {

    @IBOutlet weak var labelShowTargetGoal: UILabel!
    @IBOutlet weak var sliderTargetGoal: UISlider!
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get target steps from UserDefaults if present or set it to 100
        // Also change the value in slider.
        if(defaults.integer(forKey: "TARGET_STEPS") == 0){
            self.defaults.set(100, forKey: "TARGET_STEPS")
            sliderTargetGoal.setValue(100, animated: true)
            self.labelShowTargetGoal.text = "You have set a target of 100 steps"
        }
        else{
            sliderTargetGoal.setValue(defaults.float(forKey: "TARGET_STEPS"), animated: true)
            self.labelShowTargetGoal.text = "You have set a target of \(defaults.float(forKey: "TARGET_STEPS")) steps"
        }
        
    }
    
    @IBAction func onSliderValueChangedSteps(_ sender: UISlider) {
        // When slider value changes, the target steps also change
        self.labelShowTargetGoal.text = "You have set a target of \((Int)(sender.value)) steps"
        self.defaults.set((Int)(sender.value), forKey: "TARGET_STEPS")
    }
    
    
}
