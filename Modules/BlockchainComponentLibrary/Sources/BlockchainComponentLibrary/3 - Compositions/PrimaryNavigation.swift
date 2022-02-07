// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Public

extension View {

    /// Replacement for setting navigation items using component library styling.
    /// - Parameters:
    ///   - icon: Optional leading icon displayed in the navigation bar
    ///   - title: Optional title displayed in the navigation bar
    ///   - byline: Optional byline displayed under the title
    ///   - trailing: Trailing views in navigation bar. Commonly `IconButton`, or `TextButton`.
    ///               Multiple views are auto distributed along an HStack.
    /// - Returns: `self`, otherwise unmodified.
    public func primaryNavigation<LeadingIcon: View, Trailing: View>(
        @ViewBuilder icon: @escaping () -> LeadingIcon,
        title: String? = nil,
        isLargeTitle: Bool = false,
        byline: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) -> some View {
        modifier(
            PrimaryNavigationModifier(
                icon: icon,
                title: title,
                isLargeTitle: isLargeTitle,
                byline: byline,
                trailing: trailing
            )
        )
    }

    /// Replacement for setting navigation items using component library styling.
    /// - Parameters:
    ///   - icon: Optional leading icon displayed in the navigation bar
    ///   - title: Optional title displayed in the navigation bar
    ///   - byline: Optional byline displayed under the title
    ///   - trailing: Trailing views in navigation bar. Commonly `IconButton`, or `TextButton`.
    ///               Multiple views are auto distributed along an HStack.
    /// - Returns: `self`, otherwise unmodified.
    public func primaryNavigation<Trailing: View>(
        title: String? = nil,
        isLargeTitle: Bool = false,
        byline: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) -> some View {
        modifier(
            PrimaryNavigationModifier(
                icon: EmptyView.init,
                title: title,
                isLargeTitle: isLargeTitle,
                byline: byline,
                trailing: trailing
            )
        )
    }

    /// Replacement for setting navigation items using component library styling.
    ///
    /// This function is specifically available for setting the title without changing trailing views.
    ///
    /// - Parameters:
    ///   - icon: Optional leading icon displayed in the navigation bar
    ///   - title: Optional title displayed in the navigation bar
    ///   - byline: Optional byline displayed under the title
    /// - Returns: `self`, otherwise unmodified.
    public func primaryNavigation<LeadingIcon: View>(
        @ViewBuilder icon: @escaping () -> LeadingIcon,
        title: String? = nil,
        isLargeTitle: Bool = false,
        byline: String? = nil
    ) -> some View {
        modifier(
            PrimaryNavigationModifier<LeadingIcon, EmptyView>(
                icon: icon,
                title: title,
                isLargeTitle: isLargeTitle,
                byline: byline,
                trailing: nil
            )
        )
    }

    /// Replacement for setting navigation items using component library styling.
    ///
    /// This function is specifically available for setting the title without changing trailing views.
    ///
    /// - Parameters:
    ///   - icon: Optional leading icon displayed in the navigation bar
    ///   - title: Optional title displayed in the navigation bar
    ///   - byline: Optional byline displayed under the title
    /// - Returns: `self`, otherwise unmodified.
    public func primaryNavigation(
        title: String? = nil,
        isLargeTitle: Bool = false,
        byline: String? = nil
    ) -> some View {
        modifier(
            PrimaryNavigationModifier<EmptyView, EmptyView>(
                icon: EmptyView.init,
                title: title,
                isLargeTitle: isLargeTitle,
                byline: byline,
                trailing: nil
            )
        )
    }
}

/// Replacement for `NavigationView` to fix a bug on iPhone
public struct PrimaryNavigationView<Content: View>: View {
    @ViewBuilder private let content: () -> Content

