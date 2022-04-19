// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

/// - Tag: FeatureFetching
public protocol RxFeatureFetching: AnyObject {
    func fetch<Feature: Decodable>(for key: AppFeature, as type: Feature.Type) -> Single<Feature>
}
