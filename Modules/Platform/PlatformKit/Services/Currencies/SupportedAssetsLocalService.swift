// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

/// Fetches supported assets from the app bundle.
protocol SupportedAssetsLocalServiceAPI {
    var erc20Asset: Result<SupportedAssetsResponse, SupportedAssetsLocalError> { get }
}

enum SupportedAssetsLocalError: Error {
    case unimplemented
    case missingLocalFile
    case missingRemoteFile
    case localDecodingFailed(Swift.Error)
    case remoteDecodingFailed(Swift.Error)
}

final class SupportedAssetsLocalService: SupportedAssetsLocalServiceAPI {

    var erc20Asset: Result<SupportedAssetsResponse, SupportedAssetsLocalError> {
        switch remoteERC20Assets() {
        case .success(let response):
            return .success(response)
        case .failure:
            // TODO: Log error when asset list download is functional.
            // errorLogger.error(error)
            return bundleERC20Assets()
        }
    }

    private let errorLogger: ErrorRecording
    private let filePathProvider: SupportedAssetsLocalFilePathProviderAPI

    init(
        errorLogger: ErrorRecording = resolve(),
        filePathProvider: SupportedAssetsLocalFilePathProviderAPI = resolve()
    ) {
        self.errorLogger = errorLogger
        self.filePathProvider = filePathProvider
    }

    /// Loads the most recently downloaded ERC20 currencies list file.
    private func remoteERC20Assets() -> Result<SupportedAssetsResponse, SupportedAssetsLocalError> {
        guard let path = filePathProvider.remoteERC20Assets else {
            return .failure(.missingRemoteFile)
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .uncached)
            let response = try JSONDecoder().decode(SupportedAssetsResponse.self, from: data)
            return .success(response)
        } catch {
            return .failure(.remoteDecodingFailed(error))
        }
    }

    /// Loads the ERC20 currencies list file shipped within the Bundle.
    private func bundleERC20Assets() -> Result<SupportedAssetsResponse, SupportedAssetsLocalError> {
        guard let path = filePathProvider.localERC20Assets else {
            return .failure(.missingLocalFile)
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .uncached)
            let response = try JSONDecoder().decode(SupportedAssetsResponse.self, from: data)
            return .success(response)
        } catch {
            return .failure(.localDecodingFailed(error))
        }
    }
}
