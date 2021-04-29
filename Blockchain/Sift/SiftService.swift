// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import Sift

final class SiftService: SiftServiceAPI {
    
    private enum Constants {
        static let siftAccountId = "siftAccountId"
        static let siftKey = "siftKey"
    }
    
    // MARK: - Private properties
    
    private var sift: Sift? {
        guard featureConfigurator.configuration(for: .siftScienceEnabled).isEnabled else {
            return nil
        }
        return Sift.sharedInstance()
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

    private let featureConfigurator: FeatureConfiguring

    init(featureConfigurator: FeatureConfiguring = DIKit.resolve()) {
        self.featureConfigurator = featureConfigurator
    }
    
    // MARK: - SiftServiceAPI

    /// Enables the services
    func enable() {
        guard let sift = self.sift else { return }
        sift.accountId = identifier
        sift.beaconKey = beacon
        sift.allowUsingMotionSensors = false
        sift.disallowCollectingLocationData = true
    }

    func set(userId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.sift?.userId = userId
        }
    }

    func removeUserId() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.sift?.unsetUserId()
        }
    }
}
