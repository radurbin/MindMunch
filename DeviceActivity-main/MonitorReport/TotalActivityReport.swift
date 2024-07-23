//
//  TotalActivityReport.swift
//  MonitorReport
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Atividades")
}

struct TotalActivityReport: DeviceActivityReportScene {
    
    let context: DeviceActivityReport.Context = .totalActivity
    
    let content: (DeviceActivity) -> TotalActivityView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> DeviceActivity {
        
        var list: [AppReport] = []
        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })
        
        for await _data in data {
            for await activity in _data.activitySegments {
                for await category in activity.categories {
                    for await app in category.applications {
                        let appName = (app.application.localizedDisplayName ?? "nil")
                        let bundle = (app.application.bundleIdentifier ?? "nil")
                        let duration = app.totalActivityDuration
                        let app = AppReport(id: bundle, name: appName, duration: duration)
                        list.append(app)
                    }
                }
            }
        }
        
        return DeviceActivity(duration: totalActivityDuration, apps: list)
    }
}
