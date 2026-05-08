import SwiftUI

extension Color {
    static let burnSignalYellow = Color(red: 251 / 255, green: 230 / 255, blue: 8 / 255)
    static let chalkInk = Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
    static let chalkJetBlack = Color.black
    static let chalkPureWhite = Color.white
    static let chalkSteelGray = Color(red: 229 / 255, green: 229 / 255, blue: 229 / 255)
    static let repPlaceholderGray = Color(red: 102 / 255, green: 102 / 255, blue: 102 / 255)
    static let flexPitchBlack = Color(red: 1 / 255, green: 1 / 255, blue: 1 / 255)
    static let mossAura = Color(red: 66 / 255, green: 67 / 255, blue: 23 / 255)
    static let chalkCloud = Color.white
    static let chalkMist = Color.white.opacity(0.82)
}

struct BurnStageBackdrop: View {
    var body: some View {
        GeometryReader { burnFrame in
            ZStack(alignment: .topTrailing) {
                Color.flexPitchBlack

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [.mossAura, .mossAura.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: max(burnFrame.size.width, burnFrame.size.height) * 0.65
                        )
                    )
                    .frame(
                        width: burnFrame.size.width * 1.0827,
                        height: burnFrame.size.height * 0.5
                    )
                    .offset(
                        x: burnFrame.size.width * 0.24,
                        y: -burnFrame.size.height * 0.18
                    ).blur(radius: 80)
            }
            .ignoresSafeArea()
        }
    }
}

struct BurnStageBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(BurnStageBackdrop())
    }
}

extension View {
    func burnStageBackground() -> some View {
        modifier(BurnStageBackgroundModifier())
    }
}
