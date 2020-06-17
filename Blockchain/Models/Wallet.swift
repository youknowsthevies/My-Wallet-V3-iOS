//
//  Wallet.swift
//  Blockchain
//
//  Created by Paulo on 16/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

extension Wallet {
    private enum WalletJavaScriptError: Error {
        case typeError
    }

    @objc func logJavaScriptTypeError(_ message: String, stack: String?) {
        let recorder: RecordingProviderAPI = RecordingProvider.default
        recorder.message.record("JS Stack: \(stack ?? "not available")")
        recorder.message.record("JS Error: \(message)")
        recorder.error.error(WalletJavaScriptError.typeError)
    }
}
