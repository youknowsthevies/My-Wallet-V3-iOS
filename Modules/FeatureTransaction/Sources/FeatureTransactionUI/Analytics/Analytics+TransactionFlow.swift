import AnalyticsKit
import PlatformKit

extension AnalyticsEvents.New {

    public enum TransactionFlow: AnalyticsEvent {

        public var type: AnalyticsEventType {
            .nabu
        }

        public enum FlowStep: String, StringRawRepresentable {
            case buy = "BUY"
            case swap = "SWAP"

            // swiftlint:disable:next cyclomatic_complexity
            init?(_ action: AssetAction) {
                switch action {
                case .buy:
                    self = .buy
                case .deposit:
                    return nil
                case .interestTransfer:
                    return nil
                case .interestWithdraw:
                    return nil
                case .receive:
                    return nil
                case .sell:
                    return nil
                case .send:
                    return nil
                case .sign:
                    return nil
                case .swap:
                    self = .swap
                case .viewActivity:
                    return nil
                case .linkToDebitCard:
                    return nil
                case .withdraw:
                    return nil
                }
            }
        }

        // Get more access prompt
        case getMoreAccessWhenYouVerifyClicked(flowStep: FlowStep)
        case getMoreAccessWhenYouVerifyDismissed(flowStep: FlowStep)
    }
}
