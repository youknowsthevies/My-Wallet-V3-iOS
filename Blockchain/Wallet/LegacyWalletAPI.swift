// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import ToolKit

final class OrderTransactionLegacy: NSObject {
    @objc let legacyAssetType: LegacyAssetType
    @objc let from: Int32
    @objc let to: String
    @objc let amount: String
    @objc var fees: String?

    init(
        legacyAssetType: LegacyAssetType,
        from: Int32,
        to: String,
        amount: String,
        fees: String?
    ) {
        self.legacyAssetType = legacyAssetType
        self.from = from
        self.to = to
        self.amount = amount
        self.fees = fees
        super.init()
    }
}

protocol LegacyWalletAPI: AnyObject {

    func updateAccountLabel(
        _ cryptoCurrency: CryptoCurrency,
        index: Int,
        label: String
    ) -> Completable

    /// Call this method to build an Bitcoin or Bitcoin Cash payment object.
    /// It constructs and stores a payment object with a given CryptoCurrency, to, from, and amount (properties of OrderTransactionLegacy).
    /// To send the order, call `sendOrderTransaction:completion:`.
    ///
    /// - Parameters:
    ///   - orderTransaction: the `OrderTransactionLegacy` describing the payment.
    ///   - completion: Result with built payment data or error.
    func createOrderPayment(
        orderTransaction: OrderTransactionLegacy,
        completion: @escaping (Result<[AnyHashable : Any], Wallet.CreateOrderError>) -> Void
    )

    /// Sign and publish a transaction that was built by `createOrderPayment:withOrderTransaction:completion`.
    /// This is the last step in sending an Bitcoin or Bitcoin Cash payment.
    ///
    /// - Parameters:
    ///   - legacyAssetType: used to determine the type of payment to use.
    ///   - completion: Result with sent payment transaction hash or error.
    func sendOrderTransaction(
        _ legacyAssetType: LegacyAssetType,
        secondPassword: String?,
        completion: @escaping (Result<String, Wallet.SendOrderError>) -> Void
    )
    
    func needsSecondPassword() -> Bool
    
    func getReceiveAddress(forAccount account: Int32,
                           assetType: LegacyAssetType) -> String!
}

extension Wallet: LegacyWalletAPI {

    enum SendOrderError: Error {
        case sendOrderFailed(String)
        case cancelled
    }
    enum CreateOrderError: Error {
        case createOrderFailed([AnyHashable : Any])
    }

    func createOrderPayment(
        orderTransaction: OrderTransactionLegacy,
        completion: @escaping (Result<[AnyHashable : Any], CreateOrderError>) -> Void
    ) {
        let amount = NumberFormatter.parseBitcoinValue(from: orderTransaction.amount)
        let fees = NumberFormatter.parseBitcoinValue(from: orderTransaction.fees)
        let formattedAmount = String(format: "%lld", amount)
        let formattedFee = String(format: "%lld", fees)
        let tradeExecutionType: String
        switch orderTransaction.legacyAssetType {
        case .bitcoin:
            tradeExecutionType = "bitcoin"
        case .bitcoinCash:
            tradeExecutionType = "bitcoinCash"
        default:
            unimplemented()
        }
        context.invokeOnce(
            valueFunctionBlock: { jsValue in
                var result: [AnyHashable : Any] = [:]
                if
                    let stringValue = jsValue.toString(),
                    let data = stringValue.data(using: .utf8),
                    let decoded = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
                {
                    result = decoded
                }
                Logger.shared.debug("TradeExecution: on_create_order_payment_success: \(result)")
                completion(.success(result))
            },
            forJsFunctionName: "objc_on_create_order_payment_success" as NSString
        )
        context.invokeOnce(
            valueFunctionBlock: { jsValue in
                var result: [AnyHashable : Any] = [:]
                if
                    let stringValue = jsValue.toString(),
                    let data = stringValue.data(using: .utf8),
                    let decoded = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
                {
                    result = decoded
                }
                Logger.shared.debug("TradeExecution: on_create_order_payment_error: \(result)")
                completion(.failure(.createOrderFailed(result)))
            },
            forJsFunctionName: "objc_on_create_order_payment_error" as NSString
        )
        // swiftlint:disable line_length
        let script = "MyWalletPhone.tradeExecution.\(tradeExecutionType).createPayment(\(orderTransaction.from), \"\(orderTransaction.to.escapedForJS())\", \(formattedAmount.escapedForJS()), \(formattedFee.escapedForJS()))"
        _ = context.evaluateScriptCheckIsOnMainQueue(script)
    }

    func sendOrderTransaction(
        _ legacyAssetType: LegacyAssetType,
        secondPassword: String?,
        completion: @escaping (Result<String, SendOrderError>) -> Void
    ) {
        let tradeExecutionType: String
        switch legacyAssetType {
        case .bitcoin:
            tradeExecutionType = "bitcoin"
        case .bitcoinCash:
            tradeExecutionType = "bitcoinCash"
        default:
            unimplemented()
        }
        context.invokeOnce(
            valueFunctionBlock: { jsValue in
                let transactionHash = jsValue.toString() ?? ""
                Logger.shared.debug("TradeExecution: on_send_order_transaction_success: \(transactionHash)")
                completion(.success(transactionHash))
            },
            forJsFunctionName: "objc_on_send_order_transaction_success" as NSString
        )
        context.invokeOnce(
            valueFunctionBlock: { jsValue in
                let errorMessage = jsValue.toString() ?? ""
                Logger.shared.debug("TradeExecution: on_send_order_transaction_error: \(errorMessage)")
                completion(.failure(.sendOrderFailed(errorMessage)))
            },
            forJsFunctionName: "objc_on_send_order_transaction_error" as NSString
        )
        context.invokeOnce(
            functionBlock: {
                completion(.failure(.cancelled))
                Logger.shared.debug("TradeExecution: on_send_order_transaction_dismiss")
            },
            forJsFunctionName: "objc_on_send_order_transaction_dismiss" as NSString
        )
        let secondPassword = secondPassword?.escapedForJS() ?? ""
        let script = "MyWalletPhone.tradeExecution.\(tradeExecutionType).send(\"\(secondPassword)\")"
        _ = context.evaluateScriptCheckIsOnMainQueue(script)
    }
}

