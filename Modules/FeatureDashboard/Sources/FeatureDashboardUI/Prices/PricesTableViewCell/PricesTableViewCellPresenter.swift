// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class PricesTableViewCellPresenter {
    let imageViewModel: ImageViewContent
    let titleLabelContent: LabelContent
    var subtitleLabelContent: Driver<NSAttributedString?> {
        subtitleRelay.asDriver()
    }

    private let subtitleRelay = BehaviorRelay<NSAttributedString?>(value: nil)
    private let interactor: AssetPriceViewInteracting
    private let disposeBag: DisposeBag = .init()

    init(
        cryptoCurrency: CryptoCurrency,
        interactor: AssetPriceViewInteracting
    ) {
        imageViewModel = ImageViewContent(
            imageResource: cryptoCurrency.logoResource,
            accessibility: .none,
            renderingMode: .normal
        )
        titleLabelContent = .init(text: cryptoCurrency.name, font: .main(.semibold, 16), color: .titleText)
        self.interactor = interactor
        interactor
            .state
            .map { state -> NSAttributedString? in
                switch state {
                case .loading:
                    return nil
                case .loaded(next: let value):
                    let fiatPrice = NSAttributedString(
                        LabelContent(
                            text: value.fiatValue.toDisplayString(includeSymbol: true) + " ",
                            font: .main(.medium, 14),
                            color: .darkTitleText
                        )
                    )

                    var deltaTintColor: UIColor = .mutedText
                    if value.changePercentage > 0 {
                        deltaTintColor = .positivePrice
                    } else if value.changePercentage < 0 {
                        deltaTintColor = .negativePrice
                    }

                    let percentageChange: NSAttributedString
                    let percentage = value.changePercentage * 100
                    let percentageString = percentage.string(with: 2)
                    percentageChange = NSAttributedString(
                        LabelContent(
                            text: "\(percentageString)%",
                            font: .main(.medium, 14),
                            color: deltaTintColor
                        )
                    )
                    return fiatPrice + percentageChange
                }
            }
            .bind(to: subtitleRelay)
            .disposed(by: disposeBag)
    }
}
