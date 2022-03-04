// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import Combine
import FeatureQRCodeScannerDomain
import Localization

typealias RequestCameraAccess = () -> Result<AVCaptureDeviceInput, AVCaptureDeviceError>

/// Check if the device input is accessible for scanning QR codes
func deviceInputRequest() -> Result<AVCaptureDeviceInput, AVCaptureDeviceError> {
    do {
        let input = try AVCaptureDeviceInput.deviceInputForQRScanner()
        return .success(input)
    } catch {
        guard let error = error as? AVCaptureDeviceError else {
            return .failure(.unknown)
        }
        return .failure(error)
    }
}

func hasAccessToCamera() -> AVAuthorizationStatus {
    AVCaptureDevice.authorizationStatus(for: .video)
}
