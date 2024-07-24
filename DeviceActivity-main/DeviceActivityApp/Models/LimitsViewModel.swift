//
//  LimitsViewModel.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import Foundation
import FamilyControls
import ManagedSettings
import Combine

struct AppLimit: Identifiable, Codable {
    let id: UUID
    let selection: FamilyActivitySelection
    let hours: Int
    let minutes: Int
    
    init(id: UUID = UUID(), selection: FamilyActivitySelection, hours: Int, minutes: Int) {
        self.id = id
        self.selection = selection
        self.hours = hours
        self.minutes = minutes
    }
}

class LimitsViewModel: ObservableObject {
    @Published var activitySelection: FamilyActivitySelection = FamilyActivitySelection() {
        didSet {
            saveSelection()
        }
    }
    @Published var isLocked: Bool {
        didSet {
            saveLockState()
            setShieldRestrictions()
        }
    }
    @Published var appLimits: [AppLimit] = [] {
        didSet {
            saveAppLimits()
        }
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaultsKey = "familyActivitySelection"
    private let lockStateKey = "isLocked"
    private let appLimitsKey = "appLimits"
    private let store = ManagedSettingsStore()
    
    init() {
        self.isLocked = UserDefaults.standard.bool(forKey: lockStateKey)
        loadSelection()
        loadAppLimits()
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
    
    func saveLockState() {
        UserDefaults.standard.set(isLocked, forKey: lockStateKey)
        print("Lock state saved to UserDefaults.")
    }
    
    func saveAppLimits() {
        let defaults = UserDefaults.standard
        do {
            let data = try encoder.encode(appLimits)
            defaults.set(data, forKey: appLimitsKey)
            print("App limits saved to UserDefaults.")
        } catch {
            print("Failed to save app limits: \(error.localizedDescription)")
        }
    }
    
    func loadAppLimits() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: appLimitsKey) else {
            print("No app limits data found in UserDefaults.")
            return
        }

        if let limits = try? decoder.decode([AppLimit].self, from: data) {
            self.appLimits = limits
            print("App limits loaded from UserDefaults.")
        } else {
            print("Failed to decode app limits from UserDefaults.")
        }
    }
    
    func setShieldRestrictions() {
        if isLocked {
            store.shield.applications = activitySelection.applicationTokens.isEmpty ? nil : activitySelection.applicationTokens
            store.shield.applicationCategories = activitySelection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(activitySelection.categoryTokens)
            print("Apps locked.")
        } else {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            print("Apps unlocked.")
        }
    }
    
    func addAppLimit(selection: FamilyActivitySelection, hours: Int, minutes: Int) {
        let newLimit = AppLimit(selection: selection, hours: hours, minutes: minutes)
        appLimits.append(newLimit)
    }
}
