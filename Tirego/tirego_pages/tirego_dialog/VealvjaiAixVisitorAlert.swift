import SwiftUI

struct VealvjaiAixVisitorAlert: View {
    var vealvjaiAixMessage: String = "You need to log in to perform this action."
    let vealvjaiAixLoginAction: () -> Void
    let vealvjaiAixCloseAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .top) {
                Image("TIREGODialogBgGrey")
                    .resizable()
                    .frame(width: 244, height: 291)

                VStack {
                    Text(vealvjaiAixMessage)
                        .font(.pulseRobotoRegular(size: 16))
                        .foregroundStyle(Color.chalkInk)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 28)
                        .padding(.top, 92)

                    Spacer()
                    
                    PulseActionButton(
                        pulseTitle: "Log In",
                        pulseStyle: .flexDark,
                        pulseHorizontalPadding: 0,
                        pulseWidth: 146,
                        pulseHeight: 47,
                        pulseLabelFont: .pulseRobotoBold(size: 15),
                        pulseTapAction: vealvjaiAixLoginAction
                    )
                    .padding(.top, 16)
                    .padding(.bottom, 41)
                }
            }.frame(width: 244, height: 291)

            Button(action: vealvjaiAixCloseAction) {
                Image("TIREGOIconClose")
                    .resizable()
                    .frame(width: 31, height: 31)
            }
            .buttonStyle(.plain)
        }
    }
}
