import SwiftUI

struct LiftLoomProfilePage: View {
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub

    private let liftLoomUserStore = NovaPulseUserStore()
    private let liftLoomPostStore = BlazeEchoPostStore()

    @State private var liftLoomCurrentUser: NovaPulseUser?
    @State private var liftLoomPostItems: [BlazeEchoPost] = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                liftLoomHeader
                    .padding(.top, 16)
                    .padding(.horizontal, 18)

                liftLoomProfileSummary
                    .padding(.top, 30)
                    .padding(.horizontal, 12)

                liftLoomStatsCard
                    .padding(.top, 28)
                    .padding(.horizontal, 12)

                liftLoomActionRow
                    .padding(.top, 20)
                    .padding(.horizontal, 12)

                liftLoomPostList
                    .padding(.top, 18)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 120)
            }
        }
        .task {
            liftLoomRefreshProfileData()
        }
        .refreshable {
            liftLoomRefreshProfileData()
        }
    }

    private var liftLoomHeader: some View {
        HStack {
            Spacer()

            Button(action: {
                pulseNovaRouter.pulseNovaPush(.novaDriftSetting)
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.chalkPureWhite)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
        }
    }

    private var liftLoomProfileSummary: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                OrbitNovaSmartImage(
                    orbitNovaImagePath: liftLoomCurrentUser?.novaPulseAvatar ?? ""
                ) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.88), Color.yellow.opacity(0.36)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundStyle(Color.chalkPureWhite)
                        }
                }
                .frame(width: 110, height: 110)
                .clipShape(Circle())

                Button(action: {
                    pulseNovaRouter.pulseNovaPush(.forgeLoomEditProfile)
                }) {
                    Image("TIREGOEditCircle")
                        .resizable()
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .offset(x: -2, y: -3)
            }

            Text(liftLoomDisplayName)
                .font(.pulseRobotoBold(size: 18))
                .foregroundStyle(Color.chalkPureWhite)
        }
    }

    private var liftLoomStatsCard: some View {
        HStack(spacing: 0) {
            liftLoomStatBlock(
                value: "\(liftLoomFollowingCount)",
                title: "Following",
                tapAction: {
                    pulseNovaRouter.pulseNovaPush(.orbitNovaConnectionsFollowing)
                }
            )

            liftLoomStatBlock(
                value: "\(liftLoomFollowerCount)",
                title: "Follower",
                tapAction: {
                    pulseNovaRouter.pulseNovaPush(.orbitNovaConnectionsFollowers)
                }
            )
        }
        .frame(height: 86)
        .background(Color.white.opacity(0.11))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var liftLoomActionRow: some View {
        HStack(spacing: 10) {
            Image("TIREGOCoin")
                .resizable()
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(liftLoomGoldCoinCount)")
                    .font(.pulseRobotoBold(size: 22))
                    .foregroundStyle(Color.chalkJetBlack)

                Text("Gold coin balance")
                    .font(.pulseRobotoRegular(size: 12))
                    .foregroundStyle(Color.chalkInk.opacity(0.72))
            }

            Spacer(minLength: 12)

            PulseActionButton(
                pulseTitle: "Recharge",
                pulseStyle: .flexDark,
                pulseHorizontalPadding: 0,
                pulseWidth: 110,
                pulseHeight: 38,
                pulseLabelFont: .pulseRobotoBold(size: 14),
                pulseTapAction: {
                    pulseNovaRouter.pulseNovaPush(.pulseNovaRecharge)
                }
            )
        }
        .padding(.horizontal, 14)
        .frame(height: 76)
        .frame(maxWidth: .infinity)
        .background(Color.burnSignalYellow)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture {
            pulseNovaRouter.pulseNovaPush(.pulseNovaRecharge)
        }
    }

    private var liftLoomPostList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My posts")
                .font(.flexCarterDisplay(size: 20, relativeTo: .title2))
                .foregroundStyle(Color.burnSignalYellow)

            if liftLoomPostItems.isEmpty {
                liftLoomEmptyPostState
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(liftLoomDisplayPostCards) { liftLoomCard in
                        LiftLoomCoinPostCard(
                            liftLoomImagePath: liftLoomCard.liftLoomImagePath,
                            liftLoomTitle: liftLoomCard.liftLoomTitle,
                            liftLoomAvatarPath: liftLoomCard.liftLoomAvatarPath,
                            liftLoomUserName: liftLoomCard.liftLoomUserName,
                            liftLoomShowsMoreButton: false,
                            liftLoomTapAction: {
                                pulseNovaRouter.pulseNovaPush(
                                    .forgeDriftPostDetail(
                                        forgeDriftPostID: liftLoomCard.id
                                    )
                                )
                            }
                        )
                    }
                }
            }
        }
    }

    private var liftLoomEmptyPostState: some View {
        TirevOxaejjEmptyData()
            .frame(height: 136)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func liftLoomStatBlock(
        value: String,
        title: String,
        tapAction: @escaping () -> Void
    ) -> some View {
        Button(action: tapAction) {
            VStack(spacing: 6) {
                Text(value)
                    .font(.pulseRobotoBold(size: 20))
                    .foregroundStyle(Color.chalkPureWhite)

                Text(title)
                    .font(.pulseRobotoRegular(size: 13))
                    .foregroundStyle(Color.chalkMist.opacity(0.74))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func liftLoomRefreshProfileData() {
        do {
            guard let liftLoomLoggedInUserID = LiftVaultPersistenceStore.liftVaultLoadLoggedInUserID() else {
                liftLoomCurrentUser = nil
                liftLoomPostItems = []
                return
            }

            liftLoomCurrentUser = try liftLoomUserStore.novaPulseFetchUser(
                byID: liftLoomLoggedInUserID
            )

            guard liftLoomCurrentUser != nil else {
                liftLoomPostItems = []
                return
            }

            liftLoomPostItems = try liftLoomPostStore.blazeEchoFetchPosts(
                byPublisherID: liftLoomLoggedInUserID
            )
        } catch {
            liftLoomCurrentUser = nil
            liftLoomPostItems = []
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load profile data right now.",
                style: .error
            )
        }
    }

    private var liftLoomDisplayName: String {
        let liftLoomUserName = liftLoomCurrentUser?.novaPulseUserName
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return liftLoomUserName.isEmpty ? "Profile" : liftLoomUserName
    }

    private var liftLoomFollowingCount: Int {
        liftLoomCurrentUser?.novaPulseFollowingIDs.count ?? 0
    }

    private var liftLoomFollowerCount: Int {
        liftLoomCurrentUser?.novaPulseFollowerIDs.count ?? 0
    }

    private var liftLoomGoldCoinCount: Int {
        liftLoomCurrentUser?.novaPulseGoldCoinCount ?? 0
    }

    private var liftLoomDisplayPostCards: [LiftLoomPostCardItem] {
        let liftLoomUserName = liftLoomDisplayName
        let liftLoomAvatarPath = liftLoomCurrentUser?.novaPulseAvatar ?? ""

        return liftLoomPostItems.map { liftLoomPost in
            LiftLoomPostCardItem(
                id: liftLoomPost.id,
                liftLoomImagePath: liftLoomPost.blazeEchoImageList.first ?? "",
                liftLoomTitle: liftLoomPost.blazeEchoContentText,
                liftLoomAvatarPath: liftLoomAvatarPath,
                liftLoomUserName: liftLoomUserName
            )
        }
    }
}

private struct LiftLoomPostCardItem: Identifiable {
    let id: String
    let liftLoomImagePath: String
    let liftLoomTitle: String
    let liftLoomAvatarPath: String
    let liftLoomUserName: String
}

#Preview {
    LiftLoomProfilePage()
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
        .burnStageBackground()
}
