// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol NativeWalletLoggerAPI {
    func log(message: String, metadata: [String: String]?)
}

extension Publisher {
    func logMessageOnOutput(
        logger: NativeWalletLoggerAPI,
        messageAndMetadata: @escaping (Self.Output) -> (String, [String: String]?)
    ) -> Publishers.HandleEvents<Self> {
        #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        handleEvents(receiveOutput: { value in
            let (message, metadata) = messageAndMetadata(value)
            return logger.log(
                message: message,
                metadata: metadata
            )
        })
        #endif
    }

    func logMessageOnOutput(
        logger: NativeWalletLoggerAPI,
        message: @escaping (Self.Output) -> String
    ) -> Publishers.HandleEvents<Self> {
        #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        handleEvents(receiveOutput: { value in
            let message = message(value)
            return logger.log(
                message: message,
                metadata: nil
            )
        })
        #endif
    }
}
