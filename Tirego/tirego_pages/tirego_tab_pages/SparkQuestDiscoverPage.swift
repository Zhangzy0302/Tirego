import SwiftUI

struct SparkQuestDiscoverPage: View {
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub
    @EnvironmentObject private var vealvjaiAixVisitorGateHub: VealvjaiAixVisitorGateHub
    @EnvironmentObject private var blazeNovaReportSheetHub: BlazeNovaReportSheetHub

    private let sparkQuestPostStore = BlazeEchoPostStore()
    private let sparkQuestUserStore = NovaPulseUserStore()

    @State private var sparkQuestCurrentUser: NovaPulseUser?
    @State private var sparkQuestPostItems: [BlazeEchoPost] = []
    @State private var sparkQuestUserMap: [String: NovaPulseUser] = [:]
    @State private var sparkQuestReportTargetUserID: String?

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topLeading){
                        Text("Discover")
                            .font(.flexCarterDisplay(size: 34, relativeTo: .largeTitle))
                            .foregroundStyle(Color.burnSignalYellow)
                        sparkQuestHeroCard
                            .padding(.top, 22)
                    }.padding(.top, 10)

                    

                    LazyVStack(spacing: 14) {
                        if sparkQuestPostItems.isEmpty {
                            sparkQuestEmptyStateCard
                        } else {
                            ForEach(sparkQuestPostItems) { sparkQuestPost in
                                let sparkQuestPublisher = sparkQuestUserMap[
                                    sparkQuestPost.blazeEchoPublisherID
                                ]

                                LiftLoomCoinPostCard(
                                    liftLoomImagePath: sparkQuestPost.blazeEchoImageList.first ?? "",
                                    liftLoomTitle: sparkQuestPost.blazeEchoContentText,
                                    liftLoomAvatarPath: sparkQuestPublisher?.novaPulseAvatar ?? "",
                                    liftLoomUserName: sparkQuestPublisher?.novaPulseUserName ?? "Unknown",
                                    liftLoomShowsMoreButton: sparkQuestCurrentUser?.id != sparkQuestPost.blazeEchoPublisherID
                                ) {
                                    pulseNovaRouter.pulseNovaPush(
                                        .forgeDriftPostDetail(
                                            forgeDriftPostID: sparkQuestPost.id
                                        )
                                    )
                                } liftLoomMoreTapAction: {
                                    sparkQuestShowReportSheet(
                                        sparkQuestTargetUserID: sparkQuestPost.blazeEchoPublisherID
                                    )
                                }
                            }
                        }
                    }
                    .padding(.top, 18)

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 21)
            }

        }
        .task {
            sparkQuestRefreshDiscoverData()
        }
        .refreshable {
            sparkQuestRefreshDiscoverData()
        }
    }

    private var sparkQuestHeroCard: some View {
        ZStack(alignment: .bottomLeading) {
            
            Image("TIREGODiscoverTopCardBg")
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 108)

            HStack {
                Spacer()

                Image("TIREGOCharacter")
                    .resizable()
                    .frame(width: 146, height: 146)
            }

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Show Your Workout")
                        .font(.pulseRobotoBold(size: 18))
                        .foregroundStyle(Color.chalkJetBlack)
                        .lineLimit(2)

                    Text("Share training moments with the community")
                        .font(.pulseRobotoRegular(size: 10))
                        .foregroundStyle(.black)

                    Text("Share Now")
                        .font(.pulseRobotoBold(size: 12))
                        .foregroundStyle(Color.chalkPureWhite)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.chalkJetBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.top, 4)
                }

                Spacer()
            }
            .padding(.leading, 16)
            .padding(.bottom, 12)
        }
        .onTapGesture {
            if VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser() {
                vealvjaiAixVisitorGateHub.vealvjaiAixShowVisitorAlert()
                return
            }

            pulseNovaRouter.pulseNovaPush(.blazeOrbitPostComposer)
        }
    }

    private var sparkQuestEmptyStateCard: some View {
        TirevOxaejjEmptyData()
            .frame(height: 156)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func sparkQuestShowReportSheet(
        sparkQuestTargetUserID: String
    ) {
        sparkQuestReportTargetUserID = sparkQuestTargetUserID
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

                sparkQuestBlockTargetUser()
            }
        )
    }

    private func sparkQuestRefreshDiscoverData() {
        do {
            let sparkQuestAllUsers = try sparkQuestUserStore.novaPulseFetchAllUsers()
            sparkQuestUserMap = Dictionary(
                uniqueKeysWithValues: sparkQuestAllUsers.map { ($0.id, $0) }
            )

            if let sparkQuestLoggedInUserID = LiftVaultPersistenceStore.liftVaultLoadLoggedInUserID() {
                sparkQuestCurrentUser = sparkQuestUserMap[sparkQuestLoggedInUserID]
            } else {
                sparkQuestCurrentUser = nil
            }

            let sparkQuestBlockedUserIDs = Set(
                sparkQuestCurrentUser?.novaPulseBlockedIDs ?? []
            )

            sparkQuestPostItems = try sparkQuestPostStore
                .blazeEchoFetchAllPosts()
                .filter { !sparkQuestBlockedUserIDs.contains($0.blazeEchoPublisherID) }
        } catch {
            sparkQuestCurrentUser = nil
            sparkQuestPostItems = []
            sparkQuestUserMap = [:]
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load discover posts right now.",
                style: .error
            )
        }
    }

    private func sparkQuestBlockTargetUser() {
        guard let sparkQuestCurrentUserID = sparkQuestCurrentUser?.id,
              let sparkQuestTargetUserID = sparkQuestReportTargetUserID else {
            return
        }

        do {
            let sparkQuestBlockResult = try BlazeNovaBlockCenter.blazeNovaBlockUser(
                currentUserID: sparkQuestCurrentUserID,
                targetUserID: sparkQuestTargetUserID,
                userStore: sparkQuestUserStore
            )
            sparkQuestCurrentUser = sparkQuestBlockResult.blazeNovaCurrentUser

            if sparkQuestBlockResult.blazeNovaWasAlreadyBlocked {
                sparkQuestReportTargetUserID = nil
                sparkQuestRefreshDiscoverData()
                novaPulseFeedbackHub.novaPulseShowToast(
                    "This user is already blocked.",
                    style: .normal
                )
                return
            }

            sparkQuestReportTargetUserID = nil
            sparkQuestRefreshDiscoverData()
            novaPulseFeedbackHub.novaPulseShowToast(
                "User blocked successfully.",
                style: .success
            )
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to block this user right now.",
                style: .error
            )
        }
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        SparkQuestDiscoverPage()
            .burnStageBackground()

        OrbitPulseTabBar(orbitPulseSelectedTab: .constant(.sparkDiscover))
            .padding(.bottom, 22)
    }
    .preferredColorScheme(.dark)
    .environmentObject(PulseNovaRouter())
    .environmentObject(NovaPulseFeedbackHub())
    .environmentObject(VealvjaiAixVisitorGateHub())
    .environmentObject(BlazeNovaReportSheetHub())
}
