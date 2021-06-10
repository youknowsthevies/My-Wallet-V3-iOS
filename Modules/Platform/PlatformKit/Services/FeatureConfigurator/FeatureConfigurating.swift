// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

/// Types adopting the `FeatureConfiguratorAPI` should provide a way to initialize and configure a
/// remote based feature flag system
public protocol FeatureConfiguratorAPI: FeatureInitializer, FeatureConfiguring { }

public protocol FeatureInitializer: AnyObject {
    func initialize()
}

/// Any feature remote configuration protocol
@objc
public protocol FeatureConfiguring: AnyObject {
    @objc func configuration(for feature: AppFeature) -> AppFeatureConfiguration
}

/// - Tag: FeatureFetching
public protocol FeatureFetching: AnyObject {
    func fetch<Feature: Decodable>(for key: AppFeature) -> Single<Feature>
    func fetchInteger(for key: AppFeature) -> Single<Int>
    func fetchString(for key: AppFeature) -> Single<String>
    func fetchBool(for key: AppFeature) -> Single<Bool>
}

public typealias FeatureFetchingConfiguring = FeatureFetching & FeatureConfiguring

/// This protocol is responsible for variant fetching
public protocol FeatureVariantFetching: AnyObject {

    /// Returns an expected variant for the provided feature key
    /// - Parameter feature: the feature key
    /// - Returns: the `FeatureTestingVariant` value wrapped in a `RxSwift.Single`
    func fetchTestingVariant(for key: AppFeature) -> Single<FeatureTestingVariant>

    /// Returns an expected variant for the provided feature key.
    /// - Parameter feature: the feature key
    /// - Parameter defaultVariant: expected value to be returned if an error occurs
    /// - Returns: the `FeatureTestingVariant` value wrapped in a `RxSwift.Single`
    func fetchTestingVariant(for key: AppFeature,
                             onErrorReturn defaultVariant: FeatureTestingVariant) -> Single<FeatureTestingVariant>
}
