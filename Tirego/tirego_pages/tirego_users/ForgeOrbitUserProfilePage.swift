import SwiftUI

struct ForgeOrbitUserProfilePage: View {
    @Environment(\.dismiss) private var forgeOrbitDismiss
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub
    @EnvironmentObject private var vealvjaiAixVisitorGateHub: VealvjaiAixVisitorGateHub
    @EnvironmentObject private var blazeNovaReportSheetHub: BlazeNovaReportSheetHub

    enum ForgeOrbitFollowMode {
        case readyToFollow
        case followed

        var forgeOrbitButtonTitle: String {
            switch self {
            case .readyToFollow:
                return "+ Follow"
            case .followed:
                return "Followed"
            }
        }

        var forgeOrbitBackgroundColor: Color {
            switch self {
            case .readyToFollow:
                return .burnSignalYellow
            case .followed:
                return Color.white.opacity(0.11)
            }
        }

        var forgeOrbitForegroundColor: Color {
            switch self {
            case .readyToFollow:
                return .chalkJetBlack
            case .followed:
                return .chalkMist
            }
        }
    }

    private let forgeOrbitUserStore = NovaPulseUserStore()
    private let forgeOrbitPostStore = BlazeEchoPostStore()
    private let forgeOrbitChatRoomStore = EchoNovaChatRoomStore()
    let forgeOrbitUserID: String

    @State private var forgeOrbitCurrentUser: NovaPulseUser?
    @State private var forgeOrbitViewedUser: NovaPulseUser?
    @State private var forgeOrbitPostItems: [BlazeEchoPost] = []
    @State private var forgeOrbitFollowMode: ForgeOrbitFollowMode = .readyToFollow
    @State private var forgeOrbitShowsChatAlert = false

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    forgeOrbitProfileHeader
                        .padding(.top, 80)

                    forgeOrbitStatsCard
                        .padding(.top, 24)

                    forgeOrbitActionRow
                        .padding(.top, 22)

                    forgeOrbitPostList
                        .padding(.top, 26)

