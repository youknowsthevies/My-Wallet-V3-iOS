// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import PlatformUIKit
import SwiftUI

struct CustomerSupportDepartmentSelector: View {

    private typealias LocalizationIds = LocalizationConstants.CustomerSupport

    private let selection: (CustomerSupportDepartment) -> Void

    init(selection: @escaping (CustomerSupportDepartment) -> Void) {
        self.selection = selection
    }

    var body: some View {
        NavigationView {
            List {
                VStack {
                    Spacer()
                    Text(LocalizationIds.Heading.title)
                        .font(Font(weight: .semibold, size: 20))
                    Spacer()
                }
                ForEach(CustomerSupportDepartment.allCases) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(item.title)
                                .font(Font(weight: .semibold, size: 16))
                                .foregroundColor(.textTitle)
                            Spacer()
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { [selection] in
                        selection(item)
                    }
                }
            }
            .navigationTitle(LocalizationIds.title)
            .whiteNavigationBarStyle()
        }
        .whiteNavigationBarStyle()
    }
}

struct CustomerSupportDepartmentSelector_Previews: PreviewProvider {
    static var previews: some View {
        CustomerSupportDepartmentSelector(selection: { _ in
            // NOOP
        })
    }
}
