//
//  QRScannerError.swift
//  PlatformKit
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization

public enum QRScannerError: Error {
    case unknown
    case avCaptureError(AVCaptureDeviceError)
    case badMetadataObject
}

public enum AVCaptureDeviceError: LocalizedError {
    case notAuthorized
    case failedToRetrieveDevice
    case inputError

    public var errorDescription: String? {
        switch self {
        case .failedToRetrieveDevice:
            return LocalizationConstants.Errors.failedToRetrieveDevice
        case .inputError:
            return LocalizationConstants.Errors.inputError
        case .notAuthorized:
            return nil
        }
    }
}
