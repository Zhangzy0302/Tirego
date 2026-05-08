import SwiftUI

struct EchoDriftMessagePage: View {
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub

    private let echoDriftUserStore = NovaPulseUserStore()
    private let echoDriftChatRoomStore = EchoNovaChatRoomStore()

    @State private var echoDriftCurrentUser: NovaPulseUser?
    @State private var echoDriftChatRows: [EchoDriftChatRow] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Message")
                .font(.flexCarterDisplay(size: 34, relativeTo: .largeTitle))
                .foregroundStyle(Color.burnSignalYellow)
                .padding(.top, 18)

            if echoDriftChatRows.isEmpty {
                echoDriftEmptyState
                    .padding(.top, 28)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(echoDriftChatRows) { echoDriftMessage in
                        EchoDriftMessageCard(echoDriftMessage: echoDriftMessage)
                    }
                }
                .padding(.top, 20)
            }

            Spacer(minLength: 120)
        }
        .padding(.horizontal, 21)
        .task {
            echoDriftRefreshChatRooms()
        }
        .refreshable {
            echoDriftRefreshChatRooms()
        }
    }

    private var echoDriftEmptyState: some View {
        TirevOxaejjEmptyData()
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .padding(.vertical, 28)
        .background(Color.white.opacity(0.09))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func echoDriftRefreshChatRooms() {
        do {
            guard let echoDriftLoggedInUserID = LiftVaultPersistenceStore
                .liftVaultLoadLoggedInUserID()?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !echoDriftLoggedInUserID.isEmpty else {
                echoDriftCurrentUser = nil
                echoDriftChatRows = []
                return
            }

            guard let echoDriftUser = try echoDriftUserStore.novaPulseFetchUser(
                byID: echoDriftLoggedInUserID
            ) else {
                echoDriftCurrentUser = nil
                echoDriftChatRows = []
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Unable to load your chat list right now.",
                    style: .error
                )
                return
            }

            let echoDriftRooms = try echoDriftChatRoomStore.echoNovaFetchChatRooms(
                byUserID: echoDriftLoggedInUserID
            )

            echoDriftCurrentUser = echoDriftUser
            echoDriftChatRows = try echoDriftRooms.compactMap { echoDriftRoom in
                let echoDriftPeerUserID = echoDriftRoom.echoNovaMemberUserIDs.first {
                    $0 != echoDriftLoggedInUserID
                }

                guard let echoDriftPeerUserID else {
                    return nil
                }

                guard !echoDriftUser.novaPulseBlockedIDs.contains(echoDriftPeerUserID) else {
                    return nil
                }

                guard let echoDriftPeerUser = try echoDriftUserStore.novaPulseFetchUser(
                    byID: echoDriftPeerUserID
                ) else {
                    return nil
                }

                return EchoDriftChatRow(
                    id: echoDriftRoom.id,
                    echoDriftPeerUserID: echoDriftPeerUserID,
                    echoDriftName: echoDriftPeerUser.novaPulseUserName,
                    echoDriftAvatarPath: echoDriftPeerUser.novaPulseAvatar,
                    echoDriftPreviewText: echoDriftRoom.echoNovaLastMessageText,
                    echoDriftSentAt: echoDriftRoom.echoNovaLastMessageSentAt,
                    echoDriftUnreadMessageCount: echoDriftRoom.echoNovaUnreadMessageCount
                )
            }
        } catch {
            echoDriftCurrentUser = nil
            echoDriftChatRows = []
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load your chat list right now.",
                style: .error
            )
        }
    }
}

private struct EchoDriftChatRow: Identifiable {
    let id: String
    let echoDriftPeerUserID: String
    let echoDriftName: String
    let echoDriftAvatarPath: String
    let echoDriftPreviewText: String
    let echoDriftSentAt: Date
    let echoDriftUnreadMessageCount: Int
}

private struct EchoDriftMessageCard: View {
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter

    let echoDriftMessage: EchoDriftChatRow

    var body: some View {
        Button(action: {
            pulseNovaRouter.pulseNovaPush(
                .orbitEchoChatRoom(
                    orbitEchoChatRoomID: echoDriftMessage.id
                )
            )
        }) {
            HStack(spacing: 12) {
                OrbitNovaSmartImage(
                    orbitNovaImagePath: echoDriftMessage.echoDriftAvatarPath
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
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(Color.chalkPureWhite)
                        }
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(echoDriftDisplayName)
                            .font(.pulseRobotoBold(size: 16))
                            .foregroundStyle(Color.chalkPureWhite)

                        Spacer()

                        Text(echoDriftRelativeTimeText)
                            .font(.pulseRobotoRegular(size: 10))
                            .foregroundStyle(Color.chalkMist)
                    }

                    HStack(spacing: 8) {
                        Text(echoDriftPreviewText)
                            .font(.pulseRobotoRegular(size: 12))
                            .foregroundStyle(Color.chalkMist)
                            .lineLimit(1)

                        Spacer(minLength: 0)

                        if echoDriftMessage.echoDriftUnreadMessageCount > 0 {
                            Text("\(echoDriftMessage.echoDriftUnreadMessageCount)")
                                .font(.pulseRobotoBold(size: 10))
                                .foregroundStyle(Color.chalkJetBlack)
                                .frame(minWidth: 18, minHeight: 18)
                                .padding(.horizontal, 4)
                                .background(Color.burnSignalYellow)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.11))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private var echoDriftDisplayName: String {
        let echoDriftTrimmedName = echoDriftMessage.echoDriftName
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return echoDriftTrimmedName.isEmpty ? "Unknown User" : echoDriftTrimmedName
    }

    private var echoDriftPreviewText: String {
        let echoDriftTrimmedText = echoDriftMessage.echoDriftPreviewText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return echoDriftTrimmedText.isEmpty ? "Voice message" : echoDriftTrimmedText
    }

    private var echoDriftRelativeTimeText: String {
        let echoDriftFormatter = RelativeDateTimeFormatter()
        echoDriftFormatter.unitsStyle = .abbreviated
        return echoDriftFormatter.localizedString(
            for: echoDriftMessage.echoDriftSentAt,
            relativeTo: Date()
        )
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        EchoDriftMessagePage()
            .burnStageBackground()

        OrbitPulseTabBar(orbitPulseSelectedTab: .constant(.echoMessage))
            .padding(.bottom, 22)
    }
    .preferredColorScheme(.dark)
    .environmentObject(PulseNovaRouter())
    .environmentObject(NovaPulseFeedbackHub())
}