                    Spacer(minLength: 110)
                }
                .padding(.horizontal, 14)
            }
            .burnStageBackground()
            .preferredColorScheme(.dark)
            .task {
                forgeOrbitRefreshProfileData()
            }
            .refreshable {
                forgeOrbitRefreshProfileData()
            }

            forgeOrbitHeaderBar
                .padding(.top, 16)
                .padding(.horizontal, 20)

            if forgeOrbitShowsChatAlert {
                ZStack{
                    Color.black.opacity(0.68)
                        .ignoresSafeArea()
                        .onTapGesture {
                            forgeOrbitShowsChatAlert = false
                        }

                    OixhbiAeicChatAlert(
                        oixhbiAeicConfirmAction: {
                            forgeOrbitShowsChatAlert = false
                        },
                        oixhbiAeicCloseAction: {
                            forgeOrbitShowsChatAlert = false
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
                
            }
        }
        .animation(.easeInOut(duration: 0.2), value: forgeOrbitShowsChatAlert)
        .background(ForgeTrailSwipeBackEnabler())
    }

    private var forgeOrbitHeaderBar: some View {
        HStack {
            Button(action: {
                forgeOrbitDismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.chalkPureWhite)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            if forgeOrbitViewedUser?.id != forgeOrbitCurrentUser?.id {
                Button(action: {
                    forgeOrbitShowReportSheet()
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.chalkPureWhite)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var forgeOrbitProfileHeader: some View {
        VStack(spacing: 12) {
            OrbitNovaSmartImage(
                orbitNovaImagePath: forgeOrbitViewedUser?.novaPulseAvatar ?? ""
            ) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.88), Color.black],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 46))
                            .foregroundStyle(Color.chalkPureWhite.opacity(0.92))
                    }
            }
            .frame(width: 108, height: 108)
            .clipShape(Circle())

            Text(forgeOrbitDisplayName)
                .font(.pulseRobotoBold(size: 30))
                .foregroundStyle(Color.chalkPureWhite)
        }
        .frame(maxWidth: .infinity)
    }

    private var forgeOrbitStatsCard: some View {
        HStack {
            forgeOrbitStatBlock(
                value: "\(forgeOrbitFollowingCount)",
                title: "Following"
            )

            Spacer()

            forgeOrbitStatBlock(
                value: "\(forgeOrbitFollowerCount)",
                title: "Follower"
            )
        }
        .padding(.horizontal, 64)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.11))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var forgeOrbitActionRow: some View {
        Group {
            if forgeOrbitViewedUser?.id != forgeOrbitCurrentUser?.id {
                HStack(spacing: 12) {
                    Button(action: forgeOrbitToggleFollowState) {
                        Text(forgeOrbitFollowMode.forgeOrbitButtonTitle)
                            .font(.pulseRobotoBold(size: 16))
                            .foregroundStyle(forgeOrbitFollowMode.forgeOrbitForegroundColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(forgeOrbitFollowMode.forgeOrbitBackgroundColor)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        if VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser() {
                            vealvjaiAixVisitorGateHub.vealvjaiAixShowVisitorAlert()
                            return
                        }

                        guard forgeOrbitCanOpenChat else {
                            forgeOrbitShowsChatAlert = true
                            return
                        }

                        forgeOrbitOpenChatRoom()
                    }) {
                        HStack(spacing: 8) {
                            Image("TIREGONavMessage")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(.black)
                                .frame(width: 24, height: 24)

                            Text("Chat")
                                .font(.pulseRobotoBold(size: 16))
                                .foregroundStyle(Color.chalkJetBlack)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.chalkPureWhite)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var forgeOrbitPostList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Posts")
                .font(.flexCarterDisplay(size: 20, relativeTo: .title2))
                .foregroundStyle(Color.burnSignalYellow)

            if forgeOrbitPostItems.isEmpty {
                forgeOrbitEmptyPostState
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(forgeOrbitPostItems) { forgeOrbitPost in
                        LiftLoomCoinPostCard(
                            liftLoomImagePath: forgeOrbitPost.blazeEchoImageList.first ?? "",
                            liftLoomTitle: forgeOrbitPost.blazeEchoContentText,
                            liftLoomAvatarPath: forgeOrbitViewedUser?.novaPulseAvatar ?? "",
                            liftLoomUserName: forgeOrbitDisplayName,
                            liftLoomShowsMoreButton: forgeOrbitViewedUser?.id != forgeOrbitCurrentUser?.id,
                            liftLoomTapAction: {
                                pulseNovaRouter.pulseNovaPush(
                                    .forgeDriftPostDetail(
                                        forgeDriftPostID: forgeOrbitPost.id
                                    )
                                )
                            },
                            liftLoomMoreTapAction: {
                                forgeOrbitShowReportSheet()
                            }
                        )
                    }
                }
            }
        }
    }

    private var forgeOrbitEmptyPostState: some View {
        TirevOxaejjEmptyData()
            .frame(height: 136)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func forgeOrbitStatBlock(value: String, title: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.pulseRobotoBold(size: 26))
                .foregroundStyle(Color.chalkPureWhite)

            Text(title)
                .font(.pulseRobotoRegular(size: 12))
                .foregroundStyle(Color.chalkMist)
        }
    }

    private func forgeOrbitRefreshProfileData() {
        do {
            let forgeOrbitViewedUser = try forgeOrbitUserStore.novaPulseFetchUser(
                byID: forgeOrbitUserID
            )
            let forgeOrbitLoggedInUserID = LiftVaultPersistenceStore.liftVaultLoadLoggedInUserID()

            if let forgeOrbitLoggedInUserID {
                forgeOrbitCurrentUser = try forgeOrbitUserStore.novaPulseFetchUser(
                    byID: forgeOrbitLoggedInUserID
                )
            } else {
                forgeOrbitCurrentUser = nil
            }

            self.forgeOrbitViewedUser = forgeOrbitViewedUser
            forgeOrbitPostItems = try forgeOrbitPostStore.blazeEchoFetchPosts(
                byPublisherID: forgeOrbitUserID
            )

            forgeOrbitFollowMode = forgeOrbitCurrentUser?.novaPulseFollowingIDs.contains(
                forgeOrbitUserID
            ) == true ? .followed : .readyToFollow

            if forgeOrbitViewedUser == nil {
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Unable to load this user right now.",
                    style: .error
                )
            }
        } catch {
            forgeOrbitCurrentUser = nil
            forgeOrbitViewedUser = nil
            forgeOrbitPostItems = []
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load this user right now.",
                style: .error
            )
        }
    }

    private func forgeOrbitOpenChatRoom() {
        do {
            guard let forgeOrbitCurrentUser,
                  let forgeOrbitViewedUser else {
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Unable to open chat right now.",
                    style: .error
                )
                return
            }

            if let forgeOrbitExistingRoom = try forgeOrbitChatRoomStore
                .echoNovaFetchChatRoom(
                    byMemberUserIDs: [
                        forgeOrbitCurrentUser.id,
                        forgeOrbitViewedUser.id
                    ]
                ) {
                pulseNovaRouter.pulseNovaPush(
                    .orbitEchoChatRoom(
                        orbitEchoChatRoomID: forgeOrbitExistingRoom.id
                    )
                )
                return
            }

            let forgeOrbitNewRoom = EchoNovaChatRoom(
                id: UUID().uuidString,
                echoNovaMemberUserIDs: [
                    forgeOrbitCurrentUser.id,
                    forgeOrbitViewedUser.id
                ],
                echoNovaLastMessageSentAt: Date(),
                echoNovaLastSenderUserID: "",
                echoNovaLastMessageText: "",
                echoNovaUnreadMessageCount: 0
            )

            try forgeOrbitChatRoomStore.echoNovaCreateChatRoom(
                forgeOrbitNewRoom
            )

            pulseNovaRouter.pulseNovaPush(
                .orbitEchoChatRoom(
                    orbitEchoChatRoomID: forgeOrbitNewRoom.id
                )
            )
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to open chat right now.",
                style: .error
            )
        }
    }

    private var forgeOrbitCanOpenChat: Bool {
        guard let forgeOrbitCurrentUser,
              let forgeOrbitViewedUser else {
            return false
        }

        let forgeOrbitCurrentFollowsViewed = forgeOrbitCurrentUser
            .novaPulseFollowingIDs
            .contains(forgeOrbitViewedUser.id)
        let forgeOrbitViewedFollowsCurrent = forgeOrbitViewedUser
            .novaPulseFollowingIDs
            .contains(forgeOrbitCurrentUser.id)

        return forgeOrbitCurrentFollowsViewed && forgeOrbitViewedFollowsCurrent
    }

    private func forgeOrbitToggleFollowState() {
        if VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser() {
            vealvjaiAixVisitorGateHub.vealvjaiAixShowVisitorAlert()
            return
        }

        guard var forgeOrbitCurrentUser else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please sign in first.",
                style: .error
            )
            return
        }

        guard forgeOrbitCurrentUser.id != forgeOrbitUserID else {
            return
        }

        guard var forgeOrbitViewedUser else {
            return
        }

        if let forgeOrbitIndex = forgeOrbitCurrentUser.novaPulseFollowingIDs.firstIndex(of: forgeOrbitUserID) {
            forgeOrbitCurrentUser.novaPulseFollowingIDs.remove(at: forgeOrbitIndex)
            forgeOrbitViewedUser.novaPulseFollowerIDs.removeAll { $0 == forgeOrbitCurrentUser.id }
            forgeOrbitFollowMode = .readyToFollow
        } else {
            forgeOrbitCurrentUser.novaPulseFollowingIDs.append(forgeOrbitUserID)
            if !forgeOrbitViewedUser.novaPulseFollowerIDs.contains(forgeOrbitCurrentUser.id) {
                forgeOrbitViewedUser.novaPulseFollowerIDs.append(forgeOrbitCurrentUser.id)
            }
            forgeOrbitFollowMode = .followed
        }

        do {
            try forgeOrbitUserStore.novaPulseUpdateUser(forgeOrbitCurrentUser)
            try forgeOrbitUserStore.novaPulseUpdateUser(forgeOrbitViewedUser)
            self.forgeOrbitCurrentUser = forgeOrbitCurrentUser
            self.forgeOrbitViewedUser = forgeOrbitViewedUser
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to update follow state right now.",
                style: .error
            )
        }
    }

    private func forgeOrbitBlockViewedUser() {
        guard let forgeOrbitCurrentUserID = forgeOrbitCurrentUser?.id,
              let forgeOrbitViewedUserID = forgeOrbitViewedUser?.id else {
            return
        }

        do {
            let forgeOrbitBlockResult = try BlazeNovaBlockCenter.blazeNovaBlockUser(
                currentUserID: forgeOrbitCurrentUserID,
                targetUserID: forgeOrbitViewedUserID,
                userStore: forgeOrbitUserStore
            )
            self.forgeOrbitCurrentUser = forgeOrbitBlockResult.blazeNovaCurrentUser

            if forgeOrbitBlockResult.blazeNovaWasAlreadyBlocked {
                novaPulseFeedbackHub.novaPulseShowToast(
                    "This user is already blocked.",
                    style: .normal
                )
                pulseNovaRouter.pulseNovaPopToRoot()
                return
            }

            novaPulseFeedbackHub.novaPulseShowToast(
                "User blocked successfully.",
                style: .success
            )
            pulseNovaRouter.pulseNovaPopToRoot()
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to block this user right now.",
                style: .error
            )
        }
    }

    private func forgeOrbitShowReportSheet() {
        blazeNovaReportSheetHub.blazeNovaShowReportSheet(
            blazeNovaReportAction: {
                if VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser() {
                    vealvjaiAixVisitorGateHub.vealvjaiAixShowVisitorAlert()
                    return
                }

                pulseNovaRouter.pulseNovaPush(.orbitPulseReport)
            },
            blazeNovaBlockAction: {
                if VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser() {
                    vealvjaiAixVisitorGateHub.vealvjaiAixShowVisitorAlert()
                    return
                }

                forgeOrbitBlockViewedUser()
            }
        )
    }

    private var forgeOrbitDisplayName: String {
        let forgeOrbitUserName = forgeOrbitViewedUser?.novaPulseUserName
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return forgeOrbitUserName.isEmpty ? "Unknown User" : forgeOrbitUserName
    }

    private var forgeOrbitFollowingCount: Int {
        forgeOrbitViewedUser?.novaPulseFollowingIDs.count ?? 0
    }

    private var forgeOrbitFollowerCount: Int {
        forgeOrbitViewedUser?.novaPulseFollowerIDs.count ?? 0
    }
}

#Preview {
    ForgeOrbitUserProfilePage(forgeOrbitUserID: "user_002")
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
        .environmentObject(VealvjaiAixVisitorGateHub())
        .environmentObject(BlazeNovaReportSheetHub())
}
