//
//  RequestAuthorization.swift
//  DeviceActivityApp
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import Foundation
import FamilyControls

// A utility struct for managing authorization requests related to FamilyControls.
struct RequestAuthorization {
    
    // The shared authorization center used to request permissions.
    private let center = AuthorizationCenter.shared
    
    // Requests authorization for the specified FamilyControlsMember.
    // Returns a boolean indicating whether the authorization was successful.
    func requestFamilyControls(for value: FamilyControlsMember) async -> Bool {
        do {
            // Attempt to request authorization for the provided FamilyControlsMember.
            try await center.requestAuthorization(for: value)
            return true
        } catch(let error) {
            // If an error occurs, print it for debugging and return false.
            debugPrint(error)
            return false
        }
    }
}
