import Combine
import Foundation
import StoreKit

@MainActor
final class PulseNovaStoreKitCenter: NSObject, ObservableObject {
    struct PulseNovaRechargeProduct: Identifiable, Hashable {
        let id: String
        let pulseNovaCoins: Int
        let pulseNovaFallbackPriceText: String

        var pulseNovaProductIdentifier: String {
            id
        }
    }

    enum PulseNovaPurchaseState: Equatable {
        case idle
        case loadingProducts
        case purchasing(productID: String)
    }

    struct PulseNovaPurchaseResult: Equatable {
        enum PulseNovaResultStyle: Equatable {
            case success
            case error
        }

        let pulseNovaMessage: String
        let pulseNovaStyle: PulseNovaResultStyle
    }

    static let shared = PulseNovaStoreKitCenter()

    @Published private(set) var pulseNovaProducts: [String: SKProduct] = [:]
    @Published private(set) var pulseNovaPurchaseState: PulseNovaPurchaseState = .idle
    @Published private(set) var pulseNovaPurchaseResult: PulseNovaPurchaseResult?

    let pulseNovaRechargeProducts: [PulseNovaRechargeProduct] = [
        .init(
            id: "qrtwlrrvgrszwwnb",
            pulseNovaCoins: 400,
            pulseNovaFallbackPriceText: "$0.99"
        ),
        .init(
            id: "qyjbudpdomvfvlby",
            pulseNovaCoins: 800,
            pulseNovaFallbackPriceText: "$1.99"
        ),
        .init(
            id: "qjvntkzplmraxsde",
            pulseNovaCoins: 2190,
            pulseNovaFallbackPriceText: "$3.99"
        ),
        .init(
            id: "vxvnizfaybkwjkzu",
            pulseNovaCoins: 2450,
            pulseNovaFallbackPriceText: "$4.99"
        ),
        .init(
            id: "wcbfuyhnqzmkxglt",
            pulseNovaCoins: 3950,
            pulseNovaFallbackPriceText: "$8.99"
        ),
        .init(
            id: "vlbnmqqlefiakumk",
            pulseNovaCoins: 5150,
            pulseNovaFallbackPriceText: "$9.99"
        ),
        .init(
            id: "rptlvsxqmejndkaf",
            pulseNovaCoins: 7700,
            pulseNovaFallbackPriceText: "$14.99"
        ),
        .init(
            id: "shnovlsbsbwhwrqz",
            pulseNovaCoins: 10800,
            pulseNovaFallbackPriceText: "$19.99"
        ),
        .init(
            id: "dybnxzrwmzsmxvif",
            pulseNovaCoins: 29400,
            pulseNovaFallbackPriceText: "$49.99"
        ),
        .init(
            id: "uqrfdpcsngvpahtc",
            pulseNovaCoins: 63700,
            pulseNovaFallbackPriceText: "$99.99"
        )
    ]

    private let pulseNovaUserStore = NovaPulseUserStore()
    private let pulseNovaBackgroundRetryLimit = 5
    private var pulseNovaProductsRequest: SKProductsRequest?
    private var pulseNovaBackgroundRetryTask: Task<Void, Never>?
    private var pulseNovaBackgroundAttemptCount = 0
    private var pulseNovaCurrentRequestIsSilent = false
    private var pulseNovaCurrentRequestIsBackgroundWarmup = false

    private override init() {
        super.init()
    }

    func pulseNovaRegisterPaymentObserver() {
        SKPaymentQueue.default().add(self)
    }

    func pulseNovaStartBackgroundProductWarmup() {
        guard pulseNovaProducts.isEmpty else {
            return
        }

        pulseNovaBackgroundRetryTask?.cancel()
        pulseNovaBackgroundAttemptCount = 0
        pulseNovaPerformBackgroundWarmupAttempt()
    }

    func pulseNovaLoadProducts(
        isSilent pulseNovaIsSilent: Bool = false
    ) {
        pulseNovaBackgroundRetryTask?.cancel()
        pulseNovaCurrentRequestIsBackgroundWarmup = false
        pulseNovaBeginProductsRequest(
            isSilent: pulseNovaIsSilent,
            isBackgroundWarmup: false
        )
    }

