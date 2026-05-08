import SwiftUI

struct ForgeDriftPostDetailPage: View {
    @Environment(\.dismiss) private var forgeDriftDismiss
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub
    @EnvironmentObject private var vealvjaiAixVisitorGateHub: VealvjaiAixVisitorGateHub
    @EnvironmentObject private var blazeNovaReportSheetHub: BlazeNovaReportSheetHub

    private let forgeDriftPostStore = BlazeEchoPostStore()
    private let forgeDriftCommentStore = OrbitDriftCommentStore()
    private let forgeDriftUserStore = NovaPulseUserStore()
    let forgeDriftPostID: String

    @State private var forgeDriftPost: BlazeEchoPost?
    @State private var forgeDriftPublisher: NovaPulseUser?
    @State private var forgeDriftCommentItems: [OrbitDriftComment] = []
    @State private var forgeDriftUserMap: [String: NovaPulseUser] = [:]
    @State private var forgeDriftSelectedImageIndex = 0
    @State private var forgeDriftCommentText = ""
    @State private var forgeDriftReportTargetUserID: String?
    @FocusState private var forgeDriftCommentFocused: Bool

    private var forgeDriftTrimmedCommentText: String {
        forgeDriftCommentText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    var body: some View {
        ZStack {
            Color.flexPitchBlack
                .ignoresSafeArea()
                .onTapGesture {
                    forgeDriftCommentFocused = false
                }

            VStack {
                forgeDriftHeader
                    .padding(.horizontal, 14)
                    .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        forgeDriftHeroImage
                            .padding(.top, 12)

                        Text(forgeDriftPost?.blazeEchoContentText ?? "Post details")
                            .font(.pulseRobotoRegular(size: 16))
                            .foregroundStyle(Color.chalkPureWhite)
                            .padding(.horizontal, 14)
                            .padding(.top, 18)

                        Text("Comments")
                            .font(.flexCarterDisplay(size: 22, relativeTo: .title))
                            .foregroundStyle(Color.burnSignalYellow)
                            .padding(.horizontal, 14)
                            .padding(.top, 24)

                        LazyVStack(spacing: 16) {
                            if forgeDriftCommentItems.isEmpty {
                                TirevOxaejjEmptyData()
                                    .padding(.vertical, 12)
                            } else {
                                ForEach(forgeDriftCommentItems) { forgeDriftComment in
                                    ForgeDriftCommentRow(
                                        forgeDriftComment: forgeDriftComment,
                                        forgeDriftCurrentUserID: forgeDriftCurrentUserID,
                                        forgeDriftAuthorName: forgeDriftUserMap[forgeDriftComment.orbitDriftPublisherID]?.novaPulseUserName ?? "Unknown",
                                        forgeDriftAvatarPath: forgeDriftUserMap[forgeDriftComment.orbitDriftPublisherID]?.novaPulseAvatar ?? "",
                                        forgeDriftAvatarTapAction: {
                                            forgeDriftOpenUserProfile(
                                                forgeDriftUserID: forgeDriftComment.orbitDriftPublisherID
                                            )
                                        },
                                        forgeDriftMoreTapAction: {
                                            forgeDriftShowReportSheet(
                                                forgeDriftTargetUserID: forgeDriftComment.orbitDriftPublisherID
                                            )
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 16)

                        Spacer(minLength: 110)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    forgeDriftCommentFocused = false
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .burnStageBackground()
        .preferredColorScheme(.dark)
        .background(ForgeTrailSwipeBackEnabler())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            forgeDriftComposerBar
        }
        .task {
            forgeDriftRefreshPostDetail()
        }
    }

    private var forgeDriftHeader: some View {
        HStack(spacing: 16) {
            Button(action: {
                forgeDriftDismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.chalkPureWhite)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button(action: {
                forgeDriftOpenUserProfile(
                    forgeDriftUserID: forgeDriftPublisher?.id
                )
            }) {
                OrbitNovaSmartImage(
                    orbitNovaImagePath: forgeDriftPublisher?.novaPulseAvatar ?? ""
                ) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.9), Color.black],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.chalkPureWhite)
                        }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Text(forgeDriftPublisher?.novaPulseUserName ?? "Unknown")
                .font(.pulseRobotoBold(size: 16))
                .foregroundStyle(Color.chalkPureWhite)

            Spacer()

            if forgeDriftPublisher?.id != forgeDriftCurrentUserID {
                Button(action: {
                    forgeDriftShowReportSheet(
                        forgeDriftTargetUserID: forgeDriftPublisher?.id ?? ""
                    )
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

    private var forgeDriftHeroImage: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $forgeDriftSelectedImageIndex) {
                ForEach(Array(forgeDriftDisplayImagePaths.enumerated()), id: \.offset) { forgeDriftIndex, forgeDriftImagePath in
                    OrbitNovaSmartImage(
                        orbitNovaImagePath: forgeDriftImagePath
                    ) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.45),
                                        Color.white.opacity(0.92),
                                        Color.blue.opacity(0.55),
                                        Color.gray.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(alignment: .center) {
                                Image(systemName: "photo")
                                    .font(.system(size: 120, weight: .thin))
                                    .foregroundStyle(Color.white.opacity(0.72))
                            }
                    }
                    .tag(forgeDriftIndex)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if forgeDriftDisplayImagePaths.count > 1 {
                HStack(spacing: 8) {
                    ForEach(forgeDriftDisplayImagePaths.indices, id: \.self) { forgeDriftIndex in
                        Capsule()
                            .fill(
                                forgeDriftSelectedImageIndex == forgeDriftIndex
                                ? Color.chalkPureWhite
                                : Color.chalkPureWhite.opacity(0.35)
                            )
                            .frame(
                                width: forgeDriftSelectedImageIndex == forgeDriftIndex ? 18 : 7,
                                height: 7
                            )
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .frame(height: 410)
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {
            forgeDriftCommentFocused = false
        }
    }

    private var forgeDriftDisplayImagePaths: [String] {
        let forgeDriftImagePaths = forgeDriftPost?.blazeEchoImageList ?? []
        return forgeDriftImagePaths.isEmpty ? [""] : forgeDriftImagePaths
    }

    private var forgeDriftCurrentUserID: String {
        LiftVaultPersistenceStore.liftVaultLoadLoggedInUserID()?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private var forgeDriftComposerBar: some View {
        HStack(spacing: 10) {
            TextField("", text: $forgeDriftCommentText, prompt: forgeDriftPromptText)
                .font(.pulseRobotoRegular(size: 15))
                .foregroundStyle(Color.chalkPureWhite)
                .tint(.white)
                .focused($forgeDriftCommentFocused)
                .textInputAutocapitalization(.never)
                .disabled(VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser())

            Button(action: {
                if VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser() {
                    vealvjaiAixVisitorGateHub.vealvjaiAixShowVisitorAlert()
                    return
                }

                forgeDriftSubmitComment()
            }) {
                Capsule()
                    .fill(
                        forgeDriftTrimmedCommentText.isEmpty
                        ? Color.burnSignalYellow.opacity(0.55)
                        : Color.burnSignalYellow
                    )
                    .frame(width: 60, height: 40)
                    .overlay {
                        Image("TIREGOSend")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
            }
            .buttonStyle(.plain)
            .disabled(forgeDriftTrimmedCommentText.isEmpty)
        }
        .padding(.leading, 14)
        .frame(height: 46)
        .background(Color.white.opacity(0.17))
        .clipShape(Capsule())
        .contentShape(Capsule())
        .onTapGesture {
            if VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser() {
                vealvjaiAixVisitorGateHub.vealvjaiAixShowVisitorAlert()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 34)
        .background(
            Rectangle()
                .fill(Color(red: 31 / 255, green: 31 / 255, blue: 31 / 255))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var forgeDriftPromptText: Text {
        Text("Say something...")
            .font(.pulsePlaceholderText(size: 15))
            .foregroundColor(Color.chalkPureWhite.opacity(0.7))
    }

    private func forgeDriftRefreshPostDetail() {
        do {
            let forgeDriftAllUsers = try forgeDriftUserStore.novaPulseFetchAllUsers()
            forgeDriftUserMap = Dictionary(
                uniqueKeysWithValues: forgeDriftAllUsers.map { ($0.id, $0) }
            )

            forgeDriftPost = try forgeDriftPostStore.blazeEchoFetchPost(
                byID: forgeDriftPostID
            )

            if let forgeDriftPost {
                forgeDriftPublisher = forgeDriftUserMap[forgeDriftPost.blazeEchoPublisherID]
            } else {
                forgeDriftPublisher = nil
            }

            forgeDriftSelectedImageIndex = 0

            forgeDriftCommentItems = try forgeDriftCommentStore.orbitDriftFetchComments(
                byPostID: forgeDriftPostID
            )
            .filter { !forgeDriftBlockedUserIDs.contains($0.orbitDriftPublisherID) }
            .sorted { $0.orbitDriftCreatedAt < $1.orbitDriftCreatedAt }
        } catch {
            forgeDriftPost = nil
            forgeDriftPublisher = nil
            forgeDriftCommentItems = []
            forgeDriftUserMap = [:]
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load post details right now.",
                style: .error
            )
        }
    }

    private var forgeDriftBlockedUserIDs: Set<String> {
        Set(
            forgeDriftUserMap[forgeDriftCurrentUserID]?.novaPulseBlockedIDs ?? []
        )
    }

    private func forgeDriftSubmitComment() {
        let forgeDriftContentText = forgeDriftTrimmedCommentText

        guard !forgeDriftContentText.isEmpty else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please enter your comment.",
                style: .error
            )
            return
        }

        do {
            guard let forgeDriftCurrentUser = try forgeDriftCurrentUser() else {
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Please log in first.",
                    style: .error
                )
                return
            }

            let forgeDriftNewComment = OrbitDriftComment(
                id: UUID().uuidString,
                orbitDriftPostID: forgeDriftPostID,
                orbitDriftPublisherID: forgeDriftCurrentUser.id,
                orbitDriftContentText: forgeDriftContentText,
                orbitDriftCreatedAt: Date()
            )

            try forgeDriftCommentStore.orbitDriftCreateComment(
                forgeDriftNewComment
            )

            forgeDriftCommentText = ""
            forgeDriftCommentFocused = false
            forgeDriftRefreshPostDetail()
            novaPulseFeedbackHub.novaPulseShowToast(
                "Comment posted.",
                style: .success
            )
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to post comment right now.",
                style: .error
            )
        }
    }

    private func forgeDriftCurrentUser() throws -> NovaPulseUser? {
        guard let forgeDriftCurrentUserID =
                LiftVaultPersistenceStore.liftVaultLoadLoggedInUserID()
        else {
            return nil
        }

        return try forgeDriftUserStore.novaPulseFetchUser(
            byID: forgeDriftCurrentUserID
        )
    }

    private func forgeDriftOpenUserProfile(
        forgeDriftUserID: String?
    ) {
        guard let forgeDriftUserID,
              !forgeDriftUserID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return
        }

        pulseNovaRouter.pulseNovaPush(
            .forgeOrbitUserProfile(forgeOrbitUserID: forgeDriftUserID)
        )
    }

    private func forgeDriftShowReportSheet(
        forgeDriftTargetUserID: String
    ) {
        guard !forgeDriftTargetUserID
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty else {
            return
        }

        forgeDriftReportTargetUserID = forgeDriftTargetUserID
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

                forgeDriftBlockTargetUser()
            }
        )
    }

    private func forgeDriftBlockTargetUser() {
        guard !forgeDriftCurrentUserID.isEmpty,
              let forgeDriftTargetUserID = forgeDriftReportTargetUserID else {
            return
        }

        do {
            let forgeDriftBlockResult = try BlazeNovaBlockCenter.blazeNovaBlockUser(
                currentUserID: forgeDriftCurrentUserID,
                targetUserID: forgeDriftTargetUserID,
                userStore: forgeDriftUserStore
            )

            forgeDriftReportTargetUserID = nil

            if forgeDriftBlockResult.blazeNovaWasAlreadyBlocked {
                novaPulseFeedbackHub.novaPulseShowToast(
                    "This user is already blocked.",
                    style: .normal
                )
                pulseNovaRouter.pulseNovaPopToRoot()
                return
            }

            if forgeDriftTargetUserID == forgeDriftPost?.blazeEchoPublisherID {
                novaPulseFeedbackHub.novaPulseShowToast(
                    "User blocked successfully.",
                    style: .success
                )
                pulseNovaRouter.pulseNovaPopToRoot()
                return
            }

            forgeDriftRefreshPostDetail()
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

private struct ForgeDriftCommentRow: View {
    let forgeDriftComment: OrbitDriftComment
    let forgeDriftCurrentUserID: String
    let forgeDriftAuthorName: String
    let forgeDriftAvatarPath: String
    let forgeDriftAvatarTapAction: () -> Void
    let forgeDriftMoreTapAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                Button(action: forgeDriftAvatarTapAction) {
                    OrbitNovaSmartImage(
                        orbitNovaImagePath: forgeDriftAvatarPath
                    ) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.85), Color.black],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.chalkPureWhite)
                            }
                    }
                    .frame(width: 34, height: 34)
                    .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Text(forgeDriftAuthorName)
                    .font(.pulseRobotoBold(size: 17))
                    .foregroundStyle(Color.chalkPureWhite)

                Spacer()

                if forgeDriftComment.orbitDriftPublisherID != forgeDriftCurrentUserID {
                    Button(action: forgeDriftMoreTapAction) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.chalkPureWhite)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(forgeDriftComment.orbitDriftContentText)
                .font(.pulseRobotoRegular(size: 14))
                .foregroundStyle(Color.chalkMist)
                .padding(.leading, 44)
        }
    }
}

#Preview {
    ForgeDriftPostDetailPage(forgeDriftPostID: "post_001")
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
        .environmentObject(VealvjaiAixVisitorGateHub())
        .environmentObject(BlazeNovaReportSheetHub())
}
