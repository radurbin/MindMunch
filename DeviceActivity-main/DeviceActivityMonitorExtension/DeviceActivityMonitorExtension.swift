//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created by Riley Durbin on 7/31/24.
//

import DeviceActivity
import FamilyControls

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let viewModel = DailyLimitsViewModel()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("Interval did start for activity: \(activity.rawValue)")
        checkAndEnforceLimits()
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("Interval did end for activity: \(activity.rawValue)")
        checkAndEnforceLimits()
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        print("Event did reach threshold for event: \(event.rawValue), activity: \(activity.rawValue)")
        checkAndEnforceLimits()
    }
    
    private func checkAndEnforceLimits() {
        print("Checking and enforcing limits")
        viewModel.loadDailyLimits()
        for limit in viewModel.dailyLimits {
            if limit.remainingTime <= 0 {
                viewModel.lockApps(for: limit.selection)
                print("Locking apps for limit: \(limit.selection.applicationTokens)")
            } else {
                print("Limit not reached for \(limit.selection.applicationTokens): \(limit.remainingTime) seconds remaining")
            }
        }
    }
}
