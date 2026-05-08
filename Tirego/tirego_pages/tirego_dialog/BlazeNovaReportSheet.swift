import SwiftUI

struct BlazeNovaReportSheet: View {
    let blazeNovaReportAction: () -> Void
    let blazeNovaBlockAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(spacing: 71) {
                blazeNovaActionButton(
                    blazeNovaTitle: "Report",
                    blazeNovaSystemImage: "TIREGOIconReport",
                    blazeNovaIconBackground: .burnSignalYellow,
                    blazeNovaIconForeground: .chalkJetBlack,
                    blazeNovaTapAction: blazeNovaReportAction
                )

                blazeNovaActionButton(
                    blazeNovaTitle: "Block",
                    blazeNovaSystemImage: "TIREGOIconBlock",
                    blazeNovaIconBackground: .chalkPureWhite,
                    blazeNovaIconForeground: .chalkJetBlack,
                    blazeNovaTapAction: blazeNovaBlockAction
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 44)
            .background(Color(red: 18 / 255, green: 18 / 255, blue: 6 / 255))
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func blazeNovaActionButton(
        blazeNovaTitle: String,
        blazeNovaSystemImage: String,
        blazeNovaIconBackground: Color,
        blazeNovaIconForeground: Color,
        blazeNovaTapAction: @escaping () -> Void
    ) -> some View {
        Button(action: blazeNovaTapAction) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(blazeNovaIconBackground)
                        .frame(width: 72, height: 72)

                    Image(blazeNovaSystemImage)
                        .resizable()
                        .frame(width: 32, height: 32)
                }

                Text(blazeNovaTitle)
                    .font(.pulseRobotoRegular(size: 16))
                    .foregroundStyle(Color.chalkPureWhite)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        BurnStageBackdrop()

        Color.black.opacity(0.6)
            .ignoresSafeArea()

        BlazeNovaReportSheet(
            blazeNovaReportAction: {},
            blazeNovaBlockAction: {}
        )
    }
}
