import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
/// A TextField that is backed by UIKit that allows us to get/set its first responder state
struct FocusableTextField: UIViewRepresentable {

    @Binding private var isFirstResponder: Bool
    @Binding private var text: String

    private var configuration = { (_: UITextField) in }
    private var onReturnTapped = {}
    private var characterLimit: Int?

    init(
        text: Binding<String>,
        isFirstResponder: Binding<Bool>,
        characterLimit: Int? = nil,
        configuration: @escaping (UITextField) -> Void = { _ in },
        onReturnTapped: @escaping () -> Void = {}
    ) {
        self.configuration = configuration
        _text = text
        _isFirstResponder = isFirstResponder
        self.characterLimit = characterLimit
        self.onReturnTapped = onReturnTapped
    }

    func makeUIView(context: Context) -> UITextField {
        let view = UITextField()
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        configuration(uiView)
        DispatchQueue.main.async { [isFirstResponder] in
            switch isFirstResponder {
            case true:
                uiView.becomeFirstResponder()
            case false:
                uiView.resignFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            $text,
            isFirstResponder: $isFirstResponder,
            characterLimit: characterLimit,
            onReturnTapped: onReturnTapped
        )
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var isFirstResponder: Binding<Bool>
        var onReturnTapped: () -> Void
        var characterLimit: Int?

        init(
            _ text: Binding<String>,
            isFirstResponder: Binding<Bool>,
            characterLimit: Int? = nil,
            onReturnTapped: @escaping () -> Void
        ) {
            self.text = text
            self.isFirstResponder = isFirstResponder
            self.onReturnTapped = onReturnTapped
            self.characterLimit = characterLimit
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let characterLimit = characterLimit else {
                return true
            }

            let currentText = textField.text ?? ""

            // attempt to read the range they are trying to change, or exit if we can't
            guard let stringRange = Range(range, in: currentText) else { return false }

            // add their new text to the existing text
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            // make sure the result is under 16 characters
            return updatedText.count <= characterLimit
        }

        @objc func textViewDidChange(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            // Dispatching is necessary otherwise the view doesn't update properly
            DispatchQueue.main.async {
                self.isFirstResponder.wrappedValue = true
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            // Dispatching is necessary otherwise the view doesn't update properly
            DispatchQueue.main.async {
                self.isFirstResponder.wrappedValue = false
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Dispatching is necessary otherwise the view doesn't update properly
            DispatchQueue.main.async(execute: onReturnTapped)
            return true
        }
    }
}

struct FocusableTextField_Previews: PreviewProvider {
    static var previews: some View {
        FocusableTextField(
            text: .constant("test@example.com"),
            isFirstResponder: .constant(false)
        )
        .padding()
    }
}
#endif
