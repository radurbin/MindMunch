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

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        print("Event did reach threshold for event: \(event.rawValue), activity: \(activity.rawValue)")

        // Handle the threshold event by locking the apps
        if let limit = viewModel.dailyLimits.first(where: { $0.id.uuidString == activity.rawValue }) {
            viewModel.lockApps(for: limit.selection)
            print("Locking apps for limit: \(limit.selection.applicationTokens)")
        } else {
            print("No matching limit found for activity: \(activity.rawValue)")
        }
    }

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("Interval did start for activity: \(activity.rawValue)")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("Interval did end for activity: \(activity.rawValue)")
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        print("Interval will start warning for activity: \(activity.rawValue)")
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        print("Interval will end warning for activity: \(activity.rawValue)")
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        print("Event will reach threshold warning for event: \(event.rawValue), activity: \(activity.rawValue)")
    }
}
