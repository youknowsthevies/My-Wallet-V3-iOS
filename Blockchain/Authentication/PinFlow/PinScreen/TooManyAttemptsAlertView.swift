// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import SwiftUI
import UIComponentsKit
import UIKit

class TooManyAttemptsAlertViewController: UIViewController {

    private let contentView = UIHostingController(rootView: TooManyAttemptsAlertView())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentView.view)
        addChild(contentView)
        setupConstraints()
        contentView.rootView.okPressed = {
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.heightAnchor.constraint(equalToConstant: 280).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

private struct TooManyAttemptsAlertView: View {
    var okPressed: (() -> Void)?

    var body: some View {
        VStack {
            Text(LocalizationConstants.Pin.tooManyAttemptsTitle)
                .textStyle(.title)
                .padding(.bottom, 10)
            Text(LocalizationConstants.Pin.tooManyAttemptsWarningMessage)
            Spacer()
            PrimaryButton(title: LocalizationConstants.okString, action: {
                okPressed?()
            })
                .padding(.bottom, 5)
        }
        .padding(EdgeInsets(top: 34, leading: 24, bottom: 0, trailing: 24))
    }
}

private struct TooManyAttemptsAlertView_Previews: PreviewProvider {
    static var previews: some View {
        TooManyAttemptsAlertView()
    }
}
