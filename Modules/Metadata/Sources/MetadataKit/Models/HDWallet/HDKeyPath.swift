// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataHDWalletKit
import ToolKit

public enum HDWalletKitError: Error {
    case unknown
}

public struct HDKeyPath: LosslessStringConvertible {

    public var description: String {
        components.path
    }

    public let components: [DerivationComponent]

    init(_ component: DerivationComponent, relative: Bool = true) throws {
        try self.init([component], relative: relative)
    }

    init(_ index: Int, relative: Bool = true) throws {
        try self.init([.normal(UInt32(index))], relative: relative)
    }

    init(_ components: [DerivationComponent], relative: Bool = true) throws {
        switch path(from: components) {
        case .success:
            break
        case .failure(let error):
            throw error
        }
        self.components = components
    }

    public init?(_ description: String) {
        func parseComponents(
            path: String
        ) -> Result<[DerivationComponent], HDWalletKitError> {
            let prefix = "m/"
            guard path.hasPrefix(prefix) else {
                return .failure(.unknown)
            }
            let componentStrings = path
                .removing(prefix: prefix)
                .split(separator: "/")
                .map(String.init)
            return Result<[String], HDWalletKitError>.success(componentStrings)
                .flatMap { components -> Result<[DerivationComponent], HDWalletKitError> in
                    var derivationComponents: [DerivationComponent] = []
                    for component in components {
                        guard let derivationComponent = DerivationComponent(item: component) else {
                            return .failure(.unknown)
                        }
                        derivationComponents.append(derivationComponent)
                    }
                    return .success(derivationComponents)
                }
        }

        guard let components = try? parseComponents(path: description).get() else {
            return nil
        }
        self.components = components
    }

    fileprivate init(with components: [DerivationComponent], relative: Bool = true) {
        self.components = components
    }
}

extension HDKeyPath {

    public static func from(
        components: [DerivationComponent],
        relative: Bool = true
    ) -> Result<HDKeyPath, HDWalletKitError> {
        Result { try HDKeyPath(components, relative: relative) }
            .mapError { $0 as! HDWalletKitError }
    }

    public static func from(
        component: DerivationComponent,
        relative: Bool = true
    ) -> Result<HDKeyPath, HDWalletKitError> {
        Result { try HDKeyPath(component, relative: relative) }
            .mapError { $0 as! HDWalletKitError }
    }

    public static func from(
        index: Int,
        relative: Bool = true
    ) -> Result<HDKeyPath, HDWalletKitError> {
        Result { try HDKeyPath(index, relative: relative) }
            .mapError { $0 as! HDWalletKitError }
    }
}

extension HDKeyPath {

    public func with(
        hardened index: UInt32,
        relative: Bool = true
    ) -> Result<Self, HDWalletKitError> {
        Result { try HDKeyPath(components + [.hardened(index)], relative: relative) }
            .mapError { $0 as! HDWalletKitError }
    }

    public func with(
        normal index: UInt32,
        relative: Bool = true
    ) -> Result<Self, HDWalletKitError> {
        Result { try HDKeyPath(components + [.normal(index)], relative: relative) }
            .mapError { $0 as! HDWalletKitError }
    }
}

extension Result where Success == HDKeyPath, Failure == HDWalletKitError {

    public func with(
        normal index: UInt32,
        relative: Bool = true
    ) -> Result<Success, Failure> {
        flatMap { path -> Result<Success, Failure> in
            path.with(normal: index, relative: relative)
        }
    }

    public func with(
        hardened index: UInt32,
        relative: Bool = true
    ) -> Result<Success, Failure> {
        flatMap { path -> Result<Success, Failure> in
            path.with(hardened: index, relative: relative)
        }
    }
}

private func path(
    from components: [DerivationComponent]
) -> Result<HDKeyPath, HDWalletKitError> {
    .success(HDKeyPath(with: components))
}
