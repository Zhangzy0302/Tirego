import SwiftUI
import Combine

enum OrbitForgeRoute: Hashable {
    case novaTrailWelcomeGate
    case forgePulseAuthSignIn
    case forgePulseAuthSignUp
    case forgePulseAuthForgotPassword
    case blazeOrbitProfileSetup(
        blazeOrbitEmail: String = "",
        blazeOrbitPassword: String = ""
    )
    case orbitNovaWebPortal(
        orbitNovaURLString: String,
        orbitNovaTitle: String? = nil
    )
    case novaTrailTabShell
    case blazeOrbitHome
    case sparkQuestDiscover
    case echoDriftMessage
    case liftLoomProfile
    case blazeOrbitPostComposer
    case forgeDriftPostDetail(forgeDriftPostID: String)
    case forgePulseTutorialDetail(forgePulseTutorialID: String)
    case orbitEchoChatRoom(orbitEchoChatRoomID: String)
    case forgeOrbitUserProfile(forgeOrbitUserID: String)
    case orbitPulseReport
    case novaDriftSetting
    case forgeLoomEditProfile
    case pulseNovaRecharge
    case orbitNovaConnectionsFollowing
    case orbitNovaConnectionsFollowers
    case orbitNovaConnectionsBlocklist
}

@MainActor
final class PulseNovaRouter: ObservableObject {
    @Published var pulseNovaRootRoute: OrbitForgeRoute
    @Published var pulseNovaPath: [OrbitForgeRoute]

    static var pulseNovaDefaultRootRoute: OrbitForgeRoute {
        let pulseNovaLoggedInUserID = LiftVaultPersistenceStore
            .liftVaultLoadLoggedInUserID()?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let pulseNovaLoggedInUserID,
           !pulseNovaLoggedInUserID.isEmpty {
            return .novaTrailTabShell
        }

        return .novaTrailWelcomeGate
    }

    init(
        pulseNovaRootRoute: OrbitForgeRoute? = nil,
        pulseNovaPath: [OrbitForgeRoute] = []
    ) {
        self.pulseNovaRootRoute = pulseNovaRootRoute ?? PulseNovaRouter.pulseNovaDefaultRootRoute
        self.pulseNovaPath = pulseNovaPath
    }

    func pulseNovaPush(_ pulseNovaRoute: OrbitForgeRoute) {
        pulseNovaPath.append(pulseNovaRoute)
    }

    func pulseNovaPop() {
        guard !pulseNovaPath.isEmpty else {
            return
        }

        pulseNovaPath.removeLast()
    }

    func pulseNovaPopToRoot() {
        pulseNovaPath.removeAll()
    }

    func pulseNovaReplaceTop(with pulseNovaRoute: OrbitForgeRoute) {
        if pulseNovaPath.isEmpty {
            pulseNovaPath = [pulseNovaRoute]
            return
        }

        pulseNovaPath.removeLast()

        DispatchQueue.main.async { [weak self] in
            self?.pulseNovaPath.append(pulseNovaRoute)
        }
    }

    func pulseNovaPresent(_ pulseNovaRoute: OrbitForgeRoute) {
        let pulseNovaHasPath = !pulseNovaPath.isEmpty

        if pulseNovaHasPath {
            pulseNovaPath.removeAll()
        }

        DispatchQueue.main.async { [weak self] in
            self?.pulseNovaRootRoute = pulseNovaRoute
        }
    }

    func pulseNovaReset(to pulseNovaRoute: OrbitForgeRoute) {
        pulseNovaPresent(pulseNovaRoute)
    }
}

struct ForgeTrailNavigationHost: View {
    @StateObject private var pulseNovaRouter = PulseNovaRouter()
    @StateObject private var vealvjaiAixVisitorGateHub = VealvjaiAixVisitorGateHub()
    @StateObject private var blazeNovaReportSheetHub = BlazeNovaReportSheetHub()

