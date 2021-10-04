// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

/// Describes an error returned by Nabu
public struct NabuError: Error, Codable, Equatable, Identifiable {

    private enum CodingKeys: String, CodingKey {
        case id
        case code
        case type
        case serverDescription = "description"
    }

    public let id: String
    public let code: NabuErrorCode
    public let type: NabuErrorType
    public let serverDescription: String?

    public var localizedDescription: String? {
        description
    }

    public init(
        id: String?,
        code: NabuErrorCode,
        type: NabuErrorType,
        description: String?
    ) {
        self.id = id ?? Self.missingId()
        self.code = code
        self.type = type
        serverDescription = description
    }

    public init(
        id: String,
        code: NabuErrorCode,
        type: NabuErrorType,
        description: String?
    ) {
        self.id = id
        self.code = code
        self.type = type
        serverDescription = description
    }

    private static func missingId() -> String {
        "MISSING_ID_" + UUID().uuidString
    }
}

extension NabuError: CustomStringConvertible {

    /// Provides the error description that backend sent back,
    /// if no description is provided or in case it is empty the error code will be displayed
    /// otherwise the error will be in the form of "{error-description} - Error code: {code}"
    public var description: String {
        guard let description = serverDescription, !description.isEmpty else {
            return "\(LocalizationConstants.Errors.errorCode): \(code)"
        }
        return "\(description) - \(LocalizationConstants.Errors.errorCode): \(code)"
    }
}
