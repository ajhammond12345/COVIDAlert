//
//  InterfaceController.swift
//  COVID Alert WatchKit Extension
//
//  Created by Alexander Hammond on 5/13/20.
//  Copyright © 2020 aajjr. All rights reserved.
//

import WatchKit
import HealthKit
import Foundation


class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    
    var state = 0
    
    var healthStore = HKHealthStore()
    var configuration = HKWorkoutConfiguration()

    var session: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    
    
    @IBOutlet weak var heartRate: WKInterfaceTextField!
    @IBOutlet weak var monitoringButton: WKInterfaceButton!
    
    
    @IBAction func monitoring() {
        if state == 0 {
            self.startMonitoring()
        } else {
            self.stopMonitoring()
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        //don't need
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.monitoringButton.setTitle("Start Monitoring")
        }
        state = 0
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }
            if quantityType == HKQuantityType.quantityType(forIdentifier: .heartRate) {
                let statistics = workoutBuilder.statistics(for: quantityType)
                if statistics != nil {
                    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    let value = statistics!.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                    let roundedValue = Double( round( 1 * value! ) / 1 )
                    DispatchQueue.main.async {
                        self.heartRate.setText("\(roundedValue) BPM")
                    }
                }
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        //don't need
    }
    

    
    func startMonitoring() {
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session.associatedWorkoutBuilder()
            
            session.delegate = self
            builder.delegate = self
            
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
            workoutConfiguration: configuration)
            DispatchQueue.main.async {
                self.monitoringButton.setTitle("Stop Monitoring")
            }
            print("hellOOoOOOOOOO")
            state = 1
        } catch {
            //Say error
        }
        session.startActivity(with: Date())
        builder.beginCollection(withStart: Date()) { (success, error) in
            //?
        }
    }
    
    func stopMonitoring() {
        session.end()
        DispatchQueue.main.async {
            self.monitoringButton.setTitle("Start Monitoring")
        }
        state = 0
    }
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
                // Configure interface objects here.
        configuration = HKWorkoutConfiguration()
        configuration.activityType = .walking
        configuration.locationType = .outdoor
    }
    
    override func didAppear() {
        super.didAppear()
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
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
