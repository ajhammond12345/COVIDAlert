//
//  ViewController.swift
//  COVID Alert
//
//  Created by Alexander Hammond on 5/13/20.
//  Copyright © 2020 aajjr. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    

    @IBOutlet weak var heartRate: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var newHeartRate: UILabel!
    @IBAction func update(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error. No error handling in this sample project.
        }
        heartRate.text = "Hi"
    }
}

