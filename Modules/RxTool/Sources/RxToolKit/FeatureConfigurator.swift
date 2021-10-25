// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

/// - Tag: FeatureFetching
public protocol RxFeatureFetching: AnyObject {
    func fetch<Feature: Decodable>(for key: AppFeature) -> Single<Feature>
    func fetchInteger(for key: AppFeature) -> Single<Int>
    func fetchString(for key: AppFeature) -> Single<String>
    func fetchBool(for key: AppFeature) -> Single<Bool>
}

/// This protocol is responsible for variant fetching
public protocol RxFeatureVariantFetching: AnyObject {

    /// Returns an expected variant for the provided feature key
    /// - Parameter feature: the feature key
    /// - Returns: the `FeatureTestingVariant` value wrapped in a `RxSwift.Single`
    func fetchTestingVariant(for key: AppFeature) -> Single<FeatureTestingVariant>

    /// Returns an expected variant for the provided feature key.
    /// - Parameter feature: the feature key
    /// - Parameter defaultVariant: expected value to be returned if an error occurs
    /// - Returns: the `FeatureTestingVariant` value wrapped in a `RxSwift.Single`
    func fetchTestingVariant(
        for key: AppFeature,
        onErrorReturn defaultVariant: FeatureTestingVariant
    ) -> Single<FeatureTestingVariant>
}
