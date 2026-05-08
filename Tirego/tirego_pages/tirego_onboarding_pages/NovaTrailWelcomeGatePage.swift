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
                        pulseTitle: "b629af4ecf12c307737b8b0faa4329db".forgeNovaAESDecrypted(),
                        pulseStyle: .burnPrimary,
                        pulseTapAction: {
                            novaTrailHandleGateTap(route: .pulseLogin)
                        }
                    )

                    PulseActionButton(
                        pulseTitle: "ce3e7e31e9b122d9ce9dae1ac46f3270".forgeNovaAESDecrypted(),
                        pulseStyle: .chalkSecondary,
                        pulseTapAction: {
                            novaTrailHandleGateTap(route: .orbitGuestEntry)
                        }
                    )
                }

                VStack(spacing: 48) {
                    PulseInlineLinkRow(
                        pulseLeadingText: "e26f8f1287117b27f1757b8d668b554c3f2a71362e5edfaa9d5d2a1337bf6c6e".forgeNovaAESDecrypted(),
                        pulseLinkText: "5dcb39c134200a1d591e41e06ba9dfa9".forgeNovaAESDecrypted(),
                        pulseTapAction: {
                            novaTrailHandleGateTap(route: .forgeSignup)
                        }
                    )

                    HStack(spacing: 0) {
                        PulseInlineLinkRow(
                            pulseLeadingText: "0e7decd984d45f5878900d454b0a143e".forgeNovaAESDecrypted(),
                            pulseLinkText: "06165a12ffff0544be4316389508e68e".forgeNovaAESDecrypted(),
                            pulseTrailingText: " and ",
                            pulseTapAction: {
                                pulseNovaRouter.pulseNovaPush(
                                    .orbitNovaWebPortal(
                                        orbitNovaURLString: "269e226a720fa60161ea3bb462c61a7166514118e6e4a52cab9b5fe12fccb110".forgeNovaAESDecrypted(),
                                        orbitNovaTitle: "06165a12ffff0544be4316389508e68e".forgeNovaAESDecrypted()
                                    )
                                )
                            }
                        )

                        Button(action: {
                            pulseNovaRouter.pulseNovaPush(
                                .orbitNovaWebPortal(
                                    orbitNovaURLString: "269e226a720fa60161ea3bb462c61a7170bb60ed385850c7849c6fe742ce2ba09a4e0ca5b2786b6331d79bbc94cc8037".forgeNovaAESDecrypted(),
                                    orbitNovaTitle: "2cca9e184440fe114750fa727bb5c31b".forgeNovaAESDecrypted()
                                )
                            )
                        }) {
                            Text("2cca9e184440fe114750fa727bb5c31b".forgeNovaAESDecrypted())
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