    private func pulseNovaBeginProductsRequest(
        isSilent pulseNovaIsSilent: Bool,
        isBackgroundWarmup pulseNovaIsBackgroundWarmup: Bool
    ) {
        guard pulseNovaPurchaseState != .loadingProducts else {
            return
        }

        pulseNovaProductsRequest?.cancel()
        pulseNovaCurrentRequestIsSilent = pulseNovaIsSilent
        pulseNovaCurrentRequestIsBackgroundWarmup = pulseNovaIsBackgroundWarmup
        pulseNovaPurchaseState = .loadingProducts

        let pulseNovaRequest = SKProductsRequest(
            productIdentifiers: Set(
                pulseNovaRechargeProducts.map(\.pulseNovaProductIdentifier)
            )
        )
        pulseNovaRequest.delegate = self
        pulseNovaProductsRequest = pulseNovaRequest
        pulseNovaRequest.start()
    }

    func pulseNovaReloadProducts() {
        pulseNovaProducts = [:]
        pulseNovaLoadProducts()
    }

    func pulseNovaPurchase(
        productID pulseNovaProductID: String
    ) {
        guard SKPaymentQueue.canMakePayments() else {
            pulseNovaPublishResult(
                message: "In-app purchases are disabled on this device.",
                style: .error
            )
            return
        }

        guard let pulseNovaProduct = pulseNovaProducts[pulseNovaProductID] else {
            pulseNovaPublishResult(
                message: "Product information is unavailable right now.",
                style: .error
            )
            return
        }

        pulseNovaPurchaseState = .purchasing(productID: pulseNovaProductID)
        let pulseNovaPayment = SKPayment(product: pulseNovaProduct)
        SKPaymentQueue.default().add(pulseNovaPayment)
    }

    func pulseNovaDisplayPrice(
        for pulseNovaRechargeProduct: PulseNovaRechargeProduct
    ) -> String {
        guard let pulseNovaProduct = pulseNovaProducts[
            pulseNovaRechargeProduct.pulseNovaProductIdentifier
        ] else {
            return pulseNovaRechargeProduct.pulseNovaFallbackPriceText
        }

        let pulseNovaFormatter = NumberFormatter()
        pulseNovaFormatter.numberStyle = .currency
        pulseNovaFormatter.locale = pulseNovaProduct.priceLocale

        return pulseNovaFormatter.string(
            from: pulseNovaProduct.price
        ) ?? pulseNovaRechargeProduct.pulseNovaFallbackPriceText
    }

    func pulseNovaConsumePurchaseResult() {
        pulseNovaPurchaseResult = nil
    }

    private func pulseNovaResetPurchaseState() {
        if pulseNovaPurchaseState != .loadingProducts {
            pulseNovaPurchaseState = .idle
        }
    }

    private func pulseNovaPublishResult(
        message pulseNovaMessage: String,
        style pulseNovaStyle: PulseNovaPurchaseResult.PulseNovaResultStyle
    ) {
        pulseNovaPurchaseResult = PulseNovaPurchaseResult(
            pulseNovaMessage: pulseNovaMessage,
            pulseNovaStyle: pulseNovaStyle
        )
    }

    private func pulseNovaPerformBackgroundWarmupAttempt() {
        guard pulseNovaBackgroundAttemptCount < pulseNovaBackgroundRetryLimit else {
            return
        }

        pulseNovaBackgroundAttemptCount += 1
        pulseNovaBeginProductsRequest(
            isSilent: true,
            isBackgroundWarmup: true
        )
    }

