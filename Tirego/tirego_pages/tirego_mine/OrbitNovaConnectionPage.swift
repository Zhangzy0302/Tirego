import SwiftUI

struct OrbitNovaConnectionPage: View {
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub

    enum OrbitNovaConnectionMode {
        case followers
        case following
        case blocklist

        var orbitNovaTitle: String {
            switch self {
            case .following:
                return "Following"
            case .followers:
                return "Followers"
            case .blocklist:
                return "Blocklist"
            }
        }

    }

    private let orbitNovaMode: OrbitNovaConnectionMode
    private let orbitNovaUserStore = NovaPulseUserStore()

    @State private var orbitNovaCurrentUser: NovaPulseUser?
    @State private var orbitNovaUsers: [OrbitNovaUserRow] = []

    init(orbitNovaMode: OrbitNovaConnectionMode) {
        self.orbitNovaMode = orbitNovaMode
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BlazeOrbitTopBar(blazeOrbitTitle: orbitNovaMode.orbitNovaTitle)
                .padding(.top, 16)
                .padding(.horizontal, 18)

            if orbitNovaUsers.isEmpty {
                orbitNovaEmptyState
                    .padding(.top, 28)
                    .padding(.horizontal, 20)
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(orbitNovaUsers) { orbitNovaUser in
                        OrbitNovaConnectionRow(
                            orbitNovaUser: orbitNovaUser,
                            orbitNovaActionTap: {
                                orbitNovaHandleActionTap(
                                    orbitNovaUserID: orbitNovaUser.id
                                )
                            }
                        )
                    }
                }
                .padding(.top, 28)
                .padding(.horizontal, 20)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .burnStageBackground()
        .preferredColorScheme(.dark)
        .task {
            orbitNovaRefreshUsers()
        }
        .refreshable {
            orbitNovaRefreshUsers()
        }
    }

