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

    /// Enables the services
    func enable() {
        let sift = Sift.sharedInstance()
        sift?.accountId = identifier()
        sift?.beaconKey = beacon()
        sift?.allowUsingMotionSensors = false
        sift?.disallowCollectingLocationData = true
    }

    // MARK: - Private

    private func identifier() -> String {
        let info = infoDictionary()
        guard let accountId = info["siftAccountId"] as? String else {
            return ""
        }
        return accountId
    }

    private func beacon() -> String {
        let info = infoDictionary()
        guard let accountId = info["siftKey"] as? String else {
            return ""
        }
        return accountId
    }

    private func infoDictionary() -> [String: Any] {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            return [:]
        }
        return infoDictionary
    }
}
