// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import NetworkError
import ToolKit

public struct NabuErrorDecodingFailure: Error {
    let id: String?
    let code: NabuErrorCode?
    let type: NabuErrorType?
    let description: String?
}

public enum NabuNetworkError: Error, Decodable {

    enum CodingKeys: CodingKey {
        case id
        case code
        case type
        case description
    }

    case nabuError(NabuError)
    case communicatorError(NetworkError)

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let id = try values.decodeIfPresent(String.self, forKey: .id)
        var code: NabuErrorCode = .unknown
        var type: NabuErrorType = .unknown
        let description = try values.decodeIfPresent(String.self, forKey: .description)

        do {
            code = try values.decodeIfPresent(NabuErrorCode.self, forKey: .code) ?? .unknown
            type = try values.decodeIfPresent(NabuErrorType.self, forKey: .type) ?? .unknown
        } catch {
            if BuildFlag.isInternal {
                Self.crashOnUnknownCodeOrType(code: code, type: type, values: values)
            } else {
                ProbabilisticRunner.run(for: .pointZeroOnePercent) {
                    Self.crashOnUnknownCodeOrType(code: code, type: type, values: values)
                }
            }
            throw NabuErrorDecodingFailure(
                id: id,
                code: code,
                type: type,
                description: description
            )
        }
        self = .nabuError(NabuError(id: id, code: code, type: type, description: description))
    }

    public init(from communicatorError: NetworkError) {
        self = .communicatorError(communicatorError)
    }

    private static func crashOnUnknownCodeOrType(
        code: NabuErrorCode,
        type: NabuErrorType,
        values: KeyedDecodingContainer<NabuNetworkError.CodingKeys>
    ) {
        guard code == .unknown || type == .unknown else { return }

        var messages: [String] = []

        if code == .unknown {
            if let code = try? values.decode(Int.self, forKey: .code) {
                messages.append("Unknown code: \(code)")
            } else {
                messages.append("Missing code")
            }
        }

        if type == .unknown {
            if let type = try? values.decode(String.self, forKey: .type) {
                messages.append("Unknown type: \(type)")
            } else {
                messages.append("Missing type")
            }
        }

        fatalError(messages.joined(separator: ", "))
    }
}

extension NabuNetworkError: CustomStringConvertible {

    public var description: String {
        switch self {
        case .nabuError(let error):
            return String(describing: error)
        case .communicatorError(let error):
            return String(describing: error)
        }
    }
}

extension NabuNetworkError: Equatable {

    /// Just a simple implementation to bubble up this to UI States. We can improve on this if needed.
    public static func == (lhs: NabuNetworkError, rhs: NabuNetworkError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}

extension NabuNetworkError: FromNetworkErrorConvertible {

    public static func from(_ networkError: NetworkError) -> NabuNetworkError {
        NabuNetworkError(from: networkError)
    }
}
