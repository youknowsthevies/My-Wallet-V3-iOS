// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

public struct PrimaryForm: View {

    @Binding private var questions: [FormQuestion]
    private let submitActionTitle: String
    private let submitActionLoading: Bool
    private let submitAction: () -> Void

    public init(
        questions: Binding<[FormQuestion]>,
        submitActionTitle: String,
        submitActionLoading: Bool,
        submitAction: @escaping () -> Void
    ) {
        _questions = questions
        self.submitActionTitle = submitActionTitle
        self.submitActionLoading = submitActionLoading
        self.submitAction = submitAction
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.padding4) {
                ForEach($questions) { question in
                    FormQuestionView(question: question)
                }

                PrimaryButton(
                    title: submitActionTitle,
                    isLoading: submitActionLoading,
                    action: submitAction
                )
                .disabled(!questions.isValidForm)
            }
            .padding(Spacing.padding3)
            .background(Color.semantic.background)
        }
    }
}

struct PrimaryForm_Previews: PreviewProvider {

    struct FormRawData: Codable {
        let nodes: [FormQuestion]
    }

    static var previews: some View {
        let jsonData = formPreviewJSON.data(using: .utf8)!
        // swiftlint:disable:next force_try
        let formRawData = try! JSONDecoder().decode(FormRawData.self, from: jsonData)
        PreviewHelper(questions: formRawData.nodes)
    }

    struct PreviewHelper: View {

        @State var questions: [FormQuestion]

        var body: some View {
            PrimaryForm(
                questions: $questions,
                submitActionTitle: "Next",
                submitActionLoading: false,
                submitAction: {}
            )
        }
    }
}
