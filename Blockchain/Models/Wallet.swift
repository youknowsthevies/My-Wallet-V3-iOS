//
//  Wallet.swift
//  Blockchain
//
//  Created by Paulo on 16/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import ToolKit

extension Wallet {
    private enum WalletJavaScriptError: Error {
        case typeError
    }

    @objc func logJavaScriptTypeError(_ message: String, stack: String?) {
        let messageRecorder: MessageRecording = resolve()
        let errorRecorder: ErrorRecording = resolve()
        messageRecorder.record("JS Stack: \(stack ?? "not available")")
        messageRecorder.record("JS Error: \(message)")
        errorRecorder.error(WalletJavaScriptError.typeError)
    }
}
