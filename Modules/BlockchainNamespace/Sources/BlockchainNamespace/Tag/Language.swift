// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Lexicon

public final class Language {

    public let graph: Lexicon.Graph
    public var date: Date { graph.date }

    public private(set) var root: Tag!

    public let queue: DispatchQueue
    private let key: DispatchSpecificKey<Void>

    var _nodes: [Tag.ID: Tag] = [:]
    var nodes: [Tag.ID: Tag] {
        get { sync { _nodes } }
        set { sync { _nodes = newValue } }
    }

    private init(graph: Lexicon.Graph) throws {
        self.graph = graph
        queue = DispatchQueue(
            label: "com.blockchain.namespace.language.queue.\(Language.id)",
            qos: .userInitiated
        )
        let key = DispatchSpecificKey<Void>()
        queue.setSpecific(key: key, value: ())
        self.key = key
        root = Tag.add(parent: nil, node: graph.root, to: self)
        Self.unownedLanguageReferences.append(self)
    }
}

extension Language {

    private static var count: UInt = 0
    private static let lock = NSLock()
    private static var id: UInt {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }

    private func sync<T>(execute work: () throws -> T) rethrows -> T {
        DispatchQueue.getSpecific(key: key) == nil
            ? try queue.sync(execute: work)
            : try work()
    }
}

extension Language {

    public subscript(id: Tag.ID) -> Tag? { tag(id) }
    public subscript(id: L) -> Tag { tag(id(\.id))! }

    public func tag(_ id: Tag.ID) -> Tag? {
        sync { nodes[id] ?? root[id.dotPath(after: root.id).splitIfNotEmpty(separator: ".").string] }
    }
}

extension Language {

    public static func root(of graph: Lexicon.Graph) throws -> Tag {
        try Language(graph: graph).root
    }

    public static func root(taskpaper: Data) throws -> Tag {
        try root(of: TaskPaper(taskpaper).decode())
    }
}

extension Language {

    public static let errors: AnyPublisher<Tag.Error, Never> = subject
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()

    private static let subject = PassthroughSubject<Tag.Error, Never>()

    public func post(
        error description: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        let error = Tag.Error(
            tag: blockchain[],
            message: description,
            function,
            file,
            line
        )
        Language.subject.send(error)
        #if DEBUG
        fatalError(String(describing: error))
        #endif
    }

    public func post(error: Error, function: String = #function, file: String = #file, line: Int = #line) {
        post(error: String(describing: error), function: function, file: file, line: line)
    }
}

extension Language {

    // swiftlint:disable force_try
    public static let root: Tag = try! Language.root(
        taskpaper: Data(
            contentsOf: URL(
                fileURLWithPath: Bundle.module.path(
                    forResource: "blockchain",
                    ofType: "taskpaper"
                )!
            )
        )
    )

    static var unownedLanguageReferences: [Language] = []
}

extension Language: Identifiable, Hashable {

    public static func == (lhs: Language, rhs: Language) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
