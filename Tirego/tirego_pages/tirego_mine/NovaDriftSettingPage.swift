import SwiftUI

struct NovaDriftSettingPage: View {
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub

    private enum NovaDriftSettingItem: String, CaseIterable {
        case privacyPolicy = "Privacy Policy"
        case userAgreement = "User Agreement"
        case blacklist = "Blacklist"
    }

    @State private var novaDriftDialogMode: EchoNovaDeleteAccountDialog.EchoNovaDialogMode?

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                BlazeOrbitTopBar(blazeOrbitTitle: "Setting")
                    .padding(.top, 16)
                    .padding(.horizontal, 18)

                VStack(spacing: 0) {
                    ForEach(NovaDriftSettingItem.allCases, id: \.self) { novaDriftSettingItem in
                        NovaDriftSettingRow(
                            novaDriftTitle: novaDriftSettingItem.rawValue,
                            novaDriftTapAction: {
                                novaDriftHandleSettingTap(novaDriftSettingItem)
                            }
                        )
                    }
                }
                .padding(.top, 26)
                .padding(.horizontal, 20)

                Spacer()

                VStack(spacing: 16) {
                    PulseActionButton(
                        pulseTitle: "Delete account",
                        pulseStyle: .chalkSecondary,
                        pulseHorizontalPadding: 16,
                        pulseTapAction: {
                            novaDriftDialogMode = .deleteAccount
                        }
                    )

                    PulseActionButton(
                        pulseTitle: "Log out",
                        pulseStyle: .burnPrimary,
                        pulseHorizontalPadding: 16,
                        pulseTapAction: {
                            novaDriftDialogMode = .logOut
                        }
                    )
                }
                .padding(.bottom, 24)
                .padding(.horizontal, 36)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            if let novaDriftDialogMode {
                Color.black.opacity(0.72)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.novaDriftDialogMode = nil
                    }

                EchoNovaDeleteAccountDialog(
                    echoNovaMode: novaDriftDialogMode,
                    echoNovaPrimaryAction: {
                        novaDriftHandlePrimaryDialogAction(
                            novaDriftDialogMode
                        )
                    },
                    echoNovaCloseAction: {
                        self.novaDriftDialogMode = nil
                    }
                )
            }
        }
        .burnStageBackground()
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.18), value: novaDriftDialogMode != nil)
    }

    private func novaDriftHandleSettingTap(_ novaDriftSettingItem: NovaDriftSettingItem) {
        switch novaDriftSettingItem {
        case .privacyPolicy:
            pulseNovaRouter.pulseNovaPush(
                .orbitNovaWebPortal(
                    orbitNovaURLString: "https://app.txrggfzo.link/privacy",
                    orbitNovaTitle: "Privacy Policy"
                )
            )
        case .userAgreement:
            pulseNovaRouter.pulseNovaPush(
                .orbitNovaWebPortal(
                    orbitNovaURLString: "https://app.txrggfzo.link/users",
                    orbitNovaTitle: "User Agreement"
                )
            )
        case .blacklist:
            pulseNovaRouter.pulseNovaPush(.orbitNovaConnectionsBlocklist)
        }
    }

    private func novaDriftHandlePrimaryDialogAction(
        _ novaDriftDialogMode: EchoNovaDeleteAccountDialog.EchoNovaDialogMode
    ) {
        self.novaDriftDialogMode = nil

        switch novaDriftDialogMode {
        case .deleteAccount:
            novaDriftHandleDeleteAccount()
        case .logOut:
            novaDriftHandleLogOut()
        }
    }

    private func novaDriftHandleDeleteAccount() {
        guard let novaDriftLoggedInUserID = LiftVaultPersistenceStore
            .liftVaultLoadLoggedInUserID()?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !novaDriftLoggedInUserID.isEmpty else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Current account not found.",
                style: .error
            )
            pulseNovaRouter.pulseNovaReset(to: .novaTrailWelcomeGate)
            return
        }

        novaPulseFeedbackHub.novaPulseShowLoading(
            message: "Deleting account..."
        )

        Task { @MainActor in
            do {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                try ForgeNovaAccountCenter.forgeNovaDeleteAccount(
                    forgeNovaUserID: novaDriftLoggedInUserID
                )
                novaPulseFeedbackHub.novaPulseHideLoading()
                novaDriftTransitionToWelcomeGate(
                    toastMessage: "Account deleted successfully."
                )
            } catch {
                novaPulseFeedbackHub.novaPulseHideLoading()
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Failed to delete account.",
                    style: .error
                )
            }
        }
    }

    private func novaDriftHandleLogOut() {
        ForgeNovaAccountCenter.forgeNovaLogOutAccount()
        novaDriftTransitionToWelcomeGate(
            toastMessage: "Logged out successfully."
        )
    }

    private func novaDriftTransitionToWelcomeGate(
        toastMessage novaDriftToastMessage: String
    ) {
        pulseNovaRouter.pulseNovaReset(to: .novaTrailWelcomeGate)

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)
            novaPulseFeedbackHub.novaPulseShowToast(
                novaDriftToastMessage,
                style: .success
            )
        }
    }
}

private struct NovaDriftSettingRow: View {
    let novaDriftTitle: String
    let novaDriftTapAction: () -> Void

    var body: some View {
        Button(action: novaDriftTapAction) {
            HStack {
                Text(novaDriftTitle)
                    .font(.pulseBodyCaption(size: 16))
                    .foregroundStyle(Color.chalkPureWhite)

                Spacer()

                Image("TIREGOSettingArrow")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NovaDriftSettingPage()
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
}
