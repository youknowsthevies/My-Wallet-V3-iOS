import Foundation
import Lexicon
import SwiftLexicon

@main
enum Main {

    static func main() async throws {

        var arguments = ProcessInfo.processInfo.arguments.dropFirst()
            .makeIterator()

        var input: URL?
        var output: URL?

        while let argument = arguments.next() {
            switch argument {
            case "--taskpaper", "-i":
                input = arguments.next().map(URL.init(fileURLWithPath:))
            case "--output-directory", "-o":
                output = arguments.next().map(URL.init(fileURLWithPath:))
            default:
                continue
            }
        }

        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let module = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("BlockchainNamespace")

        if FileManager.default.fileExists(
            atPath: cwd.appendingPathComponent("blockchain.taskpaper").path
        ) {
            input = cwd.appendingPathComponent("blockchain.taskpaper")
        }

        if input == nil, output == nil {
            input = module.appendingPathComponent("blockchain.taskpaper")
            output = module
        }

        guard let input = input else {
            exit(EXIT_FAILURE)
        }

        let directory = output ?? input.deletingLastPathComponent()

        let taskpaper = try TaskPaper(String(contentsOfFile: input.path))
        let lexicon = try await Lexicon.from(taskpaper.decode())
        let json = await lexicon.json()

        do {
            let gen = try SwiftLexicon.Generator.generate(json)
            let file = directory.appendingPathComponent("blockchain.swift")
            print("📄 Writing to", file.lastPathComponent, terminator: " ")
            try gen.write(to: file)
            print("✅")
        }

        do {
            print("📄 Writing to", input.lastPathComponent, terminator: " ")
            try await TaskPaper.encode(lexicon.graph)
                .write(to: input, atomically: true, encoding: .utf8)
            print("✅")
        }
    }
}