    private var orbitNovaEmptyState: some View {
        TirevOxaejjEmptyData()
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.vertical, 28)
        .background(Color.white.opacity(0.09))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func orbitNovaRefreshUsers() {
        do {
            guard let orbitNovaLoggedInUserID = LiftVaultPersistenceStore
                .liftVaultLoadLoggedInUserID()?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !orbitNovaLoggedInUserID.isEmpty,
                let orbitNovaCurrentUser = try orbitNovaUserStore.novaPulseFetchUser(
                    byID: orbitNovaLoggedInUserID
                ) else {
                orbitNovaCurrentUser = nil
                orbitNovaUsers = []
                return
            }

            self.orbitNovaCurrentUser = orbitNovaCurrentUser

            let orbitNovaTargetUserIDs: [String]
            switch orbitNovaMode {
            case .following:
                orbitNovaTargetUserIDs = orbitNovaCurrentUser.novaPulseFollowingIDs
            case .followers:
                orbitNovaTargetUserIDs = orbitNovaCurrentUser.novaPulseFollowerIDs
            case .blocklist:
                orbitNovaTargetUserIDs = orbitNovaCurrentUser.novaPulseBlockedIDs
            }

            orbitNovaUsers = try orbitNovaTargetUserIDs.compactMap { orbitNovaUserID in
                guard let orbitNovaUser = try orbitNovaUserStore.novaPulseFetchUser(byID: orbitNovaUserID) else {
                    return nil
                }

                return OrbitNovaUserRow(
                    id: orbitNovaUser.id,
                    orbitNovaName: orbitNovaResolvedDisplayName(for: orbitNovaUser),
                    orbitNovaAvatarPath: orbitNovaUser.novaPulseAvatar,
                    orbitNovaActionTitle: orbitNovaActionTitle(
                        for: orbitNovaUser,
                        currentUser: orbitNovaCurrentUser
                    ),
                    orbitNovaActionBackground: orbitNovaActionBackground(
                        for: orbitNovaUser,
                        currentUser: orbitNovaCurrentUser
                    ),
                    orbitNovaActionForeground: orbitNovaActionForeground(
                        for: orbitNovaUser,
                        currentUser: orbitNovaCurrentUser
                    )
                )
            }
        } catch {
            orbitNovaCurrentUser = nil
            orbitNovaUsers = []
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load this list right now.",
                style: .error
            )
        }
    }

    private func orbitNovaResolvedDisplayName(
        for orbitNovaUser: NovaPulseUser
    ) -> String {
        let orbitNovaTrimmedName = orbitNovaUser.novaPulseUserName
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return orbitNovaTrimmedName.isEmpty ? "Unknown User" : orbitNovaTrimmedName
    }

    private func orbitNovaActionTitle(
        for orbitNovaUser: NovaPulseUser,
        currentUser orbitNovaCurrentUser: NovaPulseUser
    ) -> String {
        switch orbitNovaMode {
        case .following:
            return "Followed"
        case .followers:
            return orbitNovaCurrentUser.novaPulseFollowingIDs.contains(orbitNovaUser.id)
            ? "Followed"
            : "+ Follow"
        case .blocklist:
            return "Remove"
        }
    }

    private func orbitNovaActionBackground(
        for orbitNovaUser: NovaPulseUser,
        currentUser orbitNovaCurrentUser: NovaPulseUser
    ) -> Color {
        switch orbitNovaMode {
        case .following:
            return Color.white.opacity(0.14)
        case .followers:
            return orbitNovaCurrentUser.novaPulseFollowingIDs.contains(orbitNovaUser.id)
            ? Color.white.opacity(0.14)
            : .burnSignalYellow
        case .blocklist:
            return .chalkPureWhite
        }
    }

    private func orbitNovaActionForeground(
        for orbitNovaUser: NovaPulseUser,
        currentUser orbitNovaCurrentUser: NovaPulseUser
    ) -> Color {
        switch orbitNovaMode {
        case .following:
            return .chalkPureWhite.opacity(0.92)
        case .followers:
            return orbitNovaCurrentUser.novaPulseFollowingIDs.contains(orbitNovaUser.id)
            ? .chalkPureWhite.opacity(0.92)
            : .chalkJetBlack
        case .blocklist:
            return .chalkJetBlack
        }
    }

    private func orbitNovaHandleActionTap(
        orbitNovaUserID: String
    ) {
        guard !VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser() else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please sign in first.",
                style: .error
            )
            return
        }

        guard var orbitNovaCurrentUser else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Current user not found.",
                style: .error
            )
            return
        }

        do {
            switch orbitNovaMode {
            case .following:
                guard var orbitNovaTargetUser = try orbitNovaUserStore
                    .novaPulseFetchUser(byID: orbitNovaUserID) else {
                    throw PulseCacheStoreError.pulseCacheItemNotFound
                }

                orbitNovaCurrentUser.novaPulseFollowingIDs.removeAll {
                    $0 == orbitNovaUserID
                }
                orbitNovaTargetUser.novaPulseFollowerIDs.removeAll {
                    $0 == orbitNovaCurrentUser.id
                }

                try orbitNovaUserStore.novaPulseUpdateUser(orbitNovaCurrentUser)
                try orbitNovaUserStore.novaPulseUpdateUser(orbitNovaTargetUser)
                self.orbitNovaCurrentUser = orbitNovaCurrentUser
                orbitNovaRefreshUsers()
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Unfollowed successfully.",
                    style: .success
                )

            case .followers:
                guard var orbitNovaTargetUser = try orbitNovaUserStore
                    .novaPulseFetchUser(byID: orbitNovaUserID) else {
                    throw PulseCacheStoreError.pulseCacheItemNotFound
                }

                if orbitNovaCurrentUser.novaPulseFollowingIDs.contains(orbitNovaUserID) {
                    orbitNovaCurrentUser.novaPulseFollowingIDs.removeAll {
                        $0 == orbitNovaUserID
                    }
                    orbitNovaTargetUser.novaPulseFollowerIDs.removeAll {
                        $0 == orbitNovaCurrentUser.id
                    }

                    try orbitNovaUserStore.novaPulseUpdateUser(orbitNovaCurrentUser)
                    try orbitNovaUserStore.novaPulseUpdateUser(orbitNovaTargetUser)
                    self.orbitNovaCurrentUser = orbitNovaCurrentUser
                    orbitNovaRefreshUsers()
                    novaPulseFeedbackHub.novaPulseShowToast(
                        "Unfollowed successfully.",
                        style: .success
                    )
                } else {
                    orbitNovaCurrentUser.novaPulseFollowingIDs.append(orbitNovaUserID)
                    if !orbitNovaTargetUser.novaPulseFollowerIDs.contains(orbitNovaCurrentUser.id) {
                        orbitNovaTargetUser.novaPulseFollowerIDs.append(orbitNovaCurrentUser.id)
                    }

                    try orbitNovaUserStore.novaPulseUpdateUser(orbitNovaCurrentUser)
                    try orbitNovaUserStore.novaPulseUpdateUser(orbitNovaTargetUser)
                    self.orbitNovaCurrentUser = orbitNovaCurrentUser
                    orbitNovaRefreshUsers()
                    novaPulseFeedbackHub.novaPulseShowToast(
                        "Followed successfully.",
                        style: .success
                    )
                }

            case .blocklist:
                orbitNovaCurrentUser.novaPulseBlockedIDs.removeAll {
                    $0 == orbitNovaUserID
                }

                try orbitNovaUserStore.novaPulseUpdateUser(orbitNovaCurrentUser)
                self.orbitNovaCurrentUser = orbitNovaCurrentUser
                orbitNovaRefreshUsers()
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Removed from blacklist.",
                    style: .success
                )
            }
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to update this user right now.",
                style: .error
            )
        }
    }
}

private struct OrbitNovaUserRow: Identifiable {
    let id: String
    let orbitNovaName: String
    let orbitNovaAvatarPath: String
    let orbitNovaActionTitle: String
    let orbitNovaActionBackground: Color
    let orbitNovaActionForeground: Color
}

private struct OrbitNovaConnectionRow: View {
    let orbitNovaUser: OrbitNovaUserRow
    let orbitNovaActionTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            OrbitNovaSmartImage(
                orbitNovaImagePath: orbitNovaUser.orbitNovaAvatarPath
            ) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.84), Color.black],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.chalkPureWhite)
                    }
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            Text(orbitNovaUser.orbitNovaName)
                .font(.pulseRobotoBold(size: 16))
                .foregroundStyle(Color.chalkPureWhite)

            Spacer()

            Button(action: orbitNovaActionTap) {
                Text(orbitNovaUser.orbitNovaActionTitle)
                    .font(.pulseRobotoBold(size: 11))
                    .foregroundStyle(orbitNovaUser.orbitNovaActionForeground)
                    .padding(.horizontal, orbitNovaUser.orbitNovaActionTitle == "Remove" ? 14 : 12)
                    .frame(height: 28)
                    .background(orbitNovaUser.orbitNovaActionBackground)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview("Following") {
    OrbitNovaConnectionPage(orbitNovaMode: .following)
        .environmentObject(NovaPulseFeedbackHub())
}

#Preview("Followers") {
    OrbitNovaConnectionPage(orbitNovaMode: .followers)
        .environmentObject(NovaPulseFeedbackHub())
}

#Preview("Blocklist") {
    OrbitNovaConnectionPage(orbitNovaMode: .blocklist)
        .environmentObject(NovaPulseFeedbackHub())
}
