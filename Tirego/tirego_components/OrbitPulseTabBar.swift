import SwiftUI

struct OrbitPulseTabBar: View {
    enum OrbitPulseTab: CaseIterable {
        case blazeHome
        case sparkDiscover
        case echoMessage
        case liftProfile

        var orbitPulseSymbolName: String {
            switch self {
            case .blazeHome:
                return "TIREGONavHome"
            case .sparkDiscover:
                return "TIREGONavDiscover"
            case .echoMessage:
                return "TIREGONavMessage"
            case .liftProfile:
                return "TIREGONavMine"
            }
        }
    }

    @Binding var orbitPulseSelectedTab: OrbitPulseTab
    var orbitPulseTapAction: ((OrbitPulseTab) -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            ForEach(OrbitPulseTab.allCases, id: \.self) { orbitPulseTab in
                Button(action: {
                    if let orbitPulseTapAction {
                        orbitPulseTapAction(orbitPulseTab)
                    } else {
                        orbitPulseSelectedTab = orbitPulseTab
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                orbitPulseSelectedTab == orbitPulseTab
                                ? Color.burnSignalYellow
                                : Color.white.opacity(0.12)
                            )
                            .frame(width: 52, height: 52)

                        Image(orbitPulseTab.orbitPulseSymbolName)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(
                                orbitPulseSelectedTab == orbitPulseTab
                                ? Color.chalkJetBlack
                                : Color.chalkPureWhite
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color.chalkInk.opacity(0.92))
        .clipShape(Capsule())
    }
}

#Preview {
    ZStack {
        Color.flexPitchBlack.ignoresSafeArea()

        OrbitPulseTabBarPreview()
    }
}

private struct OrbitPulseTabBarPreview: View {
    @State private var orbitPulseSelectedTab: OrbitPulseTabBar.OrbitPulseTab = .blazeHome

    var body: some View {
        OrbitPulseTabBar(orbitPulseSelectedTab: $orbitPulseSelectedTab)
    }
}
