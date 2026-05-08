import SwiftUI

struct ForgePulseAuthPortalPage: View {
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub
    private let forgePulseUserStore = NovaPulseUserStore()

    enum ForgePulseAuthMode {
        case signIn
        case signUp
        case forgotPassword

        var forgePulseTitle: String {
            switch self {
            case .signIn:
                return "Sign in"
            case .signUp:
                return "Sign up"
            case .forgotPassword:
                return "Forget the password"
            }
        }

        var forgePulsePrimaryButtonTitle: String {
            switch self {
            case .signIn:
                return "Log in"
            case .signUp:
                return "Sign up"
            case .forgotPassword:
                return "Save"
            }
        }

        var forgePulseShowsForgotLink: Bool {
            self == .signIn
        }

        var forgePulseNeedsConfirmField: Bool {
            switch self {
            case .signIn:
                return false
            case .signUp, .forgotPassword:
                return true
            }
        }
    }

    @State private var forgePulseCurrentMode: ForgePulseAuthMode

    @State private var forgePulseEmailText = ""
    @State private var forgePulsePasswordText = ""
    @State private var forgePulseConfirmPasswordText = ""
    @FocusState private var forgePulseEmailFocused: Bool
    @FocusState private var forgePulsePasswordFocused: Bool
    @FocusState private var forgePulseConfirmPasswordFocused: Bool

