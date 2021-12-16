// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms
import ComponentLibrary
import DIKit
import Examples
import SwiftUI
import ToolKit

public protocol NetworkDebugScreenProvider {
    var viewController: UIViewController { get }
}

struct DebugView: View {

    var window: UIWindow?

    @State var pulse: Bool = false
    @State var layoutDirection: LayoutDirection = .leftToRight

    var body: some View {
        PrimaryNavigationView {
            ScrollView {
                VStack {
                    PrimaryNavigationLink(
                        destination: FeatureFlags()
                            .primaryNavigation(title: "⛳️ Feature Flags")
                    ) {
                        PrimaryRow(title: "⛳️ Feature Flags")
                    }
                    PrimaryDivider()
                    PrimaryNavigationLink(
                        destination: Examples.RootView.content
                            .environment(\.layoutDirection, layoutDirection)
                            .primaryNavigation(title: "📚 Component Library") {
                                Button(layoutDirection == .leftToRight ? "➡️" : "⬅️") {
                                    layoutDirection = layoutDirection == .leftToRight ? .rightToLeft : .leftToRight
                                }
                            }
                    ) {
                        PrimaryRow(title: "📚 Component Library")
                    }
                    PrimaryDivider()
                    PrimaryRow(title: "🤖 Pulse")
                        .onTapGesture {
                            pulse = true
                        }
                }
                .background(Color.semantic.background)
            }
            .sheet(isPresented: $pulse) {
                Pulse()
                    .ignoresSafeArea()
                    .onDisappear {
                        pulse = false
                    }
            }
            .primaryNavigation(title: "Debug") {
                Button(window?.overrideUserInterfaceStyle == .dark ? "☀️" : "🌑") {
                    if let window = window {
                        switch window.overrideUserInterfaceStyle {
                        case .dark:
                            window.overrideUserInterfaceStyle = .light
                        default:
                            window.overrideUserInterfaceStyle = .dark
                        }
                    }
                }
            }
        }
    }
}

extension DebugView {

    struct FeatureFlags: View {

        var internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve()
        var remoteFeatureFlagsService: FeatureFetching = resolve()

        @State var data: [AppFeature: JSON] = [:]

        var body: some View {
            List {
                local
                remote
            }
            .listRowInsets(
                EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            )
            .background(Color.semantic.background)
        }

        let pasteboard = UIPasteboard.general

        @ViewBuilder var local: some View {
            Section(header: Text("Internal")) {
                ForEach(InternalFeature.allCases, id: \.self) { feature in
                    PrimaryRow(
                        title: feature.displayTitle,
                        subtitle: feature.rawValue,
                        trailing: {
                            PrimarySwitch(
                                accessibilityLabel: feature.displayTitle,
                                isOn: Binding(
                                    get: { internalFeatureFlagService.isEnabled(feature) },
                                    set: { newValue in
                                        if newValue {
                                            internalFeatureFlagService.enable(feature)
                                        } else {
                                            internalFeatureFlagService.disable(feature)
                                        }
                                    }
                                )
                            )
                        }
                    )
                    .contextMenu {
                        Button(
                            action: { pasteboard.string = feature.rawValue },
                            label: {
                                Label("Copy Name", systemImage: "doc.on.doc.fill")
                            }
                        )
                    }
                }
            }
        }

        @ViewBuilder var remote: some View {
            Section(header: Text("Remote")) {
                ForEach(AppFeature.allCases, id: \.self) { feature in
                    if let name = feature.remoteEnabledKey {
                        if let value = data[feature] {
                            PrimaryRow(
                                title: name,
                                subtitle: value.description,
                                trailing: EmptyView.init
                            )
                            .contextMenu {
                                Button(
                                    action: { pasteboard.string = name },
                                    label: {
                                        Label("Copy Name", systemImage: "doc.on.doc.fill")
                                    }
                                )
                                Button(
                                    action: { pasteboard.string = value.description },
                                    label: {
                                        Label("Copy JSON", systemImage: "doc.on.doc.fill")
                                    }
                                )
                            }
                        } else {
                            PrimaryRow(
                                title: name,
                                trailing: { ProgressView() }
                            )
                            .onReceive(
                                remoteFeatureFlagsService
                                    .fetch(for: feature, as: JSON.self)
                                    .replaceError(with: .null)
                            ) { json in
                                data[feature] = json
                            }
                        }
                    }
                }
            }
        }
    }

    struct Pulse: UIViewControllerRepresentable {

        @Inject var networkDebugScreenProvider: NetworkDebugScreenProvider

        func makeUIViewController(context: Context) -> some UIViewController {
            networkDebugScreenProvider.viewController
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    }
}

enum JSON: Codable, Equatable, CustomStringConvertible {

    case null
    case boolean(Bool)
    case string(String)
    case number(NSNumber)
    case array([JSON])
    case object([String: JSON])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let boolean = try? container.decode(Bool.self) {
            self = .boolean(boolean)
        } else if let int = try? container.decode(Int.self) {
            self = .number(NSNumber(value: int))
        } else if let double = try? container.decode(Double.self) {
            self = .number(NSNumber(value: double))
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSON].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSON].self) {
            self = .object(object)
        } else {
            throw DecodingError.typeMismatch(
                JSON.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected to decode JSON value"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .boolean(let bool):
            try container.encode(bool)
        case .number(let number):
            switch CFNumberGetType(number) {
            case .intType, .nsIntegerType, .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type:
                try container.encode(number.intValue)
            default:
                try container.encode(number.doubleValue)
            }
        case .string(let string):
            try container.encode(string)
        case .array(let array):
            try container.encode(array)
        case .object(let object):
            try container.encode(object)
        }
    }

    var pretty: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        do {
            return String(decoding: try encoder.encode(self), as: UTF8.self)
        } catch {
            return "<invalid json>"
        }
    }

    var description: String { pretty }
}
