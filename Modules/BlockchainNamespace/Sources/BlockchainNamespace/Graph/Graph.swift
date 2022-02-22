// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Graph {

    public let date: Date
    public let root: Node
    public let nodes: [Node.ID: Node]

    public init(date: Date, nodes: [Node.ID: Node], root: Node.ID) throws {
        guard let root = nodes[root], root.isRoot else {
            throw Graph.Error(language: date, description: "Graph \(date) does not have a root node")
        }
        self.date = date
        self.root = root
        self.nodes = nodes
    }
}
