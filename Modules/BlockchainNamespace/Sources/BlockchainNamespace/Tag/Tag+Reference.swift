// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Tag {

    public func ref(to indices: L.Context = [:]) -> Tag.Reference {
        ref(to: indices, in: nil)
    }

    public func ref(to indices: L.Context = [:], in app: AppProtocol?) -> Tag.Reference {
        Tag.Reference(self, to: indices.mapKeys(\.[]), in: app)
    }

    public func ref(to indices: Tag.Context) -> Tag.Reference {
        ref(to: indices, in: nil)
    }

    public func ref(to indices: Tag.Context, in app: AppProtocol?) -> Tag.Reference {
        Tag.Reference(self, to: indices, in: app)
    }
}

extension Tag {

    public struct Reference {

        public typealias Indices = [Tag: String]
        public typealias Context = [Tag: Any]

        public let tag: Tag

        public let indices: Indices
        public let context: Context

        public let string: String

        var error: Swift.Error?

        init(_ tag: Tag, to context: Context, in app: AppProtocol?) {
            self.tag = tag
            self.context = context
            do {
                let ids = try tag.template.indices(from: context, in: app)
                let indices = try Dictionary(
                    uniqueKeysWithValues: zip(
                        tag.template.indices.map { try Tag(id: $0, in: tag.language) },
                        ids
                    )
                )
                self.indices = indices
                string = Self.id(
                    tag: tag,
                    to: context,
                    indices: indices
                )
            } catch {
                indices = [:]
                string = tag.id
                self.error = error
            }
        }
    }
}

extension Tag.Reference {

    public var hasError: Bool { error != nil }

    @discardableResult
    public func validated() throws -> Tag.Reference {
        guard let error = error else { return self }
        throw error
    }
}

extension Tag.Reference {

    // swiftlint:disable:next force_try
    public static let pattern = try! NSRegularExpression(pattern: #"\.(?<name>[\w_]+)(?:\[(?<id>[^\.]+)\])?"#)

    public init(id: String, in language: Language) throws {

        var tag = blockchain[]
        var indices: [Tag: String] = [:]

        for match in Tag.Reference.pattern.matches(in: id, range: NSRange(id.startIndex..<id.endIndex, in: id)) {

            let range = (
                name: match.range(withName: "name"),
                id: match.range(withName: "id")
            )

            tag = try tag.child(named: id[range.name].string)
            guard range.id.location != NSNotFound else { continue }
            try indices[
                tag.child(named: blockchain.db.collection.id[].name)
            ] = id[range.id].string
        }
        self.init(tag, to: indices, in: nil)
    }
}

extension Tag.Reference {

    public func id(ignoring: Set<L>) -> String {
        id(ignoring: ignoring.map(\.[]).set)
    }

    public func id(ignoring: Set<Tag> = []) -> String {
        Self.id(
            tag: tag,
            to: context,
            indices: indices,
            ignoring: ignoring
        )
    }

    fileprivate static func id(
        tag: Tag,
        to context: Context,
        indices: Indices,
        ignoring: Set<Tag> = []
    ) -> String {
        var ignoring = ignoring
        if tag.is(blockchain.db.collection.id) {
            ignoring.insert(tag)
        }
        guard indices.keys.count(where: ignoring.doesNotContain) > 0 else {
            return tag.id
        }
        return tag.lineage
            .reversed()
            .map { info in
                guard
                    let collectionId = info["id"],
                    ignoring.doesNotContain(collectionId),
                    let id = context[collectionId]
                else {
                    return info.name
                }
                return "\(info.name)[\(id)]"
            }
            .joined(separator: ".")
    }
}

extension Tag.Reference: Equatable {

    public static func == (lhs: Tag.Reference, rhs: Tag.Reference) -> Bool {
        lhs.string == rhs.string
    }
}

extension Tag.Reference: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }
}

extension Tag.Reference: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let language = decoder.userInfo[.language] as? Language ?? Language.root.language
        try self.init(id: container.decode(String.self), in: language)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
}

extension Tag.Reference {

    public struct Template {

        private let tag: Tag
        public private(set) var indices: [String] = []

        init(_ tag: Tag) {
            self.tag = tag
            var id = ""
            for crumb in tag.breadcrumb {
                if crumb.name == crumb.id {
                    id = crumb.name
                    continue
                }
                id += ".\(crumb.name)"
                if crumb.is(blockchain.db.collection) {
                    indices.append(id + ".id")
                }
            }
        }

        func indices(from ids: Tag.Context, in app: AppProtocol?) throws -> [String] {
            let ids = ids.mapKeysAndValues(
                key: \.id,
                value: String.init(describing:)
            )
            return try indices.map { id in
                if let value = ids[id], value.isNotEmpty {
                    return value
                } else if tag.id == id {
                    return "ø"
                } else if let tag = app?.language[id], let value = try? app?.state.get(tag) as? String {
                    return value
                } else {
                    throw tag.error(message: "Missing index \(id) for ref to \(tag.id)")
                }
            }
        }
    }
}

extension Tag.Reference: CustomStringConvertible {
    public var description: String { string }
}
