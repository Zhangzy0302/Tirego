import SwiftUI

struct ForgeNovaTutorialPayDialog: View {
    enum ForgeNovaDialogMode {
        case unlock
        case recharge
        
        var forgeNovaMessagePaddingTop: CGFloat {
            switch self {
            case .unlock:
                return 80
            case .recharge:
                return 67
            }
        }

        var forgeNovaShellBgImag: String {
            switch self {
            case .unlock:
                return "TIREGODialogBg"
            case .recharge:
                return "TIREGODialogBgGrey"
            }
        }

        var forgeNovaMessageText: String {
            switch self {
            case .unlock:
                return "Are you sure you want to\nspend 200 gold coins to\nunlock this video?"
            case .recharge:
                return "Sorry, your balance is\ninsufficient. Please top up\nyour account first and\nthen proceed with this\noperation."
            }
        }

        var forgeNovaActionTitle: String {
            switch self {
            case .unlock:
                return "Sure"
            case .recharge:
                return "Recharge"
            }
        }
    }

    let forgeNovaMode: ForgeNovaDialogMode
    let forgeNovaPrimaryAction: () -> Void
    let forgeNovaCloseAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .top) {
                Image(forgeNovaMode.forgeNovaShellBgImag)
                    .resizable()
                    .frame(width: 244, height: 291)

                VStack {
                    Text(forgeNovaMode.forgeNovaMessageText)
                        .font(.pulseRobotoRegular(size: 16))
                        .foregroundStyle(Color.chalkInk)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 28)
                        .padding(.top, forgeNovaMode.forgeNovaMessagePaddingTop)

                    Spacer()
                    
                    PulseActionButton(
                        pulseTitle: forgeNovaMode.forgeNovaActionTitle,
                        pulseStyle: .flexDark,
                        pulseHorizontalPadding: 0,
                        pulseWidth: 146,
                        pulseHeight: 47,
                        pulseLabelFont: .pulseRobotoBold(size: 15),
                        pulseTapAction: forgeNovaPrimaryAction
                    )
                    .padding(.top, 16)
                    .padding(.bottom, 41)
                }
            }.frame(width: 244, height: 291)

            Button(action: forgeNovaCloseAction) {
                Image("TIREGOIconClose")
                    .resizable()
                    .frame(width: 31, height: 31)
            }
            .buttonStyle(.plain)
        }
    }
}