    /// A `NavigationView` with a custom designed navigation bar
    /// - Parameters:
    ///   - content: Content of navigation view. Use `.primaryNavigation(...)` for titles and trailing items, and `PrimaryNavigationLink` for links.
    public init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        #if os(macOS)
        NavigationView(content: content)
        #else
        NavigationView(content: content)
            // StackNavigationViewStyle is to fix a bug on iPhone where the following
            // console error appears, and the navigation bar goes blank.
            //
            // > [Assert] displayModeButtonItem is internally managed and not exposed for DoubleColumn style. Returning an empty, disconnected UIBarButtonItem to fulfill the non-null contract.
            //
            // If we add iPad layout, we can re-enable other styles conditionally.
            .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

/// Replacement for `NavigationLink` which provides some private functionality for detecting
/// being a pushed view in the destination.
public struct PrimaryNavigationLink<Destination: View, Label: View>: View {
    let destination: Destination
    let isActive: Binding<Bool>?
    @ViewBuilder let label: () -> Label

    public init(
        destination: Destination,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.destination = destination
        self.isActive = isActive
        self.label = label
    }

    private var secondaryDestination: some View {
        destination.environment(\.isSecondaryViewInNavigation, true)
    }

    public var body: some View {
        if let isActive = isActive {
            NavigationLink(
                destination: secondaryDestination,
                isActive: isActive,
                label: label
            )
        } else {
            NavigationLink(
                destination: secondaryDestination,
                label: label
            )
        }
    }
}

extension EnvironmentValues {

    /// Accent color for navigation bar back button in `PrimaryNavigation`
    ///
    /// Defaults to `.semantic.primary` (Wallet)
    public var navigationBackButtonColor: Color {
        get { self[NavigationBackButtonColor.self] }
        set { self[NavigationBackButtonColor.self] = newValue }
    }
}

// MARK: - Private

/// Modifier which applies custom navigation bar styling
private struct PrimaryNavigationModifier<LeadingIcon: View, Trailing: View>: ViewModifier {
    let icon: () -> LeadingIcon
    let title: String?
    let isLargeTitle: Bool
    let byline: String?
    let trailing: (() -> Trailing)?

    // Custom variable required for this because `presentationMode.wrappedValue.isPresented`
    // is set AFTER the push animation occurs, causing an unsatisfactory transition between
    // navigation items.
    @Environment(\.isSecondaryViewInNavigation) var isSecondaryViewInNavigation
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        content
            .if(true) {
                #if canImport(UIKit)
                $0
                    .navigationBarTitleDisplayMode(.inline)
                    .background(NavigationConfigurator())
                #else
                $0
                #endif
            }
            .ifLet(title) { view, title in
                view
                    .navigationTitle(title)
                    .if(true) {
                        #if os(macOS)
                        $0
                        #else
                        $0.toolbar {
                            ToolbarItem(placement: isSecondaryViewInNavigation ? .principal : .navigationBarLeading) {
                                HStack(spacing: 8) {
                                    icon()
                                        .frame(width: 24, height: 24)

                                    VStack(alignment: isSecondaryViewInNavigation ? .center : .leading, spacing: 0) {
                                        Text(title)
                                            .typography(titleTypography)
                                            .foregroundColor(.semantic.title)

                                        byline.map(Text.init)?
                                            .typography(isSecondaryViewInNavigation ? .caption1 : .paragraph2)
                                            .foregroundColor(
                                                Color(light: .palette.grey600, dark: .palette.dark200)
                                            )
                                    }
                                }
                                .padding(.leading, Spacing.padding1)
                            }
                        }
                        #endif
                    }
            }
            .ifLet(trailing) { view, trailing in
                #if os(macOS)
                view
                    .toolbar {
                        ToolbarItem {
                            trailing()
                        }
                    }
                #else
                view
                    .navigationBarItems(
                        trailing: HStack(spacing: Spacing.padding3) {
                            trailing()
                        }
                        .padding(.trailing, Spacing.padding1)
                        .accentColor(.semantic.muted)
                    )
                #endif
            }
    }

    private var titleTypography: Typography {
        switch (byline, isSecondaryViewInNavigation) {
        case (.none, false):
            return isLargeTitle ? .title2 : .title3 // First view, no byline
        case (.none, true):
            return .title3 // Back button visible, no byline
        case (.some, _):
            return .body2 // with byline in any view
        }
    }
}

