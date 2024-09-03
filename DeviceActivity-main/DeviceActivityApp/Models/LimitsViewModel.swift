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

// Represents a limit placed on a specific app or category of apps.
// Each AppLimit contains a unique ID, the selection of apps or categories to limit,
// the allowed hours and minutes, and the remaining time before the limit triggers.
struct AppLimit: Identifiable, Codable {
    let id: UUID                      // Unique identifier for each limit
    let selection: FamilyActivitySelection  // Selection of apps or categories to limit
    let hours: Int                    // Number of hours allowed for the limit
    let minutes: Int                  // Number of minutes allowed for the limit
    var remainingTime: TimeInterval   // Remaining time before the limit triggers
    var lastUpdateTime: Date          // Last time the remaining time was updated
    
    // Initializer for AppLimit with default remaining time based on hours and minutes
    init(id: UUID = UUID(), selection: FamilyActivitySelection, hours: Int, minutes: Int) {
        self.id = id
        self.selection = selection
        self.hours = hours
        self.minutes = minutes
        self.remainingTime = TimeInterval(hours * 3600 + minutes * 60)
        self.lastUpdateTime = Date()
    }

    // Extends the remaining time by a specified number of minutes
    mutating func extendTime(by minutes: Int) {
        remainingTime += TimeInterval(minutes * 60)
        lastUpdateTime = Date()
    }
}

// ViewModel that manages the state and logic for setting and managing app limits.
class LimitsViewModel: ObservableObject {
    // MARK: - Published Properties
    
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
    
    // MARK: - Private Properties
    
    private let encoder = JSONEncoder()  // Encoder for saving data to UserDefaults
    private let decoder = JSONDecoder()  // Decoder for loading data from UserDefaults
    private let userDefaultsKey = "familyActivitySelection" // Key for saving the activity selection
    private let lockStateKey = "isLocked"  // Key for saving the lock state
    private let appLimitsKey = "appLimits" // Key for saving the app limits
    private let store = ManagedSettingsStore() // Store for managing shield restrictions
    private var timer: Timer? // Timer for regularly updating app usage
    
    // MARK: - Initializer
    
    // Initializes the ViewModel, loading saved data and starting the timer.
    init() {
        self.isLocked = UserDefaults.standard.bool(forKey: lockStateKey)
        loadSelection()
        loadAppLimits()
        startTimer()
    }
    
    // MARK: - Timer Management
    
    // Starts a timer that updates app usage every second.
    func startTimer() {
        timer?.invalidate() // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateAppUsage()
        }
    }
    
    // Updates the remaining time for each app limit and applies restrictions if needed.
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
    
    // MARK: - Lock/Unlock Apps
    
    // Locks apps or categories when the remaining time for their limit reaches zero.
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
    
    // Unlocks apps or categories when their limit is extended or removed.
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
    
    // MARK: - Persistence Methods
    
    // Saves the current activity selection to UserDefaults.
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
    
    // Loads the activity selection from UserDefaults, if it exists.
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
    
    // Saves the current lock state to UserDefaults.
    func saveLockState() {
        UserDefaults.standard.set(isLocked, forKey: lockStateKey)
        print("Lock state saved to UserDefaults.")
    }
    
    // Saves the current app limits to UserDefaults.
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
    
    // Loads the app limits from UserDefaults, if they exist.
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
    
    // MARK: - Shield Restrictions
    
    // Updates the shield restrictions based on the current app limits.
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
    
    // MARK: - App Limit Management
    
    // Adds a new app limit and updates the shield restrictions accordingly.
    func addAppLimit(selection: FamilyActivitySelection, hours: Int, minutes: Int) {
        let newLimit = AppLimit(selection: selection, hours: hours, minutes: minutes)
        appLimits.append(newLimit)
        if hours == 0 && minutes == 0 {
            lockApps(for: selection)
        }
        updateAppUsage()
    }
    
    // Deletes an app limit and updates the shield restrictions accordingly.
    func deleteAppLimit(at index: Int) {
        appLimits.remove(at: index)
        setShieldRestrictions() // Ensure shield restrictions are updated immediately after deleting a limit
    }
    
    // Extends the time for a specific app limit and updates the shield restrictions.
    func extendAppLimit(for id: UUID, by minutes: Int) {
        if let index = appLimits.firstIndex(where: { $0.id == id }) {
            appLimits[index].extendTime(by minutes)
            saveAppLimits()
            setShieldRestrictions() // Ensure shield restrictions are updated immediately after extending a limit
        }
    }
}

