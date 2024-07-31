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

    mutating func extendTime(by minutes: Int) {
        remainingTime += TimeInterval(minutes * 60)
        lastUpdateTime = Date()
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
    private var timer: Timer?
    
    init() {
        self.isLocked = UserDefaults.standard.bool(forKey: lockStateKey)
        loadSelection()
        loadAppLimits()
        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateAppUsage()
        }
    }
    
    func updateAppUsage() {
        var needsUpdate = false
        let currentTime = Date()
        for (index, limit) in appLimits.enumerated() {
            if appLimits[index].remainingTime > 0 {
                let elapsedTime = currentTime.timeIntervalSince(limit.lastUpdateTime)
                appLimits[index].remainingTime -= elapsedTime
                appLimits[index].lastUpdateTime = currentTime
                needsUpdate = true
                if appLimits[index].remainingTime <= 0 {
                    appLimits[index].remainingTime = 0
                    lockApps(for: limit.selection)
                }
            }
        }
        if needsUpdate {
            saveAppLimits()
            setShieldRestrictions() // Update shield restrictions immediately after usage update
        }
    }
    
    func lockApps(for selection: FamilyActivitySelection) {
        var allAppTokens = Set<ApplicationToken>()
        var allCategoryTokens = Set<ActivityCategoryToken>()
        
        for limit in appLimits where limit.remainingTime <= 0 {
            allAppTokens.formUnion(limit.selection.applicationTokens)
            allCategoryTokens.formUnion(limit.selection.categoryTokens)
        }
        
        store.shield.applications = allAppTokens.isEmpty ? nil : allAppTokens
        store.shield.applicationCategories = allCategoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(allCategoryTokens)
        
        print("Apps locked.")
    }
    
    func unlockApps(for selection: FamilyActivitySelection) {
        var allAppTokens = Set<ApplicationToken>()
        var allCategoryTokens = Set<ActivityCategoryToken>()
        
        for limit in appLimits where limit.remainingTime > 0 {
            allAppTokens.formUnion(limit.selection.applicationTokens)
            allCategoryTokens.formUnion(limit.selection.categoryTokens)
        }
        
        store.shield.applications = allAppTokens.isEmpty ? nil : allAppTokens
        store.shield.applicationCategories = allCategoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(allCategoryTokens)
        
        print("Apps unlocked.")
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
        var allAppTokens = Set<ApplicationToken>()
        var allCategoryTokens = Set<ActivityCategoryToken>()
        
        for limit in appLimits {
            if limit.remainingTime <= 0 {
                allAppTokens.formUnion(limit.selection.applicationTokens)
                allCategoryTokens.formUnion(limit.selection.categoryTokens)
            }
        }
        
        store.shield.applications = allAppTokens.isEmpty ? nil : allAppTokens
        store.shield.applicationCategories = allCategoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(allCategoryTokens)
        
        print("Shield restrictions updated.")
    }
    
    func addAppLimit(selection: FamilyActivitySelection, hours: Int, minutes: Int) {
        let newLimit = AppLimit(selection: selection, hours: hours, minutes: minutes)
        appLimits.append(newLimit)
        updateAppUsage() // Ensure the app usage is updated immediately after adding a new limit
    }
    
    func deleteAppLimit(at index: Int) {
        appLimits.remove(at: index)
        setShieldRestrictions() // Ensure shield restrictions are updated immediately after deleting a limit
    }
    
    func extendAppLimit(for id: UUID, by minutes: Int) {
        if let index = appLimits.firstIndex(where: { $0.id == id }) {
            appLimits[index].extendTime(by: minutes)
            saveAppLimits()
            setShieldRestrictions() // Ensure shield restrictions are updated immediately after extending a limit
        }
    }
}