/// Environment key set by `PrimaryNavigationLink`
private struct IsSecondaryViewInNavigation: EnvironmentKey {
    static var defaultValue = false
}

/// Environment key set by `PrimaryNavigation`
private struct NavigationBackButtonColor: EnvironmentKey {
    static var defaultValue = Color.semantic.primary
}

extension EnvironmentValues {
    fileprivate var isSecondaryViewInNavigation: Bool {
        get { self[IsSecondaryViewInNavigation.self] }
        set { self[IsSecondaryViewInNavigation.self] = newValue }
    }
}

#if canImport(UIKit)
/// Customizing `UINavigationController` without using `UIAppearance`
private struct NavigationConfigurator: UIViewControllerRepresentable {
    @Environment(\.navigationBackButtonColor) var navigationBackButtonColor

    func makeUIViewController(context: Context) -> NavigationConfiguratorViewController {
        let controller = NavigationConfiguratorViewController(navigationBackButtonColor: navigationBackButtonColor)
        return controller
    }

    func updateUIViewController(_ uiViewController: NavigationConfiguratorViewController, context: Context) {
        uiViewController.navigationBackButtonColor = navigationBackButtonColor
    }

    final class NavigationConfiguratorViewController: UIViewController {
        var navigationBackButtonColor: Color {
            didSet {
                styleNavigationBar()
            }
        }

        init(navigationBackButtonColor: Color) {
            self.navigationBackButtonColor = navigationBackButtonColor
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // Must wait until the view controller is added to the hierarchy to customize the navigation bar.
        // Otherwise `navigationController?` is nil.
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)

            // Parent being the content hosting controller
            if let navigationItem = parent?.navigationItem {
                // Hide the back button title
                navigationItem.backButtonDisplayMode = .minimal

                // If we're the root view, hide the title view since we have a custom one.
                // If we do this for every view it screws up the animation when pushing
                if navigationController?.children.first == parent {
                    navigationItem.titleView = UIView()
                }
            }

            styleNavigationBar()
        }

        // Customize the styling of the navigation bar
        private func styleNavigationBar() {
            if let navigationBar = navigationController?.navigationBar {
                navigationBar.tintColor = UIColor(
                    Color(
                        light: .palette.grey400,
                        dark: .palette.grey400
                    )
                )
                navigationBar.barTintColor = UIColor(.semantic.background)
                navigationBar.shadowImage = UIImage()

                let image = Icon.chevronLeft.uiImage?
                    .padded(by: UIEdgeInsets(top: 0, left: Spacing.padding1, bottom: 0, right: 0))

                navigationBar.backIndicatorImage = image
                navigationBar.backIndicatorTransitionMaskImage = image
                navigationBar.tintColor = UIColor(navigationBackButtonColor)

                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}
#endif

// MARK: - Previews

struct PrimaryNavigation_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer()
            .previewDisplayName("Wallet")

        PreviewContainer()
            .environment(\.navigationBackButtonColor, Color(light: .palette.dark400, dark: .palette.white))
            .previewDisplayName("Exchange")
    }

    struct PreviewContainer: View {
        @State var isActive: Bool = false

        var body: some View {
            PrimaryNavigationView {
                primary
            }
        }

        @ViewBuilder var primary: some View {
            PrimaryNavigationLink(
                destination: secondary,
                isActive: $isActive,
                label: { Text("Foo") }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green)
            .primaryNavigation(
                icon: { Icon.placeholder },
                title: "Foo",
                byline: "Byline",
                trailing: {
                    IconButton(icon: .qrCode) {}

                    IconButton(icon: .user) {}
                }
            )
        }

        @ViewBuilder var secondary: some View {
            ScrollView {
                LazyVStack {
                    ForEach(0..<100, id: \.self) { value in
                        Text("\(value)")
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                    }
                }
            }
            .primaryNavigation(title: "Bar", byline: "Byline") {
                IconButton(icon: .chat) {}
            }
        }
    }
}
