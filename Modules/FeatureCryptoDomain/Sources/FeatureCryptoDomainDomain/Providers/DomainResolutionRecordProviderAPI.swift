// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol DomainResolutionRecordProviderAPI {

    /// Resolution record for a crypto asset
    var resolutionRecord: AnyPublisher<ResolutionRecord, Error> { get }
}
