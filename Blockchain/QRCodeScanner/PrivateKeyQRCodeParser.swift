// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinKit
import PlatformKit
import PlatformUIKit

final class PrivateKeyQRCodeParser: QRCodeScannerParsing {
    
    enum PrivateKeyQRCodeParserError: Error {
        case scanError(QRScannerError)
        case unknownKeyFormat
        case unsupportedPrivateKey
        
        var privateKeyReaderError: PrivateKeyReaderError {
            switch self {
            case .scanError:
                return PrivateKeyReaderError.badMetadataObject
            case .unknownKeyFormat:
                return PrivateKeyReaderError.unknownKeyFormat
            case .unsupportedPrivateKey:
                return PrivateKeyReaderError.unsupportedPrivateKey
            }
        }
    }
    
    struct PrivateKey {
        let scannedKey: String
        let assetAddress: AssetAddress?
    }
    
    private let walletManager: WalletManager
    private let loadingViewPresenter: LoadingViewPresenting
    private let assetAddress: AssetAddress?
    
    init(walletManager: WalletManager = .shared,
         loadingViewPresenter: LoadingViewPresenting,
         assetAddress: AssetAddress?) {
        self.walletManager = walletManager
        self.loadingViewPresenter = loadingViewPresenter
        self.assetAddress = assetAddress
    }
    
    func parse(scanResult: Result<String, QRScannerError>, completion: ((Result<PrivateKey, PrivateKeyQRCodeParserError>) -> Void)?) {
        switch scanResult {
        case .success(let privateKey):
            handleSuccess(privateKey: privateKey, completion: completion)
        case .failure(let error):
            completion?(.failure(.scanError(error)))
        }
    }
    
    private func handleSuccess(privateKey stringValue: String, completion: ((Result<PrivateKey, PrivateKeyQRCodeParserError>) -> Void)?) {
        let scheme = "\(AssetConstants.URLSchemes.bitcoin):"
        var scannedKey = stringValue
        //: strip scheme if applicable
        if stringValue.hasPrefix(scheme) {
            let startIndex = stringValue.index(stringValue.startIndex, offsetBy: scheme.count)
            let description = String(stringValue[startIndex...])
            scannedKey = description
        }
        //: Check if the scanned key is a private key, otherwise try public key if accepted
        guard let format = walletManager.wallet.detectPrivateKeyFormat(scannedKey), format.count > 0 else {
            loadingViewPresenter.hide()
            completion?(.failure(.unsupportedPrivateKey))
            return
        }
        //: Pass valid private key back via success handler
        completion?(.success(PrivateKey(scannedKey: scannedKey, assetAddress: assetAddress)))
    }
}
