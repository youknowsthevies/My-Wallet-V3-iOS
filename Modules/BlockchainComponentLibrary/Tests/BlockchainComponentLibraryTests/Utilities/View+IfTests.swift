// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class ViewIfTests: XCTestCase {

    let view = Rectangle()

    func testIfThen() {
        let trueResult = view.if(true) { $0.fill(Color.green) }
        assertSnapshot(matching: trueResult.fixedSize(), as: .image, record: false)

        let falseResult = view.if(false) { $0.fill(Color.green) }
        assertSnapshot(matching: falseResult.fixedSize(), as: .image, record: false)
    }

    func testIfThenElse() {
        let trueResult = view.if(true) { $0.fill(Color.green) } else: { $0.fill(Color.red) }
        assertSnapshot(matching: trueResult.fixedSize(), as: .image, record: false)

        let falseResult = view.if(false) { $0.fill(Color.green) } else: { $0.fill(Color.red) }
        assertSnapshot(matching: falseResult.fixedSize(), as: .image, record: false)
    }

    func testIfLetThen() {
        let someOptional: String? = "t"
        let someResult = view.ifLet(someOptional) { view, value in
            view.fill(Color.green)
                .overlay(Text(value).typography(.micro))
        }
        assertSnapshot(matching: someResult.fixedSize(), as: .image, record: false)

        let nilOptional: String? = nil
        let nilResult = view.ifLet(nilOptional) { view, value in
            view.fill(Color.green)
                .overlay(Text(value).typography(.micro))
        }
        assertSnapshot(matching: nilResult.fixedSize(), as: .image, record: false)
    }

    func testIfLetThenElse() {
        let someOptional: String? = "t"
        let someResult = view
            .ifLet(
                someOptional,
                then: { view, value in
                    view.fill(Color.green)
                        .overlay(Text(value).typography(.micro))
                },
                else: { view in
                    view.fill(Color.red)
                }
            )
        assertSnapshot(matching: someResult.fixedSize(), as: .image, record: false)

        let nilOptional: String? = nil
        let nilResult = view.ifLet(
            nilOptional,
            then: { view, value in
                view.fill(Color.green)
                    .overlay(Text(value).typography(.micro))
            },
            else: { view in
                view.fill(Color.red)
            }
        )
        assertSnapshot(matching: nilResult.fixedSize(), as: .image, record: false)
    }
}
