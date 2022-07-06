// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureFormDomain
import PlatformKit

public protocol KYCAccountUsageServiceAPI {

    func fetchAccountUsageForm() -> AnyPublisher<[FormQuestion], NabuNetworkError>
    func submitAccountUsageForm(_ form: [FormQuestion]) -> AnyPublisher<Void, NabuNetworkError>
}

final class KYCAccountUsageService: KYCAccountUsageServiceAPI {

    private let apiClient: KYCClientAPI

    init(apiClient: KYCClientAPI) {
        self.apiClient = apiClient
    }

    func fetchAccountUsageForm() -> AnyPublisher<[FormQuestion], NabuNetworkError> {
        apiClient.fetchAccountUsageForm()
    }

    func submitAccountUsageForm(_ form: [FormQuestion]) -> AnyPublisher<Void, NabuNetworkError> {
        apiClient.submitAccountUsageForm(form)
    }
}
