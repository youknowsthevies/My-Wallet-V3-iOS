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

        guard let input = input else {
            exit(EXIT_FAILURE)
        }

        let directory = output ?? input.deletingLastPathComponent()

        let taskpaper = try TaskPaper(String(contentsOfFile: input.path)).decode()
        let lexicon = await Lexicon.from(taskpaper)
        let json = await lexicon.json()

        do {
            let gen = try JSONClasses.generate(json)
            let file = directory.appendingPathComponent("blockchain.json")
            print("📄 Writing to", file.path, terminator: " ")
            try gen.write(to: file)
            print("✅")
        }

        do {
            let gen = try SwiftLexicon.Generator.generate(json)
            let file = directory.appendingPathComponent("blockchain.swift")
            print("📄 Writing to", file.path, terminator: " ")
            try gen.write(to: file)
            print("✅")
        }
    }
}
