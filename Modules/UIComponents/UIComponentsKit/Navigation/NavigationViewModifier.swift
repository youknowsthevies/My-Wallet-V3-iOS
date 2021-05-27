// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public enum NavigationButton {
    case back
    case close

    var iconName: String {
        switch self {
        case .back:
            return "back_chevron_icon"
        case .close:
            return "cancel_icon"
        }
    }
}

extension View {

    public func updateNavigationBarStyle() -> some View {
        configureNavigationBar {
            $0.navigationBar.barTintColor = .white
            $0.navigationBar.shadowImage = UIImage() // remove shadow
        }
    }

    public func leadingNavigationButton(_ button: NavigationButton, action: @escaping () -> Void) -> some View {
        navigationBarItems(
            leading: HStack {
                Button(action: action) {
                    Image(button.iconName, bundle: .current)
                }
            }
        )
    }

    public func trailingNavigationButton(_ button: NavigationButton, action: @escaping () -> Void) -> some View {
        navigationBarItems(
            trailing: HStack {
                Button(action: action) {
                    Image(button.iconName, bundle: .current)
                }
            }
        )
    }
}

// iOS 13 workaround to customize the background for NavigationView
// Source: https://stackoverflow.com/a/62785462
extension View {
    func configureNavigationBar(configure: @escaping (UINavigationController) -> Void) -> some View {
        modifier(NavigationConfigurationViewModifier(configure: configure))
    }
}

struct NavigationConfigurationViewModifier: ViewModifier {
    let configure: (UINavigationController) -> Void

    func body(content: Content) -> some View {
        content.background(NavigationConfigurator(configure: configure))
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    let configure: (UINavigationController) -> Void

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<NavigationConfigurator>
    ) -> NavigationConfigurationViewController {
        NavigationConfigurationViewController(configure: configure)
    }

    func updateUIViewController(
        _ uiViewController: NavigationConfigurationViewController,
        context: UIViewControllerRepresentableContext<NavigationConfigurator>
    ) { }
}

final class NavigationConfigurationViewController: UIViewController {
    let configure: (UINavigationController) -> Void

    init(configure: @escaping (UINavigationController) -> Void) {
        self.configure = configure
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let navigationController = navigationController {
            configure(navigationController)
        }
    }
}
