import SwiftUI

struct PulseNovaRechargePage: View {
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub

    private let pulseNovaUserStore = NovaPulseUserStore()
    private let pulseNovaGridItems = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    @ObservedObject private var pulseNovaStoreKitCenter =
    PulseNovaStoreKitCenter.shared

    @State private var pulseNovaCoinBalance = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BlazeOrbitTopBar(blazeOrbitTitle: "Recharge")
                .padding(.top, 16)
                .padding(.horizontal, 18)

            pulseNovaBalanceCard
                .padding(.top, 26)
                .padding(.horizontal, 18)
            ScrollView {
                LazyVGrid(columns: pulseNovaGridItems, spacing: 12) {
                    ForEach(pulseNovaStoreKitCenter.pulseNovaRechargeProducts) {
                        pulseNovaPackage in
                        PulseNovaRechargeCard(
                            pulseNovaPackage: pulseNovaPackage,
                            pulseNovaPriceText: pulseNovaStoreKitCenter
                                .pulseNovaDisplayPrice(for: pulseNovaPackage),
                            pulseNovaTapAction: {
                                pulseNovaStoreKitCenter.pulseNovaPurchase(
                                    productID: pulseNovaPackage
                                        .pulseNovaProductIdentifier
                                )
                            }
                        )
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 26)
            }.padding(.top, 22)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .burnStageBackground()
            .preferredColorScheme(.dark)
            .task {
                pulseNovaRefreshBalance()
                pulseNovaStoreKitCenter.pulseNovaLoadProducts()
            }
            .refreshable {
                pulseNovaRefreshBalance()
                pulseNovaStoreKitCenter.pulseNovaReloadProducts()
            }
            .onChange(of: pulseNovaStoreKitCenter.pulseNovaPurchaseState) {
                pulseNovaPurchaseState in
                switch pulseNovaPurchaseState {
                case .idle:
                    novaPulseFeedbackHub.novaPulseHideLoading()
                case .loadingProducts:
                    novaPulseFeedbackHub.novaPulseShowLoading(
                        message: "Loading recharge products..."
                    )
                case .purchasing:
                    novaPulseFeedbackHub.novaPulseShowLoading(
                        message: "Processing purchase..."
                    )
                }
            }
            .onChange(of: pulseNovaStoreKitCenter.pulseNovaPurchaseResult) {
                pulseNovaPurchaseResult in
                guard let pulseNovaPurchaseResult else {
                    return
                }

                pulseNovaRefreshBalance()

                switch pulseNovaPurchaseResult.pulseNovaStyle {
                case .success:
                    novaPulseFeedbackHub.novaPulseShowToast(
                        pulseNovaPurchaseResult.pulseNovaMessage,
                        style: .success
                    )
                case .error:
                    novaPulseFeedbackHub.novaPulseShowToast(
                        pulseNovaPurchaseResult.pulseNovaMessage,
                        style: .error
                    )
                }

                pulseNovaStoreKitCenter.pulseNovaConsumePurchaseResult()
            }
        
    }

    private var pulseNovaBalanceCard: some View {
        HStack(spacing: 10) {
            Image("TIREGOCoin")
                .resizable()
                .frame(width: 52, height: 52)

            Text("\(pulseNovaCoinBalance)")
                .font(.pulseRobotoBold(size: 20))
                .foregroundStyle(Color.chalkJetBlack)
        }
        .padding(.horizontal, 92)
        .frame(height: 82)
        .frame(maxWidth: .infinity)
        .background(Color.burnSignalYellow)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func pulseNovaRefreshBalance() {
        do {
            guard let pulseNovaLoggedInUserID = LiftVaultPersistenceStore
                .liftVaultLoadLoggedInUserID(),
                  let pulseNovaCurrentUser = try pulseNovaUserStore.novaPulseFetchUser(
                    byID: pulseNovaLoggedInUserID
                  ) else {
                pulseNovaCoinBalance = 0
                return
            }

            pulseNovaCoinBalance = pulseNovaCurrentUser.novaPulseGoldCoinCount
        } catch {
            pulseNovaCoinBalance = 0
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load your balance right now.",
                style: .error
            )
        }
    }
}

private struct PulseNovaRechargeCard: View {
    let pulseNovaPackage: PulseNovaStoreKitCenter.PulseNovaRechargeProduct
    let pulseNovaPriceText: String
    let pulseNovaTapAction: () -> Void

    var body: some View {
        Button(action: pulseNovaTapAction) {
            VStack(spacing: 0) {
                Image("TIREGOCoin")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.top, 12)

                Text("\(pulseNovaPackage.pulseNovaCoins)")
                    .font(.pulseRobotoBold(size: 16))
                    .foregroundStyle(Color.chalkJetBlack)
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                Text(pulseNovaPriceText)
                    .font(.pulseRobotoRegular(size: 13))
                    .foregroundStyle(Color.chalkJetBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(Color.burnSignalYellow)
                    .clipShape(Capsule())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
            }
            .background(Color(red: 244 / 255, green: 246 / 255, blue: 250 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PulseNovaRechargePage()
        .environmentObject(NovaPulseFeedbackHub())
}
