// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable type_name

import Foundation

public struct Tag {

    public typealias ID = String
    public typealias Name = String

    public let id: ID
    public var name: Name { node.name }

    public let node: Graph.Node
    public unowned let language: Language

    public var parent: Tag? { parentID.flatMap(language.tag) }
    private let parentID: ID?

    public var children: [Name: Tag] { Tag.children(of: self) }
    public var type: [Graph.Node.ID: Graph.Node] { Tag.type(of: self) }
    public var lineage: UnfoldFirstSequence<Tag> { Tag.lineage(of: self) }

    init(parent: ID?, node: Graph.Node, in language: Language) {
        parentID = parent
        id = parent?.dot(node.name) ?? node.name
        self.node = node
        self.language = language
    }
}

extension Tag {

    public init(_ identifier: L, in language: Language) {
        do {
            self = try Tag(id: identifier(\.id), in: language)
        } catch {
            fatalError(
                """
                Failed to load language from identifier \(identifier(\.id))
                \(error)
                """
            )
        }
    }

    public init(id: String, in language: Language) throws {
        if id.isEmpty {
            self = blockchain.db.type.tag.none[]
        } else if let tag = language.tag(id) {
            self = tag
        } else {
            throw Graph.Error(
                language: language.graph.date,
                description: "'\(id)' does not exist in language"
            )
        }
    }
}

extension L {
    public subscript() -> Tag { Tag(self, in: Language.root.language) }
}

extension Tag {

    public func `is`(_ type: L) -> Bool {
        `is`(type[])
    }

    public func `is`(_ types: L...) -> Bool {
        for type in types where isNot(type) { return false }
        return true
    }

    public func `is`(_ tag: Tag) -> Bool {
        type.values.contains(tag.node)
    }

    public func `is`(_ types: Tag...) -> Bool {
        for type in types where isNot(type) { return false }
        return true
    }

    public func isNot(_ type: L) -> Bool {
        `is`(type) == false
    }

    public func isNot(_ type: Tag) -> Bool {
        `is`(type) == false
    }
}

public func ~= (lhs: L, rhs: L) -> Bool {
    rhs[].is(lhs[])
}

public func ~= (lhs: L, rhs: Tag) -> Bool {
    rhs.is(lhs[])
}

public func ~= (lhs: Tag, rhs: L) -> Bool {
    rhs[].is(lhs)
}

public func ~= (lhs: Tag, rhs: Tag) -> Bool {
    rhs.is(lhs)
}

extension Tag {

    public func isAncestor(of other: Tag) -> Bool {
        id.isDotPathAncestor(of: other.id)
    }

    public func isDescendant(of other: Tag) -> Bool {
        id.isDotPathDescendant(of: other.id)
    }

    public func idRemainder(after tag: Tag) throws -> Substring {
        guard isDescendant(of: tag) else {
            throw error(message: "\(tag) is not an ancestor of \(self)")
        }
        return id.dotPath(after: tag.id)
    }
}

public func ~= <T>(pattern: (T) -> Bool, value: T) -> Bool {
    pattern(value)
}

public func isAncestor(of a: L) -> (Tag) -> Bool {
    isAncestor(of: a[])
}

public func isAncestor(of a: Tag) -> (Tag) -> Bool {
    { b in b.isAncestor(of: a) }
}

public func isDescendant(of a: L) -> (Tag) -> Bool {
    isDescendant(of: a[])
}

public func isDescendant(of a: Tag) -> (Tag) -> Bool {
    { b in b.isDescendant(of: a) }
}

extension Tag {

    public func `as`<T: L>(_ other: T) throws -> T {
        guard `is`(other[]) else {
            throw error(message: "\(self) is not a \(other)")
        }
        return other
    }
}

extension Tag {

    public subscript(descendant: Name...) -> Tag? {
        self[descendant]
    }

    public subscript<Descendant>(
        descendant: Descendant
    ) -> Tag? where Descendant: Collection, Descendant.Element == Name {
        var result = self
        for name in descendant {
            guard let tag = result.children[name] else {
                return nil
            }
            result = (try? tag.node.protonym.map { try Tag(id: $0, in: language) }) ?? tag
        }
        return result
    }
}

extension Tag {

    @discardableResult
    static func add(parent: ID?, node: Graph.Node, to language: Language) -> Tag {
        let id = parent?.dot(node.name) ?? node.name
        if let node = language.nodes[id] { return node }
        let tag = Tag(parent: parent, node: node, in: language)
        language.nodes[tag.id] = tag
        return tag
    }

    static func lineage(of id: Tag) -> UnfoldFirstSequence<Tag> {
        sequence(first: id, next: \.parent)
    }

    static func children(of tag: Tag) -> [Name: Tag] {
        tag.type.values.reduce(into: [:]) { nodes, type in
            for name in type.children {
                let nodeID = type.id.dot(name)
                do {
                    guard let node = tag.language.graph.nodes[nodeID] else {
                        throw Graph.Error(
                            language: tag.language.graph.date,
                            description: "Missing node id '\(nodeID)' of child '\(name)' of \(tag)"
                        )
                    }
                    nodes[name] = Tag.add(parent: tag.id, node: node, to: tag.language)
                } catch {
                    tag.language.post(error: error)
                    continue
                }
            }
        }
    }

    static func type(of tag: Tag) -> [Graph.Node.ID: Graph.Node] {
        var type: Set<Graph.Node> = []
        var ids = tag.node.type
        while !ids.isEmpty {
            let id = ids.removeFirst()
            do {
                guard let node = tag.language.graph.nodes[id] else {
                    throw Graph.Error(
                        language: tag.language.graph.date,
                        description: "Type '\(id)' does not exist"
                    )
                }
                type.insert(node)
                ids.formUnion(node.type)
            } catch {
                tag.language.post(error: error)
                continue
            }
        }
        return type.reduce(
            into: [tag.node.id: tag.node] + [tag.id: tag.node]
        ) { types, node in types[node.id] = node }
    }
}

extension Tag: Equatable, Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id && lhs.language == rhs.language
    }
}

extension CodingUserInfoKey {
    public static let language = CodingUserInfoKey(rawValue: "com.blockchain.namespace.language")!
}

extension Tag: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let language = decoder.userInfo[.language] as? Language ?? Language.root.language
        let id = try container.decode(String.self)
        try self.init(id: id, in: language)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}
