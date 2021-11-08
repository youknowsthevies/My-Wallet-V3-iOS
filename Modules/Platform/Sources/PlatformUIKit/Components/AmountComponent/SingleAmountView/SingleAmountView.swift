// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import ToolKit
import UIComponentsKit
import UIKit

public final class SingleAmountView: UIView, AmountViewable {

    public var view: UIView {
        self
    }

    // MARK: - Properties

    private let fiatAmountLabelView = AmountLabelView()
    private let labeledButtonView = LabeledButtonView<CurrencyLabeledButtonViewModel>()

    private let presenter: SingleAmountPresenter

    public init(presenter: SingleAmountPresenter) {
        self.presenter = presenter
        super.init(frame: UIScreen.main.bounds)

        fiatAmountLabelView.presenter = presenter.amountPresenter.presenter

        setupUI()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init from coder isn't supported")
    }

    private func setupUI() {
        addSubview(fiatAmountLabelView)
        addSubview(labeledButtonView)

        fiatAmountLabelView.layoutToSuperview(.centerX)
        fiatAmountLabelView.layout(dimension: .height, to: 48)
        fiatAmountLabelView.layoutToSuperview(.leading, relation: .greaterThanOrEqual, offset: Spacing.outer)
        fiatAmountLabelView.layoutToSuperview(.trailing, relation: .lessThanOrEqual, offset: -Spacing.outer)
        fiatAmountLabelView.layoutToSuperview(.centerY)

        labeledButtonView.layout(edge: .top, to: .bottom, of: fiatAmountLabelView, offset: Spacing.standard)
        labeledButtonView.layout(to: .centerY, of: fiatAmountLabelView, priority: .penultimateLow)
        labeledButtonView.layoutToSuperview(.centerX)
    }

    public func connect(input: Driver<AmountPresenterInput>) -> Driver<AmountPresenterState> {
        Driver.combineLatest(
            presenter.connect(input: input),
            presenter.auxiliaryButtonEnabled
        )
        .map { (state: $0.0, auxiliaryEnabled: $0.1) }
        .map { [weak self] state, auxiliaryEnabled in
            guard let self = self else { return .empty }
            return self.performEffect(state: state, auxiliaryEnabled: auxiliaryEnabled)
        }
    }

    private func performEffect(state: AmountPresenterState, auxiliaryEnabled: Bool) -> AmountPresenterState {
        let limitButtonVisibility: Visibility
        let textColor: UIColor
        switch state {
        case .showLimitButton(let viewModel):
            labeledButtonView.viewModel = viewModel
            limitButtonVisibility = auxiliaryEnabled ? .visible : .hidden
            textColor = auxiliaryEnabled ? .validInput : .invalidInput
        case .empty:
            limitButtonVisibility = .hidden
            textColor = .validInput
        case .warning,
             .showSecondaryAmountLabel:
            unimplemented()
        }
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.labeledButtonView.alpha = limitButtonVisibility.defaultAlpha
                self.fiatAmountLabelView.textColor = textColor
            },
            completion: nil
        )
        return state
    }
}
