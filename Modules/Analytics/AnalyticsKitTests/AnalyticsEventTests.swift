// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

@testable import AnalyticsKit

class AnalyticsEventTests: XCTestCase {
    enum NewAnalyticsEvent: AnalyticsEvent {
        var type: AnalyticsEventType { .new }

        case simpleEventWithoutParams
        case eventWithParams(nameOfTheParam: String, valueOfTheParam: Double)
        case eventWithCustom(custom: CustomEnum)

        enum CustomEnum: String, StringRawRepresentable {
            case type = "TYPE"
        }
    }

    enum OldEvent: AnalyticsEvent {
        case eventWithParams(nameOfTheParam: String, valueOfTheParam: Double)
    }

    func test_NewAnalyticsEventReflection_simpleEventTitleAndParams() throws {
        let event: NewAnalyticsEvent = .simpleEventWithoutParams
        XCTAssertEqual(event.name, "Simple Event Without Params")
        XCTAssertEqual(event.params?.count, 1)
        XCTAssertEqual(event.params?["platform"] as? String, "WALLET")
    }

    func test_NewAnalyticsEventReflection_advancedEventTitleAndParams() throws {
        let event: NewAnalyticsEvent = .eventWithParams(nameOfTheParam: "The Name", valueOfTheParam: 3)
        XCTAssertEqual(event.name, "Event With Params")
        XCTAssertEqual(event.params?.count, 3)
        XCTAssertEqual(event.params?["platform"] as? String, "WALLET")
        XCTAssertEqual(event.params?["name_of_the_param"] as? String, "The Name")
        XCTAssertEqual(event.params?["value_of_the_param"] as? Double, 3)
    }

    func test_NewAnalyticsEventReflection_advancedEventCustomEnum() throws {
        let event: NewAnalyticsEvent = .eventWithCustom(custom: .type)
        XCTAssertEqual(event.name, "Event With Custom")
        XCTAssertEqual(event.params?.count, 2)
        XCTAssertEqual(event.params?["platform"] as? String, "WALLET")
        XCTAssertEqual(event.params?["custom"] as? String, "TYPE")
    }

    func test_OldAnalyticsEventReflection_advancedEventReflectedTitleAndParams() throws {
        let event: OldEvent = .eventWithParams(nameOfTheParam: "The Name", valueOfTheParam: 3)
        XCTAssertEqual(event.name, "Event With Params")
        XCTAssertNil(event.params)
    }
}