    private func pulseNovaScheduleBackgroundRetryIfNeeded() {
        guard pulseNovaCurrentRequestIsBackgroundWarmup,
              pulseNovaProducts.isEmpty,
              pulseNovaBackgroundAttemptCount < pulseNovaBackgroundRetryLimit else {
            return
        }

        pulseNovaBackgroundRetryTask?.cancel()
        pulseNovaBackgroundRetryTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            guard !Task.isCancelled else {
                return
            }

            self.pulseNovaPerformBackgroundWarmupAttempt()
        }
    }

    private func pulseNovaHandleProductsLoadFailure(
        message pulseNovaMessage: String
    ) {
        pulseNovaProductsRequest = nil
        pulseNovaPurchaseState = .idle

        if pulseNovaCurrentRequestIsBackgroundWarmup {
            pulseNovaScheduleBackgroundRetryIfNeeded()
        }

        _ = pulseNovaMessage
    }

    private func pulseNovaHandlePurchasedTransaction(
        _ pulseNovaTransaction: SKPaymentTransaction
    ) {
        let pulseNovaProductID = pulseNovaTransaction.payment.productIdentifier

        do {
            guard let pulseNovaLoggedInUserID = LiftVaultPersistenceStore
                .liftVaultLoadLoggedInUserID(),
                  !pulseNovaLoggedInUserID.trimmingCharacters(
                    in: .whitespacesAndNewlines
                  ).isEmpty,
                  var pulseNovaCurrentUser = try pulseNovaUserStore.novaPulseFetchUser(
                    byID: pulseNovaLoggedInUserID
                  ) else {
                SKPaymentQueue.default().finishTransaction(pulseNovaTransaction)
                pulseNovaResetPurchaseState()
                pulseNovaPublishResult(
                    message: "Please sign in before purchasing.",
                    style: .error
                )
                return
            }

            guard let pulseNovaRechargeProduct = pulseNovaRechargeProducts.first(
                where: { $0.pulseNovaProductIdentifier == pulseNovaProductID }
            ) else {
                SKPaymentQueue.default().finishTransaction(pulseNovaTransaction)
                pulseNovaResetPurchaseState()
                pulseNovaPublishResult(
                    message: "Purchase completed, but product mapping is missing.",
                    style: .error
                )
                return
            }

            pulseNovaCurrentUser.novaPulseGoldCoinCount +=
            pulseNovaRechargeProduct.pulseNovaCoins
            try pulseNovaUserStore.novaPulseUpdateUser(pulseNovaCurrentUser)

            SKPaymentQueue.default().finishTransaction(pulseNovaTransaction)
            pulseNovaPurchaseState = .idle
            pulseNovaPublishResult(
                message: "Recharge successful.",
                style: .success
            )
        } catch {
            SKPaymentQueue.default().finishTransaction(pulseNovaTransaction)
            pulseNovaPurchaseState = .idle
            pulseNovaPublishResult(
                message: "Unable to finish this purchase right now.",
                style: .error
            )
        }
    }
}

extension PulseNovaStoreKitCenter: SKProductsRequestDelegate {
    nonisolated func productsRequest(
        _ request: SKProductsRequest,
        didReceive response: SKProductsResponse
    ) {
        Task { @MainActor in
            self.pulseNovaProducts = Dictionary(
                uniqueKeysWithValues: response.products.map {
                    ($0.productIdentifier, $0)
                }
            )
            self.pulseNovaProductsRequest = nil
            self.pulseNovaPurchaseState = .idle
            self.pulseNovaBackgroundRetryTask?.cancel()

            if response.products.isEmpty {
                self.pulseNovaHandleProductsLoadFailure(
                    message: "Unable to load recharge products right now."
                )
                return
            }

            if !response.invalidProductIdentifiers.isEmpty {
                if self.pulseNovaCurrentRequestIsBackgroundWarmup {
                    self.pulseNovaScheduleBackgroundRetryIfNeeded()
                }
            }
        }
    }

    nonisolated func request(
        _ request: SKRequest,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            self.pulseNovaHandleProductsLoadFailure(
                message: "Unable to load recharge products right now."
            )
        }
    }
}

extension PulseNovaStoreKitCenter: SKPaymentTransactionObserver {
    nonisolated func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        for pulseNovaTransaction in transactions {
            switch pulseNovaTransaction.transactionState {
            case .purchased, .restored:
                Task { @MainActor in
                    self.pulseNovaHandlePurchasedTransaction(
                        pulseNovaTransaction
                    )
                }
            case .failed:
                Task { @MainActor in
                    SKPaymentQueue.default().finishTransaction(
                        pulseNovaTransaction
                    )
                    self.pulseNovaPurchaseState = .idle

                    if let pulseNovaError = pulseNovaTransaction.error as? SKError,
                       pulseNovaError.code == .paymentCancelled {
                        return
                    }

                    self.pulseNovaPublishResult(
                        message: pulseNovaTransaction.error?.localizedDescription
                        ?? "Purchase failed.",
                        style: .error
                    )
                }
            case .purchasing, .deferred:
                Task { @MainActor in
                    self.pulseNovaPurchaseState = .purchasing(
                        productID: pulseNovaTransaction.payment.productIdentifier
                    )
                }
            @unknown default:
                Task { @MainActor in
                    SKPaymentQueue.default().finishTransaction(
                        pulseNovaTransaction
                    )
                    self.pulseNovaPurchaseState = .idle
                }
            }
        }
    }
}
