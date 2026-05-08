import SwiftUI

struct NovaTrailTabShellPage: View {
    @EnvironmentObject private var vealvjaiAixVisitorGateHub: VealvjaiAixVisitorGateHub
    @State private var novaTrailSelectedTab: OrbitPulseTabBar.OrbitPulseTab = .blazeHome

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch novaTrailSelectedTab {
                case .blazeHome:
                    BlazeOrbitHomePage()
                case .sparkDiscover:
                    SparkQuestDiscoverPage()
                case .echoMessage:
                    EchoDriftMessagePage()
                case .liftProfile:
                    LiftLoomProfilePage()
                }
            }

            OrbitPulseTabBar(
                orbitPulseSelectedTab: $novaTrailSelectedTab,
                orbitPulseTapAction: novaTrailHandleTabTap
            )
                .padding(.bottom, 22)
        }
        .burnStageBackground()
        .preferredColorScheme(.dark)
    }

    private func novaTrailHandleTabTap(
        _ novaTrailTargetTab: OrbitPulseTabBar.OrbitPulseTab
    ) {
        let novaTrailGuestRestrictedTabs: [OrbitPulseTabBar.OrbitPulseTab] = [
            .echoMessage,
            .liftProfile
        ]

        if VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser(),
           novaTrailGuestRestrictedTabs.contains(novaTrailTargetTab) {
            vealvjaiAixVisitorGateHub.vealvjaiAixShowVisitorAlert()
            return
        }

        novaTrailSelectedTab = novaTrailTargetTab
    }
}
