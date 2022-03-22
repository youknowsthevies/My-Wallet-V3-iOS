// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Tag {

    @dynamicMemberLookup
    public struct Context: @unchecked Sendable, Hashable, Equatable {
        public typealias Wrapped = [Tag.Reference: AnyHashable]
        public private(set) var dictionary: Wrapped
        public subscript<Value>(dynamicMember keyPath: KeyPath<Wrapped, Value>) -> Value {
            dictionary[keyPath: keyPath]
        }

        public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Wrapped, Value>) -> Value {
            get { dictionary[keyPath: keyPath] }
            set { dictionary[keyPath: keyPath] = newValue }
        }

        public subscript(reference: TaggedEvent) -> Value? {
            get { dictionary[reference.key] }
            set { dictionary[reference.key] = newValue }
        }

        public subscript<K: TaggedEvent>(reference: K) -> Value? {
            get { dictionary[reference.key] }
            set { dictionary[reference.key] = newValue }
        }
    }
}

extension Tag.Context: Collection {
    public typealias Index = Wrapped.Index
    public typealias Element = Wrapped.Element
    public var startIndex: Index { dictionary.startIndex }
    public var endIndex: Index { dictionary.endIndex }
    public subscript(index: Index) -> Element { dictionary[index] }
    public func index(after i: Index) -> Index { dictionary.index(after: i) }
}

extension Tag.Context: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (TaggedEvent, Wrapped.Value)...) {
        dictionary = Dictionary(elements.map { tag, value in
            (tag.key, value)
        }, uniquingKeysWith: { $1 })
    }
}

extension Tag.Context {

    public init(_ object: [L: Wrapped.Value]) {
        self.init(object.mapKeys(\.[]))
    }

    public init(_ object: [Tag: Wrapped.Value]) {
        self.init(object.mapKeys(\.reference))
    }

    public init(_ object: [Tag.Reference: Wrapped.Value]) {
        dictionary = object
    }
}

extension Tag.Context {

    public static func == (lhs: Tag.Context, rhs: Tag.Context) -> Bool { lhs.dictionary == rhs.dictionary }
    public static func == (lhs: Tag.Context, rhs: [L: Wrapped.Value]) -> Bool { lhs == Tag.Context(rhs) }
    public static func == (lhs: Tag.Context, rhs: [Tag: Wrapped.Value]) -> Bool { lhs == Tag.Context(rhs) }
    public static func == (lhs: Tag.Context, rhs: [Tag.Reference: Wrapped.Value]) -> Bool { lhs.dictionary == rhs }
    public static func == (lhs: [L: Wrapped.Value], rhs: Tag.Context) -> Bool { Tag.Context(lhs) == rhs }
    public static func == (lhs: [Tag: Wrapped.Value], rhs: Tag.Context) -> Bool { Tag.Context(lhs) == rhs }
    public static func == (lhs: [Tag.Reference: Wrapped.Value], rhs: Tag.Context) -> Bool { lhs == rhs.dictionary }
}

extension Tag.Context {

    public func decode<K: TaggedEvent, T: Decodable>(
        _ key: K,
        as type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try FetchResult.value(self[key] as Any, key.key.metadata())
            .decode(as: T.self, decoder: decoder)
            .get()
    }
}

extension Tag.Context {

    public func filter(_ isIncluded: (Tag.Context.Element) throws -> Bool) rethrows -> Tag.Context {
        try Tag.Context(dictionary.filter(isIncluded))
    }

    public func mapKeys<A>(_ transform: (Key) throws -> A) rethrows -> [A: Value] {
        try reduce(into: [:]) { a, e in try a[transform(e.key)] = e.value }
    }

    public func mapKeysAndValues<A, B>(key: (Key) throws -> A, value: (Value) throws -> B) rethrows -> [A: B] {
        try reduce(into: [:]) { a, e in try a[key(e.key)] = value(e.value) }
    }
}

extension Tag.Context {

    public static func += (lhs: inout Tag.Context, rhs: Tag.Context) { lhs = lhs + rhs }
    public static func + (lhs: Tag.Context, rhs: Tag.Context) -> Tag.Context {
        Tag.Context(lhs.dictionary.merging(rhs.dictionary, uniquingKeysWith: { $1 }))
    }
}

public protocol TaggedEvent: CustomStringConvertible {
    func key(_ context: Tag.Context) -> Tag.Reference
}

extension TaggedEvent {
    var key: Tag.Reference { key([:]) }
}

extension L: TaggedEvent, CustomStringConvertible {
    public var description: String { self(\.id) }
    public func key(_ context: Tag.Context) -> Tag.Reference { self[].ref(to: context) }
}

extension Tag: TaggedEvent {
    public typealias Event = TaggedEvent
    public var key: Tag.Reference { key([:]) }
    public func key(_ context: Tag.Context) -> Tag.Reference { Tag.Reference(unchecked: self, context: context) }
}

extension Tag.Reference: TaggedEvent {
    public var key: Tag.Reference { self }
    public func key(_ context: Tag.Context) -> Tag.Reference { ref(to: context) }
}

extension TaggedEvent {

    public static func + (event: TaggedEvent, context: Tag.Context) -> Tag.Reference {
        switch event {
        case let tag as L:
            return Tag.Reference(tag[], to: context, in: nil)
        case let tag as Tag:
            return Tag.Reference(tag, to: context, in: nil)
        case let reference as Tag.Reference:
            return reference.ref(to: context)
        default:
            return event.key(context)
        }
    }
}
