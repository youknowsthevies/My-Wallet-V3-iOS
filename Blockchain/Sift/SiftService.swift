//
//  SiftService.swift
//  Blockchain
//
//  Created by Dimitrios Chatzieleftheriou on 29/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Sift
import PlatformKit

final class SiftService: SiftServiceAPI {
    
    private enum Constants {
        static let siftAccountId = "siftAccountId"
        static let siftKey = "siftKey"
    }
    
    // MARK: - Private properties
    
    private var sift: Sift {
        Sift.sharedInstance()
    }

    private var identifier: String {
        guard let accountId = infoDictionary[Constants.siftAccountId] as? String else {
            return ""
        }
        return accountId
    }

    private var beacon: String {
        guard let accountId = infoDictionary[Constants.siftKey] as? String else {
            return ""
        }
        return accountId
    }

    private var infoDictionary: [String: Any] {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            return [:]
        }
        return infoDictionary
    }
    
    // MARK: - SiftServiceAPI

    /// Enables the services
    func enable() {
        sift.accountId = identifier
        sift.beaconKey = beacon
        sift.allowUsingMotionSensors = false
        sift.disallowCollectingLocationData = true
    }

    func set(userId: String) {
        sift.userId = userId
    }

    func removeUserId() {
        sift.unsetUserId()
    }
}
