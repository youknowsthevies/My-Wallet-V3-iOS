// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum QRScannerError: Error {
    case unknown
    case avCaptureError(AVCaptureDeviceError)
    case badMetadataObject
    case parserError(Error)
}

public enum AVCaptureDeviceError: LocalizedError {
    case notAuthorized
    case failedToRetrieveDevice
    case inputError
    case unknown

    public var errorDescription: String? {
        switch self {
        case .failedToRetrieveDevice:
            return LocalizationConstants.Errors.failedToRetrieveDevice
        case .inputError:
            return LocalizationConstants.Errors.inputError
        case .notAuthorized:
            return nil
        case .unknown:
            return nil
        }
    }
}
