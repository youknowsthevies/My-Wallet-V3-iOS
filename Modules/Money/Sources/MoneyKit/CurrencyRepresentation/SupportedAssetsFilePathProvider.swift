// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import ToolKit

public protocol SupportedAssetsFilePathProviderAPI {
    var remoteEthereumERC20Assets: URL? { get }
    var localEthereumERC20Assets: URL? { get }
    var remotePolygonERC20Assets: URL? { get }
    var localPolygonERC20Assets: URL? { get }
    var remoteCustodialAssets: URL? { get }
    var localCustodialAssets: URL? { get }
}

final class SupportedAssetsFilePathProvider: SupportedAssetsFilePathProviderAPI {

    private enum FileName {
        enum Local {
            static var ethereumERC20: String { "local-currencies-ethereum-erc20.json" }
            static var polygonERC20: String { "local-currencies-polygon-erc20.json" }
            static var custodial: String { "local-currencies-custodial.json" }
        }

        enum Remote {
            static var ethereumERC20: String { "remote-currencies-erc20.json" }
            static var polygonERC20: String { "remote-currencies-polygon-erc20.json" }
            static var custodial: String { "remote-currencies-custodial.json" }
        }
    }

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    var localEthereumERC20Assets: URL? {
        Bundle.module.url(forResource: FileName.Local.ethereumERC20, withExtension: nil)
    }

    var localPolygonERC20Assets: URL? {
        Bundle.module.url(forResource: FileName.Local.polygonERC20, withExtension: nil)
    }

    var localCustodialAssets: URL? {
        Bundle.module.url(forResource: FileName.Local.custodial, withExtension: nil)
    }

    var remoteEthereumERC20Assets: URL? {
        guard let documentsDirectory = documentsDirectory else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(FileName.Remote.ethereumERC20)
    }

    var remotePolygonERC20Assets: URL? {
        guard let documentsDirectory = documentsDirectory else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(FileName.Remote.polygonERC20)
    }

    var remoteCustodialAssets: URL? {
        guard let documentsDirectory = documentsDirectory else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(FileName.Remote.custodial)
    }

    private var documentsDirectory: URL? {
        try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
    }
}
