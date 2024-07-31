//
//  DailyLimitsViewModel.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/31/24.
//

import Foundation
import FamilyControls
import ManagedSettings
import Combine

struct DailyLimit: Identifiable, Codable {
    let id: UUID
    let selection: FamilyActivitySelection
    let hours: Int
    let minutes: Int
    var remainingTime: TimeInterval
    var lastUpdateTime: Date
    
    init(id: UUID = UUID(), selection: FamilyActivitySelection, hours: Int, minutes: Int) {
        self.id = id
        self.selection = selection
        self.hours = hours
        self.minutes = minutes
        self.remainingTime = TimeInterval(hours * 3600 + minutes * 60)
        self.lastUpdateTime = Date()
    }
}

class DailyLimitsViewModel: ObservableObject {
    @Published var activitySelection: FamilyActivitySelection = FamilyActivitySelection() {
        didSet {
            saveSelection()
        }
    }
    @Published var dailyLimits: [DailyLimit] = [] {
        didSet {
            saveDailyLimits()
        }
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let dailyLimitsKey = "dailyLimits"
    
    init() {
        loadDailyLimits()
    }
    
    func lockApps(for selection: FamilyActivitySelection) {
        let store = ManagedSettingsStore()
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        print("Apps locked for selection: \(selection.applicationTokens)")
    }
    
    func unlockApps(for selection: FamilyActivitySelection) {
        let store = ManagedSettingsStore()
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        print("Apps unlocked for selection: \(selection.applicationTokens)")
    }
    
    func saveSelection() {
        let defaults = UserDefaults.standard
        do {
            let data = try encoder.encode(activitySelection)
            defaults.set(data, forKey: "activitySelection")
            print("Selection saved to UserDefaults.")
        } catch {
            print("Failed to save selection: \(error.localizedDescription)")
        }
    }
    
    func saveDailyLimits() {
        let defaults = UserDefaults.standard
        do {
            let data = try encoder.encode(dailyLimits)
            defaults.set(data, forKey: dailyLimitsKey)
            print("Daily limits saved to UserDefaults.")
        } catch {
            print("Failed to save daily limits: \(error.localizedDescription)")
        }
    }
    
    func loadDailyLimits() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: dailyLimitsKey) else {
            print("No daily limits data found in UserDefaults.")
            return
        }
        if let limits = try? decoder.decode([DailyLimit].self, from: data) {
            self.dailyLimits = limits
            print("Daily limits loaded from UserDefaults.")
        } else {
            print("Failed to decode daily limits from UserDefaults.")
        }
    }
    
    func addDailyLimit(selection: FamilyActivitySelection, hours: Int, minutes: Int) {
        let newLimit = DailyLimit(selection: selection, hours: hours, minutes: minutes)
        dailyLimits.append(newLimit)
        print("Added new limit for \(selection.applicationTokens): \(hours) hours, \(minutes) minutes")
    }
    
    func deleteDailyLimit(at index: Int) {
        let limit = dailyLimits.remove(at: index)
        unlockApps(for: limit.selection)
        saveDailyLimits()
        print("Deleted limit for \(limit.selection.applicationTokens)")
    }
}
