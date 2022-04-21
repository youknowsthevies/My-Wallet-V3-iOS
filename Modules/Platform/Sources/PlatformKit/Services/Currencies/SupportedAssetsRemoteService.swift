// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MoneyKit
import ToolKit

public protocol SupportedAssetsRemoteServiceAPI {
    func refreshCustodialAssetsCache() -> AnyPublisher<Void, Never>
    func refreshEthereumERC20AssetsCache() -> AnyPublisher<Void, Never>
    func refreshPolygonERC20AssetsCache() -> AnyPublisher<Void, Never>
}

final class SupportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI {

    private let client: SupportedAssetsClientAPI
    private let filePathProvider: SupportedAssetsFilePathProviderAPI
    private let fileIO: FileIOAPI
    private let jsonDecoder: JSONEncoder

    init(
        client: SupportedAssetsClientAPI = resolve(),
        filePathProvider: SupportedAssetsFilePathProviderAPI = resolve(),
        fileIO: FileIOAPI = resolve(),
        jsonDecoder: JSONEncoder = .init()
    ) {
        self.client = client
        self.filePathProvider = filePathProvider
        self.fileIO = fileIO
        self.jsonDecoder = jsonDecoder
    }

    func refreshCustodialAssetsCache() -> AnyPublisher<Void, Never> {
        client.custodialAssets
            .eraseError()
            .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(
                        response,
                        to: filePathProvider.remoteCustodialAssets!,
                        encodedUsing: jsonDecoder
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    func refreshEthereumERC20AssetsCache() -> AnyPublisher<Void, Never> {
        client.ethereumERC20Assets
            .eraseError()
            .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(
                        response,
                        to: filePathProvider.remoteEthereumERC20Assets!,
                        encodedUsing: jsonDecoder
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    func refreshPolygonERC20AssetsCache() -> AnyPublisher<Void, Never> {
        .just(())
        // TODO: (paulo) IOS-5614 Uncomment this when safe for first release.
        //    client.polygonERC20Assets
        //        .eraseError()
        //        .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
        //            fileIO
        //                .write(
        //                    response,
        //                    to: filePathProvider.remotePolygonERC20Assets!,
        //                    encodedUsing: jsonDecoder
        //                )
        //                .eraseError()
        //                .publisher
        //                .eraseToAnyPublisher()
        //        }
        //        .replaceError(with: ())
        //        .eraseToAnyPublisher()
    }
}
