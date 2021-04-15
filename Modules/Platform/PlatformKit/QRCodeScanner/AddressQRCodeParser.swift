//
//  AddressQRCodeParser.swift
//  Blockchain
//
//  Created by Jack on 18/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import ToolKit

public protocol AssetURLPayloadFactoryAPI {
    func create(fromString string: String?, asset: CryptoCurrency) -> CryptoAssetQRMetadata?
    func create(from url: URL) -> CryptoAssetQRMetadata?
}

public final class AddressQRCodeParser: QRCodeScannerParsing {

    public enum AddressQRCodeParserError: Error {
        case scanError(QRScannerError)
        case unableToCreatePayload
    }

    public struct Address {
        public let payload: CryptoAssetQRMetadata
    }

    private let assetType: CryptoCurrency
    private let payloadFactory: AssetURLPayloadFactoryAPI

    public init(assetType: CryptoCurrency,
                payloadFactory: AssetURLPayloadFactoryAPI = resolve()) {
        self.assetType = assetType
        self.payloadFactory = payloadFactory
    }

    public func parse(scanResult: Result<String, QRScannerError>, completion: ((Result<Address, AddressQRCodeParserError>) -> Void)?) {
        switch scanResult {
        case .success(let address):
            handleSuccess(address: address, completion: completion)
        case .failure(let error):
            completion?(.failure(.scanError(error)))
        }
    }

    private func handleSuccess(address: String, completion: ((Result<Address, AddressQRCodeParserError>) -> Void)?) {
        guard let payload = payloadFactory.create(fromString: address, asset: assetType) else {
            Logger.shared.error("Could not create payload from scanned string: \(address)")
            completion?(.failure(.unableToCreatePayload))
            return
        }
        completion?(.success(Address(payload: payload)))
    }
}
