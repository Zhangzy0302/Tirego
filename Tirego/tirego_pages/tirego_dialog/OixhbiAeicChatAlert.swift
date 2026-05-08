import SwiftUI

struct OixhbiAeicChatAlert: View {
    let oixhbiAeicConfirmAction: () -> Void
    let oixhbiAeicCloseAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .top) {
                Image("TIREGODialogBg")
                    .resizable()
                    .frame(width: 244, height: 291)

                VStack {
                    Text("Mutual follow required to start a conversation.")
                        .font(.pulseRobotoRegular(size: 16))
                        .foregroundStyle(Color.chalkInk)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 28)
                        .padding(.top, 94)

                    Spacer()
                    
                    PulseActionButton(
                        pulseTitle: "Sure",
                        pulseStyle: .flexDark,
                        pulseHorizontalPadding: 0,
                        pulseWidth: 146,
                        pulseHeight: 47,
                        pulseLabelFont: .pulseRobotoBold(size: 15),
                        pulseTapAction: oixhbiAeicConfirmAction
                    )
                    .padding(.top, 16)
                    .padding(.bottom, 41)
                }
            }.frame(width: 244, height: 291)

            Button(action: oixhbiAeicCloseAction) {
                Image("TIREGOIconClose")
                    .resizable()
                    .frame(width: 31, height: 31)
            }
            .buttonStyle(.plain)
        }
    }
}
