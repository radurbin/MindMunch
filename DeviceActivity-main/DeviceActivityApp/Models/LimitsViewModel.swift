//
//  LimitsViewModel.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import Foundation
import FamilyControls
import Combine

class LimitsViewModel: ObservableObject {
    @Published var activitySelection: FamilyActivitySelection = FamilyActivitySelection() {
        didSet {
            saveSelection()
        }
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaultsKey = "familyActivitySelection"
    
    init() {
        loadSelection()
    }
    
    func saveSelection() {
        let defaults = UserDefaults.standard
        do {
            let data = try encoder.encode(activitySelection)
            defaults.set(data, forKey: userDefaultsKey)
            print("Selection saved to UserDefaults.")
        } catch {
            print("Failed to save selection: \(error.localizedDescription)")
        }
    }
    
    func loadSelection() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: userDefaultsKey) else {
            print("No selection data found in UserDefaults.")
            return
        }

        if let selection = try? decoder.decode(FamilyActivitySelection.self, from: data) {
            self.activitySelection = selection
            print("Selection loaded from UserDefaults.")
        } else {
            print("Failed to decode selection from UserDefaults.")
        }
    }
}