    init(forgePulseMode: ForgePulseAuthMode) {
        _forgePulseCurrentMode = State(initialValue: forgePulseMode)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    forgePulseDismissAllFocus()
                }

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: 101)

                Text(forgePulseCurrentMode.forgePulseTitle)
                    .font(.flexCarterDisplay(size: forgePulseCurrentMode == .forgotPassword ? 28 : 36))
                    .foregroundStyle(Color.burnSignalYellow)

                VStack(alignment: .leading, spacing: 11) {
                    Text("Email")
                        .font(.pulseRobotoBold(size: 15))
                        .foregroundStyle(Color.chalkPureWhite)

                    CoreLiftEntryField(
                        coreLiftPlaceholder: "Please enter",
                        coreLiftText: $forgePulseEmailText,
                        coreLiftKeyboardType: .emailAddress,
                        coreLiftFocusState: $forgePulseEmailFocused
                    )
                }
                .padding(.top, 28)

                VStack(alignment: .leading, spacing: 11) {
                    Text("Password")
                        .font(.pulseRobotoBold(size: 15))
                        .foregroundStyle(Color.chalkPureWhite)

                    CoreLiftEntryField(
                        coreLiftPlaceholder: "Please enter",
                        coreLiftText: $forgePulsePasswordText,
                        coreLiftIsSecure: true,
                        coreLiftFocusState: $forgePulsePasswordFocused
                    )

                    if forgePulseCurrentMode.forgePulseNeedsConfirmField {
                        CoreLiftEntryField(
                            coreLiftPlaceholder: "Please enter again",
                            coreLiftText: $forgePulseConfirmPasswordText,
                            coreLiftIsSecure: true,
                            coreLiftFocusState: $forgePulseConfirmPasswordFocused
                        )
                        .padding(.top, 6)
                    }
                }
                .padding(.top, 16)

                if forgePulseCurrentMode.forgePulseShowsForgotLink {
                    HStack {
                        Spacer()

                        Button(action: {
                            forgePulseDismissAllFocus()
                            forgePulseCurrentMode = .forgotPassword
                        }) {
                            Text("Forgot ?")
                                .font(.pulseBodyCaption())
                                .foregroundStyle(Color.burnSignalYellow)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 11)
                    .padding(.trailing, 16)
                }

                PulseActionButton(
                    pulseTitle: forgePulseCurrentMode.forgePulsePrimaryButtonTitle,
                    pulseStyle: .burnPrimary,
                    pulseHorizontalPadding: 11,
                    pulseTapAction: forgePulseHandlePrimaryAction
                )
                .padding(.top, forgePulseCurrentMode.forgePulseShowsForgotLink ? 50 : 40)

                Spacer()
            }
            .padding(.horizontal, 22)
            
            BlazeOrbitTopBar()
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .burnStageBackground()
        .preferredColorScheme(.dark)
    }

    private func forgePulseDismissAllFocus() {
        forgePulseEmailFocused = false
        forgePulsePasswordFocused = false
        forgePulseConfirmPasswordFocused = false
    }

    private func forgePulseHandlePrimaryAction() {
        forgePulseDismissAllFocus()
        
        DispatchQueue.main.async {
            switch forgePulseCurrentMode {
            case .signIn:
                forgePulseHandleSignIn()
            case .signUp:
                forgePulseHandleSignUp()
            case .forgotPassword:
                pulseNovaRouter.pulseNovaPop()
            }
        }
    }

    private func forgePulseHandleSignIn() {
        let forgePulseNormalizedEmail = forgePulseEmailText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let forgePulseNormalizedPassword = forgePulsePasswordText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !forgePulseNormalizedEmail.isEmpty else {
            forgePulsePresentAlert("8ec188fe8bd186835ff7c7ba0157023f0a3bf8aa52e5e26f8fd948e3ea0f3c04".forgeNovaAESDecrypted())
            return
        }

        guard !forgePulseNormalizedPassword.isEmpty else {
            forgePulsePresentAlert("8ec188fe8bd186835ff7c7ba0157023f52173caf71f19bdd95c195e36a392b57".forgeNovaAESDecrypted())
            return
        }

        novaPulseFeedbackHub.novaPulseShowLoading(message: "Logging in...")

        do {
            guard let forgePulseMatchedUser = try forgePulseUserStore.novaPulseFetchUser(
                byEmail: forgePulseNormalizedEmail
            ) else {
                novaPulseFeedbackHub.novaPulseHideLoading()
                forgePulsePresentAlert("4febf37749e0df368aeac29893268d49ab791008d304f449f30e93303443c29fc44c53d0a93c700229a9a2e99f77da6d".forgeNovaAESDecrypted())
                return
            }

            guard forgePulseMatchedUser.novaPulsePassword == forgePulseNormalizedPassword else {
                novaPulseFeedbackHub.novaPulseHideLoading()
                forgePulsePresentAlert("d602f5652ba3d6e5d38ca62d5d69d9b9ecea1f5748b9584b6ced379cfea86c35".forgeNovaAESDecrypted())
                return
            }

            LiftVaultPersistenceStore.liftVaultSaveLoggedInUserID(forgePulseMatchedUser.id)
            forgePulseHandleSuccessTransition(
                successMessage: "74c460ba3f1b97039bbb46640a38ebb2a7d62aa3d5b46407b9ac859b997c7723".forgeNovaAESDecrypted()
            )
        } catch {
            novaPulseFeedbackHub.novaPulseHideLoading()
            forgePulsePresentAlert("04fb6f1b284aa7273bd635bddc9c1cc9b0d92a8238a6af1e03a281528a511b1f4b34c325f1cef3e3570c02185ecae306".forgeNovaAESDecrypted())
        }
    }

    private func forgePulseHandleSignUp() {
        let forgePulseNormalizedEmail = forgePulseEmailText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let forgePulseNormalizedPassword = forgePulsePasswordText
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let forgePulseNormalizedConfirmPassword = forgePulseConfirmPasswordText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !forgePulseNormalizedEmail.isEmpty else {
            forgePulsePresentAlert("8ec188fe8bd186835ff7c7ba0157023f0a3bf8aa52e5e26f8fd948e3ea0f3c04".forgeNovaAESDecrypted())
            return
        }

        guard !forgePulseNormalizedPassword.isEmpty else {
            forgePulsePresentAlert("8ec188fe8bd186835ff7c7ba0157023f52173caf71f19bdd95c195e36a392b57".forgeNovaAESDecrypted())
            return
        }

        guard forgePulseNormalizedPassword == forgePulseNormalizedConfirmPassword else {
            forgePulsePresentAlert("f697eab7bbdd3841f418cf6839f921191e5a61b102cdc436b6555882a21c8225".forgeNovaAESDecrypted())
            return
        }

        do {
            if try forgePulseUserStore.novaPulseFetchUser(byEmail: forgePulseNormalizedEmail) != nil {
                forgePulsePresentAlert("ab68297ee65143282de11448c9763876ea963caf70d7fae382f25305d77998157c2527eed88073f1a95695c397f6012b".forgeNovaAESDecrypted())
                return
            }

            pulseNovaRouter.pulseNovaPush(
                .blazeOrbitProfileSetup(
                    blazeOrbitEmail: forgePulseNormalizedEmail,
                    blazeOrbitPassword: forgePulseNormalizedPassword
                )
            )
        } catch {
            forgePulsePresentAlert("587b95b4b1ce5a8df6feeb425aedef5dfd2b68b48e175f266ae9bf6de1114bcf1efcf552218dcb22f7acb4e496b98fcf".forgeNovaAESDecrypted())
        }
    }

    private func forgePulsePresentAlert(_ forgePulseMessage: String) {
        novaPulseFeedbackHub.novaPulseShowToast(
            forgePulseMessage,
            style: .error
        )
    }

    private func forgePulseHandleSuccessTransition(
        successMessage: String
    ) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            novaPulseFeedbackHub.novaPulseHideLoading()
            novaPulseFeedbackHub.novaPulseShowToast(
                successMessage,
                style: .success
            )
            try? await Task.sleep(nanoseconds: 150_000_000)
            pulseNovaRouter.pulseNovaPresent(.novaTrailTabShell)
        }
    }
}
