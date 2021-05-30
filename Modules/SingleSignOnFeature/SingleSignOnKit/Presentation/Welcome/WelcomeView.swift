// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

typealias WelcomeViewString = LocalizationConstants.Onboarding.WelcomeScreen

struct WelcomeView: View {
    var body: some View {
        VStack {
            WelcomeMessageSection()
                .padding(EdgeInsets(top: 173, leading: 0, bottom: 0, trailing: 0))
            Spacer()
            WelcomeActionSection()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 58, trailing: 0))
        }
    }
}

struct WelcomeMessageSection: View {
    var body: some View {
        VStack {
            Image("logo_large")
                .frame(width: 64, height: 64)
                .padding(40)
            Text(WelcomeViewString.title)
                .font(.custom("Inter-SemiBold", size: 24))
                .foregroundColor(.textHeading)
                .padding(16)
            WelcomeMessageDescription()
                .font(.custom("Inter-Medium", size: 16))
                .lineSpacing(4)
        }
        .multilineTextAlignment(.center)
    }
}

struct WelcomeMessageDescription: View {
    let prefix = Text(WelcomeViewString.Description.prefix)
        .foregroundColor(.textMuted)
    let comma = Text(WelcomeViewString.Description.comma)
        .foregroundColor(.textMuted)
    let receive = Text(WelcomeViewString.Description.receive)
        .foregroundColor(.textHeading)
    let store = Text(WelcomeViewString.Description.store + "\n")
        .foregroundColor(.textHeading)
    let and = Text(WelcomeViewString.Description.and)
        .foregroundColor(.textMuted)
    let trade = Text(WelcomeViewString.Description.trade)
        .foregroundColor(.textHeading)
    let suffix = Text(WelcomeViewString.Description.suffix)
        .foregroundColor(.textMuted)

    var body: some View {
        Group {
            prefix + receive + comma + store + and + trade + suffix
        }
    }
}

struct WelcomeActionSection: View {
    var body: some View {
        VStack {
            PrimaryButton(title: WelcomeViewString.Button.createWallet) {
                // Add Action here
            }
                .frame(width: 327, height: 48)
                .border(Color.black)
                .cornerRadius(8.0)
                .padding(10)
            SecondaryButton(title: WelcomeViewString.Button.login) {
                // Add Action here
            }
                .frame(width: 327, height: 48)
            HStack {
                Button(WelcomeViewString.Button.recoverFunds) {
                    // Add Action here
                }
                    .font(.custom("Inter-SemiBold", size: 12))
                Spacer()
                Text("Test Version")
                    .font(.custom("Inter-Medium", size: 12))
            }
            .padding()
            .frame(width: 327, height: 28)
        }
    }
}

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
#endif
