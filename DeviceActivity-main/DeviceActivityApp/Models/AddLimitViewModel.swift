//
//  AddLimitViewModel.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/24/24.
//

import Foundation
import FamilyControls
import Combine

// ViewModel responsible for managing the state of the Add Limit screen in the app.
class AddLimitViewModel: ObservableObject {
    // The selection of apps or categories that the user wants to limit.
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    
    // The number of hours the user has selected for the limit.
    @Published var selectedHours: Int = 0
    
    // The number of minutes the user has selected for the limit.
    @Published var selectedMinutes: Int = 0
}
