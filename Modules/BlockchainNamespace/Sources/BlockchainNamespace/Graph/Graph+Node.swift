// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable type_name

import Foundation

extension Graph {

    public struct Node: Decodable {

        public typealias ID = String
        public typealias Name = String
        public typealias Protonym = String

        public let id: ID
        public let name: Name
        public let protonym: ID?
        public let type: Set<ID>
        public let children: Set<Name>
        public let synonyms: [Name: Protonym]?
        public let supertype: ID?
        public let mixin: Mixin?
    }
}

extension Graph.Node {

    public var isRoot: Bool { id == name }

    public func `is`(_ node: Graph.Node) -> Bool {
        type.contains(node.id)
    }
}

extension Graph.Node {

    public struct Mixin: Decodable {
        public var type: ID
        public var children: [Name: ID]?
    }
}

extension Graph.Node: Identifiable, Hashable, CustomStringConvertible {

    public static func == (lhs: Graph.Node, rhs: Graph.Node) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var description: String { id }
}
