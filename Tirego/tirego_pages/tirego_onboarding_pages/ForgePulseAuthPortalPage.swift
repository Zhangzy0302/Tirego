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
            forgePulsePresentAlert("Please enter your email.")
            return
        }

        guard !forgePulseNormalizedPassword.isEmpty else {
            forgePulsePresentAlert("Please enter your password.")
            return
        }

        novaPulseFeedbackHub.novaPulseShowLoading(message: "Logging in...")

        do {
            guard let forgePulseMatchedUser = try forgePulseUserStore.novaPulseFetchUser(
                byEmail: forgePulseNormalizedEmail
            ) else {
                novaPulseFeedbackHub.novaPulseHideLoading()
                forgePulsePresentAlert("This email has not been registered.")
                return
            }

            guard forgePulseMatchedUser.novaPulsePassword == forgePulseNormalizedPassword else {
                novaPulseFeedbackHub.novaPulseHideLoading()
                forgePulsePresentAlert("The password is incorrect.")
                return
            }

            LiftVaultPersistenceStore.liftVaultSaveLoggedInUserID(forgePulseMatchedUser.id)
            forgePulseHandleSuccessTransition(
                successMessage: "Login successful."
            )
        } catch {
            novaPulseFeedbackHub.novaPulseHideLoading()
            forgePulsePresentAlert("Unable to complete login right now.")
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
            forgePulsePresentAlert("Please enter your email.")
            return
        }

        guard !forgePulseNormalizedPassword.isEmpty else {
            forgePulsePresentAlert("Please enter your password.")
            return
        }

        guard forgePulseNormalizedPassword == forgePulseNormalizedConfirmPassword else {
            forgePulsePresentAlert("The two passwords do not match.")
            return
        }

        do {
            if try forgePulseUserStore.novaPulseFetchUser(byEmail: forgePulseNormalizedEmail) != nil {
                forgePulsePresentAlert("This email has already been registered.")
                return
            }

            pulseNovaRouter.pulseNovaPush(
                .blazeOrbitProfileSetup(
                    blazeOrbitEmail: forgePulseNormalizedEmail,
                    blazeOrbitPassword: forgePulseNormalizedPassword
                )
            )
        } catch {
            forgePulsePresentAlert("Unable to continue registration right now.")
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

#Preview("Sign In") {
    ForgePulseAuthPortalPage(forgePulseMode: .signIn)
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
}

#Preview("Sign Up") {
    ForgePulseAuthPortalPage(forgePulseMode: .signUp)
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
}

#Preview("Forgot Password") {
    ForgePulseAuthPortalPage(forgePulseMode: .forgotPassword)
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
}
