//
//  AddLimitViewModel.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/24/24.
//

import Foundation
import FamilyControls
import Combine

class AddLimitViewModel: ObservableObject {
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @Published var selectedHours: Int = 0
    @Published var selectedMinutes: Int = 0
}