    var body: some View {
        ZStack {
            NavigationStack(path: $pulseNovaRouter.pulseNovaPath) {
                OrbitForgeRouteView(orbitForgeRoute: pulseNovaRouter.pulseNovaRootRoute)
                    .navigationBarBackButtonHidden(true)
                    .navigationDestination(for: OrbitForgeRoute.self) { orbitForgeRoute in
                        OrbitForgeRouteView(orbitForgeRoute: orbitForgeRoute)
                            .navigationBarBackButtonHidden(true)
                    }
            }
            .environmentObject(pulseNovaRouter)
            .environmentObject(vealvjaiAixVisitorGateHub)
            .environmentObject(blazeNovaReportSheetHub)

            if vealvjaiAixVisitorGateHub.vealvjaiAixShowsVisitorAlert {
                Color.black.opacity(0.56)
                    .ignoresSafeArea()
                    .onTapGesture {
                        vealvjaiAixVisitorGateHub.vealvjaiAixHideVisitorAlert()
                    }

                VealvjaiAixVisitorAlert(
                    vealvjaiAixMessage: vealvjaiAixVisitorGateHub.vealvjaiAixMessage,
                    vealvjaiAixLoginAction: {
                        vealvjaiAixVisitorGateHub.vealvjaiAixHideVisitorAlert()
                        pulseNovaRouter.pulseNovaPush(.forgePulseAuthSignIn)
                    },
                    vealvjaiAixCloseAction: {
                        vealvjaiAixVisitorGateHub.vealvjaiAixHideVisitorAlert()
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                .zIndex(10)
            }

            if blazeNovaReportSheetHub.blazeNovaShowsReportSheet {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        blazeNovaReportSheetHub.blazeNovaHideReportSheet()
                    }
                    .zIndex(11)

                BlazeNovaReportSheet(
                    blazeNovaReportAction: {
                        blazeNovaReportSheetHub.blazeNovaHandleReportAction()
                    },
                    blazeNovaBlockAction: {
                        blazeNovaReportSheetHub.blazeNovaHandleBlockAction()
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(12)
            }
        }
    }
}

private struct OrbitForgeRouteView: View {
    let orbitForgeRoute: OrbitForgeRoute

    var body: some View {
        switch orbitForgeRoute {
        case .novaTrailWelcomeGate:
            NovaTrailWelcomeGatePage()
        case .forgePulseAuthSignIn:
            ForgePulseAuthPortalPage(forgePulseMode: .signIn)
        case .forgePulseAuthSignUp:
            ForgePulseAuthPortalPage(forgePulseMode: .signUp)
        case .forgePulseAuthForgotPassword:
            ForgePulseAuthPortalPage(forgePulseMode: .forgotPassword)
        case let .blazeOrbitProfileSetup(blazeOrbitEmail, blazeOrbitPassword):
            BlazeOrbitProfileSetupPage(
                blazeOrbitEmail: blazeOrbitEmail,
                blazeOrbitPassword: blazeOrbitPassword
            )
        case let .orbitNovaWebPortal(orbitNovaURLString, orbitNovaTitle):
            OrbitNovaWebPortalPage(
                orbitNovaURLString: orbitNovaURLString,
                orbitNovaTitle: orbitNovaTitle
            )
        case .novaTrailTabShell:
            NovaTrailTabShellPage()
        case .blazeOrbitHome:
            BlazeOrbitHomePage()
        case .sparkQuestDiscover:
            SparkQuestDiscoverPage()
        case .echoDriftMessage:
            EchoDriftMessagePage()
        case .liftLoomProfile:
            LiftLoomProfilePage()
        case .blazeOrbitPostComposer:
            BlazeOrbitPostComposerPage()
        case let .forgeDriftPostDetail(forgeDriftPostID):
            ForgeDriftPostDetailPage(
                forgeDriftPostID: forgeDriftPostID
            )
        case let .forgePulseTutorialDetail(forgePulseTutorialID):
            ForgePulseTutorialDetailPage(
                forgePulseTutorialID: forgePulseTutorialID
            )
        case let .orbitEchoChatRoom(orbitEchoChatRoomID):
            OrbitEchoChatRoomPage(
                orbitEchoChatRoomID: orbitEchoChatRoomID
            )
        case let .forgeOrbitUserProfile(forgeOrbitUserID):
            ForgeOrbitUserProfilePage(
                forgeOrbitUserID: forgeOrbitUserID
            )
        case .orbitPulseReport:
            OrbitPulseReportPage()
        case .novaDriftSetting:
            NovaDriftSettingPage()
        case .forgeLoomEditProfile:
            ForgeLoomEditProfilePage()
        case .pulseNovaRecharge:
            PulseNovaRechargePage()
        case .orbitNovaConnectionsFollowing:
            OrbitNovaConnectionPage(orbitNovaMode: .following)
        case .orbitNovaConnectionsFollowers:
            OrbitNovaConnectionPage(orbitNovaMode: .followers)
        case .orbitNovaConnectionsBlocklist:
            OrbitNovaConnectionPage(orbitNovaMode: .blocklist)
        }
    }
}

#Preview {
    ForgeTrailNavigationHost()
}
