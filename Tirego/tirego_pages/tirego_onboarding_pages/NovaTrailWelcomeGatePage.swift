import SwiftUI

struct NovaTrailWelcomeGatePage: View {
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub

    private let novaTrailUserStore = NovaPulseUserStore()

    private enum NovaTrailGateRoute {
        case pulseLogin
        case forgeSignup
        case orbitGuestEntry
    }

    @AppStorage(LiftVaultPersistenceStore.liftVaultHasAcceptedEULAKey)
    private var novaTrailHasAcceptedEULA = LiftVaultPersistenceStore.liftVaultHasAcceptedEULADefaultValue
    @State private var novaTrailShowsEULASheet = false
    @State private var novaTrailPendingRoute: NovaTrailGateRoute?

    var body: some View {
        ZStack {
            ZStack(alignment: .bottom){
                GeometryReader { geo in
                    Image("TIREGOGateBg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .ignoresSafeArea()
                }
                
                    
                LinearGradient(colors: [
                    .black,
                    .black.opacity(0)
                ], startPoint: .bottom, endPoint: .top)
                .frame(height: 400)
            }
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 14) {
                    PulseActionButton(
                        pulseTitle: "Login by email",
                        pulseStyle: .burnPrimary,
                        pulseTapAction: {
                            novaTrailHandleGateTap(route: .pulseLogin)
                        }
                    )

                    PulseActionButton(
                        pulseTitle: "I'm new",
                        pulseStyle: .chalkSecondary,
                        pulseTapAction: {
                            novaTrailHandleGateTap(route: .orbitGuestEntry)
                        }
                    )
                }

                VStack(spacing: 48) {
                    PulseInlineLinkRow(
                        pulseLeadingText: "Don't have an account? ",
                        pulseLinkText: "Sign up",
                        pulseTapAction: {
                            novaTrailHandleGateTap(route: .forgeSignup)
                        }
                    )

                    HStack(spacing: 0) {
                        PulseInlineLinkRow(
                            pulseLeadingText: "Agree with ",
                            pulseLinkText: "User Agreement",
                            pulseTrailingText: " and ",
                            pulseTapAction: {
                                pulseNovaRouter.pulseNovaPush(
                                    .orbitNovaWebPortal(
                                        orbitNovaURLString: "https://app.txrggfzo.link/users",
                                        orbitNovaTitle: "User Agreement"
                                    )
                                )
                            }
                        )

                        Button(action: {
                            pulseNovaRouter.pulseNovaPush(
                                .orbitNovaWebPortal(
                                    orbitNovaURLString: "https://app.txrggfzo.link/privacy",
                                    orbitNovaTitle: "Privacy Policy"
                                )
                            )
                        }) {
                            Text("Privacy Policy")
                                .font(.pulseBodyCaption())
                                .foregroundStyle(Color.burnSignalYellow)
                                .underline()
                        }
                        .buttonStyle(.plain)
                    }
                    .multilineTextAlignment(.center)
                }
                .padding(.top, 22)
                .padding(.bottom, 34)
            }
            .padding(.bottom, 14)

            if novaTrailShowsEULASheet {
                IronEchoEULABottomSheet(
                    ironEchoDisagreeAction: {
                        novaTrailShowsEULASheet = false
                        novaTrailPendingRoute = nil
                    },
                    ironEchoAgreeAction: {
                        novaTrailHasAcceptedEULA = true
                        novaTrailShowsEULASheet = false
                        novaTrailContinuePendingRoute()
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .burnStageBackground()
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.22), value: novaTrailShowsEULASheet)
    }

    private func novaTrailHandleGateTap(route: NovaTrailGateRoute) {
        if novaTrailHasAcceptedEULA {
            novaTrailPendingRoute = route
            novaTrailContinuePendingRoute()
            return
        }

        novaTrailPendingRoute = route
        novaTrailShowsEULASheet = true
    }

    private func novaTrailContinuePendingRoute() {
        guard let novaTrailPendingRoute else {
            return
        }

        switch novaTrailPendingRoute {
        case .pulseLogin:
            pulseNovaRouter.pulseNovaPush(.forgePulseAuthSignIn)
        case .forgeSignup:
            pulseNovaRouter.pulseNovaPush(.forgePulseAuthSignUp)
        case .orbitGuestEntry:
            Task {
                await novaTrailHandleGuestEntry()
            }
        }

        self.novaTrailPendingRoute = nil
    }

    @MainActor
    private func novaTrailHandleGuestEntry() async {
        novaPulseFeedbackHub.novaPulseShowLoading(message: "Entering as guest...")

        do {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            let novaTrailLoggedInGuestUserID: String
            if let novaTrailGuestUser = try novaTrailUserStore
                .novaPulseFetchAllUsers()
                .first(where: \.novaPulseIsGuest) {
                novaTrailLoggedInGuestUserID = novaTrailGuestUser.id
            } else {
                let novaTrailNewGuestUser = NovaPulseUser(
                    id: "guest_\(UUID().uuidString.lowercased())",
                    novaPulseEmail: "",
                    novaPulsePassword: "",
                    novaPulseAvatar: "TIREGODefaultAvatar",
                    novaPulseUserName: "Guest User",
                    novaPulseBirthdayDate: Date(),
                    novaPulseLocation: "",
                    novaPulseGender: .undisclosed,
                    novaPulseFollowerIDs: [],
                    novaPulseFollowingIDs: [],
                    novaPulseBlockedIDs: [],
                    novaPulsePurchasedTutorialIDs: [],
                    novaPulseCheckedInDateKeys: [],
                    novaPulseCheckInStreakCount: 0,
                    novaPulseGoldCoinCount: 0,
                    novaPulseIsGuest: true
                )

                try novaTrailUserStore.novaPulseCreateUser(novaTrailNewGuestUser)
                novaTrailLoggedInGuestUserID = novaTrailNewGuestUser.id
            }

            LiftVaultPersistenceStore.liftVaultSaveLoggedInUserID(
                novaTrailLoggedInGuestUserID
            )

            novaPulseFeedbackHub.novaPulseHideLoading()
            pulseNovaRouter.pulseNovaPresent(.novaTrailTabShell)
        } catch {
            novaPulseFeedbackHub.novaPulseHideLoading()
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to enter as guest right now.",
                style: .error
            )
        }
    }
}

struct PulseInlineLinkRow: View {
    let pulseLeadingText: String
    let pulseLinkText: String
    var pulseTrailingText: String? = nil
    let pulseTapAction: () -> Void

    private let pulseBodyColor = Color.chalkMist
    private let pulseLinkColor = Color.burnSignalYellow

    var body: some View {
        HStack(spacing: 0) {
            Text(pulseLeadingText)
                .foregroundStyle(pulseBodyColor)

            Button(action: pulseTapAction) {
                Text(pulseLinkText)
                    .foregroundStyle(pulseLinkColor)
                    .underline()
            }
            .buttonStyle(.plain)

            if let pulseTrailingText {
                Text(pulseTrailingText)
                    .foregroundStyle(pulseBodyColor)
            }
        }
        .font(.pulseBodyCaption())
        .multilineTextAlignment(.center)
    }
}

#Preview {
    NovaTrailWelcomeGatePage()
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
}
