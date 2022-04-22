//
//  File.swift
//  
//
//  Created by Augustin Udrea on 21/04/2022.
//

import Foundation


public struct UpdatedPreferences: Encodable, Equatable {
    public init(preferences: [UpdatedNotificationPreference]) {
        self.preferences = preferences
    }
    let preferences: [UpdatedNotificationPreference]
}

public struct UpdatedNotificationPreference: Encodable, Equatable {
    public init(contactMethod: String, channel: String, action: String) {
        self.contactMethod = contactMethod
        self.channel = channel
        self.action = action
    }
    
    let contactMethod: String
    let channel: String
    let action: String
}
