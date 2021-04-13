//
//  TargetSelectionQRScanningViewModel.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 3/16/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformUIKit

struct TargetSelectionQRScanningViewModel: QRCodeScannerTextViewModel {
    let loadingText: String? = nil
    let headerText: String = LocalizationConstants.scanQRCode
}
