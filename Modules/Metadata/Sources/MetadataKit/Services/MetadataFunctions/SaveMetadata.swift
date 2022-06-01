// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers
import Errors
import Foundation
import MetadataHDWalletKit
import ToolKit

public enum SaveMetadataError: Error {
    case failedToDeriveNode(MetadataNodeError)
    case failedToCreateMessage(Error)
    case failedToSignMessage(Error)
    case failedToPutMetadata(NetworkError)
    case failedToValidateJSON(JSONValidationError)
    case failedToEncryptPayload(Error)
    case failedToCreateMagicHash(Error)
    case network(NetworkError)
}

struct SaveInput {
    var payloadJson: String
    var type: EntryType
    var nodes: RemoteMetadataNodes
}

typealias SaveNodeToMetadata =
    (SaveInput) -> AnyPublisher<Void, SaveMetadataError>

func provideSave(
    fetch: @escaping FetchMetadataEntry,
    put: @escaping PutMetadataEntry
) -> SaveNodeToMetadata {
    { input in
        save(
            input: input,
            putMetadata: put,
            fetchMetadata: fetch
        )
    }
}

func save(
    input: SaveInput,
    putMetadata: @escaping PutMetadataEntry,
    fetchMetadata: @escaping FetchMetadataEntry
) -> AnyPublisher<Void, SaveMetadataError> {
    MetadataNode
        .from(
            metaDataHDNode: input.nodes.metadataNode,
            metadataDerivation: MetadataDerivation(),
            for: input.type
        )
        .publisher
        .mapError(SaveMetadataError.failedToDeriveNode)
        .flatMap { metadata -> AnyPublisher<Void, SaveMetadataError> in
            saveMetadata(
                input: .init(
                    payloadJson: input.payloadJson,
                    metadata: metadata
                ),
                fetchMetadata: fetchMetadata,
                putMetadata: putMetadata
            )
        }
        .eraseToAnyPublisher()
}

private enum Constants {

    static let maxMetadataAttempts = 1

    static let metadataVersion = 1
}

struct SaveConfig {

    static let `default` = Self(
        scheduler: DispatchQueue.global().eraseToAnyScheduler(),
        maxAttempts: Constants.maxMetadataAttempts
    )

    let scheduler: AnySchedulerOf<DispatchQueue>
    let maxAttempts: Int
}

struct SaveMetadataInput {
    var payloadJson: String
    var metadata: MetadataNode
}

typealias SaveMetadata =
    (SaveMetadataInput) -> AnyPublisher<Void, SaveMetadataError>

func provideSaveMetadata(
    fetch: @escaping FetchMetadataEntry,
    put: @escaping PutMetadataEntry
) -> SaveMetadata {
    { input in
        saveMetadata(
            input: input,
            fetchMetadata: fetch,
            putMetadata: put
        )
    }
}

func saveMetadata(
    input: SaveMetadataInput,
    fetchMetadata: @escaping FetchMetadataEntry,
    putMetadata: @escaping PutMetadataEntry,
    config: SaveConfig = .default
) -> AnyPublisher<Void, SaveMetadataError> {

    let payloadJson = input.payloadJson
    let metadata = input.metadata

    let writeMetadata: (Data) -> AnyPublisher<Void, SaveMetadataError> = { encrypted in
        let encryptedPayloadBytes = encrypted
            .base64EncodedString()
            .bytes
        return fetchMagic(address: metadata.address, fetchMetadata: fetchMetadata)
            .flatMap { m -> AnyPublisher<(Data, [UInt8]), SaveMetadataError> in
                MetadataUtil.message(
                    payload: encryptedPayloadBytes
                )
                .publisher
                .map { message -> (Data, [UInt8]) in
                    (m, message)
                }
                .mapError(SaveMetadataError.failedToCreateMessage)
                .eraseToAnyPublisher()
            }
            .flatMap { m, message
                -> AnyPublisher<(Data, String), SaveMetadataError> in
                sign(bitcoinMessage: message, with: metadata)
                    .map { sig -> (Data, String) in
                        (m, sig)
                    }
                    .mapError(SaveMetadataError.failedToSignMessage)
                    .publisher
                    .eraseToAnyPublisher()
            }
            .flatMap { m, sig -> AnyPublisher<Void, SaveMetadataError> in
                let body = MetadataBody(
                    version: Constants.metadataVersion,
                    payload: encrypted.base64EncodedString(),
                    signature: sig,
                    prevMagicHash: m.hex,
                    typeId: Int(metadata.type.rawValue)
                )
                return putMetadata(metadata.address, body)
                    .mapError(SaveMetadataError.failedToPutMetadata)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    return validateJSON(jsonString: payloadJson)
        .mapError(SaveMetadataError.failedToValidateJSON)
        .publisher
        .flatMap { validJSON -> AnyPublisher<Void, SaveMetadataError>in
            let data = Data(validJSON.utf8)
            return AESUtil
                .encryptWithKey(
                    key: metadata.encryptionKey,
                    data: data
                )
                .mapError(SaveMetadataError.failedToEncryptPayload)
                .publisher
                .flatMap { encrypted -> AnyPublisher<Void, SaveMetadataError> in
                    writeMetadata(encrypted)
                        .catch { error -> AnyPublisher<Void, SaveMetadataError> in
                            guard case .network(let networkError) = error else {
                                return .failure(error)
                            }
                            guard networkError.is404 else {
                                return .failure(error)
                            }
                            return writeMetadata(encrypted)
                                .delay(for: 1, scheduler: config.scheduler)
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}

private func fetchMagic(
    address: String,
    fetchMetadata: FetchMetadataEntry
) -> AnyPublisher<Data, SaveMetadataError> {
    fetchMetadata(address)
        .mapError(SaveMetadataError.network)
        .flatMap { payload -> AnyPublisher<[UInt8], SaveMetadataError> in
            let encryptedPayloadBytes = Data(payload.payload.utf8)
                .base64EncodedData()
                .bytes

            guard let prevMagicHash = payload.prevMagicHash else {
                return MetadataUtil.magic(
                    payload: encryptedPayloadBytes,
                    prevMagicHash: nil
                )
                .mapError(SaveMetadataError.failedToCreateMagicHash)
                .publisher
                .eraseToAnyPublisher()
            }

            let prevMagicBytes = Data(hex: prevMagicHash).bytes

            return MetadataUtil.magic(
                payload: encryptedPayloadBytes,
                prevMagicHash: prevMagicBytes
            )
            .mapError(SaveMetadataError.failedToCreateMagicHash)
            .publisher
            .eraseToAnyPublisher()
        }
        .map(Data.init(_:))
        .eraseToAnyPublisher()
}
