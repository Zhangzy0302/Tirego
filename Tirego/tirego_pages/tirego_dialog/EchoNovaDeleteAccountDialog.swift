import SwiftUI

struct EchoNovaDeleteAccountDialog: View {
    enum EchoNovaDialogMode {
        case deleteAccount
        case logOut

        var echoNovaMessageText: String {
            switch self {
            case .deleteAccount:
                return "Your account will be\npermanently deleted. This\ncannot be reversed."
            case .logOut:
                return "Are you sure you want to\nlog out?"
            }
        }

        var echoNovaActionTitle: String {
            switch self {
            case .deleteAccount:
                return "Delete"
            case .logOut:
                return "Log out"
            }
        }
    }

    let echoNovaMode: EchoNovaDialogMode
    let echoNovaPrimaryAction: () -> Void
    let echoNovaCloseAction: () -> Void

    var body: some View {
        VStack(spacing: 23) {
            ZStack(alignment: .top) {
                Image("TIREGODialogBg")
                    .resizable()
                    .frame(width: 244, height: 291)

                Circle()
                    .fill(Color.chalkJetBlack)
                    .frame(width: 14, height: 14)
                    .padding(.top, 12)

                VStack(spacing: 0) {
                    VStack(spacing: 0) {

                        Text(echoNovaMode.echoNovaMessageText)
                            .font(.pulseRobotoRegular(size: 16))
                            .foregroundStyle(Color.chalkInk)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.top, 80)
                        Spacer()
                        PulseActionButton(
                            pulseTitle: echoNovaMode.echoNovaActionTitle,
                            pulseStyle: .flexDark,
                            pulseHorizontalPadding: 26,
                            pulseWidth: 146,
                            pulseHeight: 47,
                            pulseTapAction: echoNovaPrimaryAction
                        )
                        .padding(.bottom, 41)
                    }
                }
            }
            .frame(width: 244, height: 291)

            Button(action: echoNovaCloseAction) {
                Image("TIREGOIconClose")
                    .resizable()
                    .frame(width: 31, height: 31)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.75).ignoresSafeArea()

        EchoNovaDeleteAccountDialog(
            echoNovaMode: .deleteAccount,
            echoNovaPrimaryAction: {},
            echoNovaCloseAction: {}
        )
    }
}
