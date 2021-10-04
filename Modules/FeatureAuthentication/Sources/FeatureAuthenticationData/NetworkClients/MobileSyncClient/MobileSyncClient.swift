// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit

protocol MobileAuthSyncClientAPI {

    func updateMobileSetup(
        guid: String,
        sharedKey: String,
        isMobileSetup: Bool
    ) -> AnyPublisher<Void, NetworkError>

    func verifyCloudBackup(
        guid: String,
        sharedKey: String,
        hasCloudBackUp: Bool
    ) -> AnyPublisher<Void, NetworkError>
}

final class MobileAuthSyncClient: MobileAuthSyncClientAPI {

    // MARK: - Types

    private enum Path {
        static let wallet = ["wallet"]
    }

    private enum Parameters {
        enum UpdateMobileSetup {
            static let method = "method"
            static let guid = "guid"
            static let sharedKey = "sharedKey"
            static let isMobileSetup = "is_mobile_setup"
            static let mobileDeviceType = "mobile_device_type"
        }

        enum VerifyCloudBackup {
            static let method = "method"
            static let guid = "guid"
            static let sharedKey = "sharedKey"
            static let hasCloudBackup = "has_cloud_backup"
            static let mobileDeviceType = "mobile_device_type"
        }
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - API

    func updateMobileSetup(
        guid: String,
        sharedKey: String,
        isMobileSetup: Bool
    ) -> AnyPublisher<Void, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameters.UpdateMobileSetup.method,
                value: "update_mobile_setup"
            ),
            URLQueryItem(
                name: Parameters.UpdateMobileSetup.guid,
                value: guid
            ),
            URLQueryItem(
                name: Parameters.UpdateMobileSetup.sharedKey,
                value: sharedKey
            ),
            URLQueryItem(
                name: Parameters.UpdateMobileSetup.isMobileSetup,
                value: String(isMobileSetup)
            ),
            URLQueryItem(
                name: Parameters.UpdateMobileSetup.mobileDeviceType,
                value: "1"
            )
        ]
        let data = RequestBuilder.body(from: parameters)
        let request = requestBuilder.post(
            path: Path.wallet,
            body: data,
            contentType: .formUrlEncoded
        )!
        return networkAdapter.perform(request: request)
    }

    func verifyCloudBackup(
        guid: String,
        sharedKey: String,
        hasCloudBackUp: Bool
    ) -> AnyPublisher<Void, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameters.VerifyCloudBackup.method,
                value: "verify_cloud_backup"
            ),
            URLQueryItem(
                name: Parameters.VerifyCloudBackup.guid,
                value: guid
            ),
            URLQueryItem(
                name: Parameters.VerifyCloudBackup.sharedKey,
                value: sharedKey
            ),
            URLQueryItem(
                name: Parameters.VerifyCloudBackup.hasCloudBackup,
                value: String(hasCloudBackUp)
            ),
            URLQueryItem(
                name: Parameters.VerifyCloudBackup.mobileDeviceType,
                value: "1"
            )
        ]
        let data = RequestBuilder.body(from: parameters)
        let request = requestBuilder.post(
            path: Path.wallet,
            body: data,
            contentType: .formUrlEncoded
        )!
        return networkAdapter.perform(request: request)
    }
}
