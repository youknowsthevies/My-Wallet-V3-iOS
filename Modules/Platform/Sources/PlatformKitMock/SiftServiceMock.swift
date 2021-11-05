// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureAuthenticationDomain

final class SiftServiceMock: FeatureAuthenticationDomain.SiftServiceAPI {

    func enable() {}

    func set(userId: String) {}

    func removeUserId() {}
}
