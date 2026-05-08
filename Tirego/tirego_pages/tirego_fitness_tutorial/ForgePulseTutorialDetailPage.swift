import AVFoundation
import AVKit
import SwiftUI

struct ForgePulseTutorialDetailPage: View {
    private enum ForgePulseVideoPlaybackState {
        case idle
        case loading
        case ready
    }

    @Environment(\.dismiss) private var forgePulseDismiss
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub
    @EnvironmentObject private var vealvjaiAixVisitorGateHub: VealvjaiAixVisitorGateHub

    private let forgePulseUserStore = NovaPulseUserStore()
    private let forgePulseUnlockCost = 200
    private let forgePulseTutorialStore = ForgeLiftTutorialStore()
    let forgePulseTutorialID: String

    @State private var forgePulseCurrentUser: NovaPulseUser?
    @State private var forgePulseTutorial: ForgeLiftTutorial?
    @State private var forgePulseShowsPayDialog = false
    @State private var forgePulseDialogMode: ForgeNovaTutorialPayDialog.ForgeNovaDialogMode = .unlock
    @State private var forgePulseVideoPlayer: AVPlayer?
    @State private var forgePulseShowsVideoPlayer = false
    @State private var forgePulseVideoPlaybackState: ForgePulseVideoPlaybackState = .idle
    @State private var forgePulseVideoStatusObserver: NSKeyValueObservation?
    @State private var forgePulsePlaybackStalledObserver: NSObjectProtocol?
    @State private var forgePulsePlaybackEndedObserver: NSObjectProtocol?
    @State private var forgePulseVideoLoadTimeoutTask: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    forgePulseHeroButton

                    forgePulseBottomSheet
                }
            }

            forgePulseOverlayHeader
                .padding(.horizontal, 18)
                .padding(.top, 16)

            if forgePulseShowsPayDialog {
                ZStack{
                    Color.black.opacity(0.62)
                        .ignoresSafeArea()
                        .onTapGesture {
                            forgePulseShowsPayDialog = false
                        }

                    ForgeNovaTutorialPayDialog(
                        forgeNovaMode: forgePulseDialogMode,
                        forgeNovaPrimaryAction: forgePulseHandleDialogPrimaryAction,
                        forgeNovaCloseAction: {
                            forgePulseShowsPayDialog = false
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
                
            }

            
        }
        .background(Color.flexPitchBlack)
        .preferredColorScheme(.dark)
        .background(ForgeTrailSwipeBackEnabler())
        .task {
            forgePulseRefreshTutorial()
            forgePulseRefreshCurrentUser()
        }
        .animation(.easeInOut(duration: 0.2), value: forgePulseShowsPayDialog)
        .fullScreenCover(isPresented: $forgePulseShowsVideoPlayer, onDismiss: {
            forgePulseCleanupVideoPlayback()
        }) {
            forgePulseVideoPlayerScreen
        }
    }

    private var forgePulseHeroButton: some View {
        Button(action: forgePulseHandleUnlockEntryTap) {
            ZStack(alignment: .bottom) {
                forgePulseHeroSection

                if forgePulseShowsUnlockCard {
                    forgePulseUnlockCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
        .buttonStyle(.plain)
        .ignoresSafeArea()
    }

    private var forgePulseHeroSection: some View {
        ZStack {
            OrbitNovaSmartImage(
                orbitNovaImagePath: forgePulseTutorial?.forgeLiftCoverURL ?? ""
            ) {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.65),
                        Color.orange.opacity(0.55),
                        Color.red.opacity(0.45),
                        Color.gray.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .frame(height: 600)
            .overlay {
                Rectangle()
                    .fill(Color.black.opacity(0.22))
            }

            Image("TIREGOIconPlay")
                .resizable()
                .frame(width: 62, height: 62)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 600)
        .clipped()
        .contentShape(Rectangle())
    }

    private var forgePulseOverlayHeader: some View {
        HStack {
            Button(action: {
                forgePulseDismiss()
            }) {
                
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.chalkPureWhite)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.14))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

        }
    }

    private var forgePulseUnlockCard: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(forgePulseTutorialNeedsPayment ? Color.burnSignalYellow : Color.chalkPureWhite)
                .frame(width: 54, height: 54)
                .overlay {
                    Image("TIREGOLock")
                        .resizable()
                        .frame(width: 32, height: 32)
                }

            Text(forgePulseUnlockDescriptionText)
                .font(.pulseRobotoRegular(size: 14))
                .foregroundStyle(Color.chalkPureWhite)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .background(.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var forgePulseBottomSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(forgePulseTutorialLevelTitle)
                .font(.pulseRobotoRegular(size: 12))
                .foregroundStyle(Color.chalkJetBlack)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(forgePulseTutorialNeedsPayment ? Color.burnSignalYellow : Color.chalkPureWhite)
                .clipShape(Capsule())
            

            Text(forgePulseTutorialDescriptionText)
                .font(.pulseRobotoRegular(size: 16))
                .foregroundStyle(Color.chalkPureWhite)
                .lineSpacing(3)
                .padding(.top, 22)
                .padding(.bottom, 33)

        }
        .padding(.horizontal, 18)
        .padding(.top, 28)
        .padding(.bottom, 42)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.flexPitchBlack)
    }

    private var forgePulseTutorialNeedsPayment: Bool {
        forgePulseTutorial?.forgeLiftNeedsPayment ?? true
    }

    private var forgePulseTutorialLevelTitle: String {
        forgePulseTutorialNeedsPayment ? "Advanced" : "Beginner"
    }

    private var forgePulseUnlockTutorialID: String {
        forgePulseTutorial?.id ?? forgePulseTutorialID
    }

    private var forgePulseUnlockDescriptionText: String {
        if forgePulseTutorialNeedsPayment {
            return "This is a high-quality video tutorial. To unlock it, \(forgePulseUnlockCost) coins are required. Once unlocked, you can watch it with peace of mind."
        }

        return "This tutorial is free to watch. Tap play to start training and follow the guided movements at your own pace."
    }

    private var forgePulseShowsUnlockCard: Bool {
        guard forgePulseTutorialNeedsPayment else {
            return false
        }

        guard let forgePulseCurrentUser else {
            return true
        }

        return !forgePulseCurrentUser.novaPulsePurchasedTutorialIDs.contains(
            forgePulseUnlockTutorialID
        )
    }

    private var forgePulseTutorialDescriptionText: String {
        let forgePulseTrimmedText = forgePulseTutorial?
            .forgeLiftTutorialText
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if forgePulseTrimmedText.isEmpty {
            return "This workout tutorial helps you train more steadily with clear guidance, better rhythm, and a more focused routine."
        }

        return forgePulseTrimmedText
    }

    private var forgePulseVideoPlayerScreen: some View {
        ZStack(alignment: .topLeading) {
            Color.black
                .ignoresSafeArea()

            if let forgePulseVideoPlayer {
                VideoPlayer(player: forgePulseVideoPlayer)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .tint(.white)
            }

            if forgePulseVideoPlaybackState == .loading {
                ZStack {
                    Color.black.opacity(0.24)
                        .ignoresSafeArea()

                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.18)
                }
            }

            Button(action: {
                forgePulseShowsVideoPlayer = false
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.chalkPureWhite)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.45))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.leading, 18)
            .padding(.top, 18)
        }
        .preferredColorScheme(.dark)
    }

    private func forgePulseRefreshTutorial() {
        do {
            forgePulseTutorial = try forgePulseTutorialStore.forgeLiftFetchTutorial(
                byID: forgePulseTutorialID
            )
        } catch {
            forgePulseTutorial = nil
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load tutorial details right now.",
                style: .error
            )
        }
    }

    private func forgePulseRefreshCurrentUser() {
        do {
            guard let forgePulseLoggedInUserID = LiftVaultPersistenceStore
                .liftVaultLoadLoggedInUserID()?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !forgePulseLoggedInUserID.isEmpty else {
                forgePulseCurrentUser = nil
                return
            }

            forgePulseCurrentUser = try forgePulseUserStore.novaPulseFetchUser(
                byID: forgePulseLoggedInUserID
            )
        } catch {
            forgePulseCurrentUser = nil
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load your balance right now.",
                style: .error
            )
        }
    }

    private func forgePulseHandleUnlockEntryTap() {
        if VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser() {
            vealvjaiAixVisitorGateHub.vealvjaiAixShowVisitorAlert()
            return
        }

        guard let forgePulseTutorial else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "This tutorial is unavailable right now.",
                style: .error
            )
            return
        }

        guard forgePulseTutorial.forgeLiftNeedsPayment else {
            forgePulsePlayTutorial()
            return
        }

        guard let forgePulseCurrentUser else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please sign in first.",
                style: .error
            )
            return
        }

        if forgePulseCurrentUser.novaPulsePurchasedTutorialIDs.contains(forgePulseUnlockTutorialID) {
            forgePulsePlayTutorial()
            return
        }

        forgePulseDialogMode = forgePulseCurrentUser.novaPulseGoldCoinCount >= forgePulseUnlockCost
        ? .unlock
        : .recharge
        forgePulseShowsPayDialog = true
    }

    private func forgePulseHandleDialogPrimaryAction() {
        switch forgePulseDialogMode {
        case .unlock:
            forgePulseUnlockTutorial()
        case .recharge:
            forgePulseShowsPayDialog = false
            pulseNovaRouter.pulseNovaPush(.pulseNovaRecharge)
        }
    }

    private func forgePulseUnlockTutorial() {
        guard var forgePulseCurrentUser else {
            forgePulseShowsPayDialog = false
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please sign in first.",
                style: .error
            )
            return
        }

        guard forgePulseCurrentUser.novaPulseGoldCoinCount >= forgePulseUnlockCost else {
            forgePulseDialogMode = .recharge
            return
        }

        if !forgePulseCurrentUser.novaPulsePurchasedTutorialIDs.contains(forgePulseUnlockTutorialID) {
            forgePulseCurrentUser.novaPulsePurchasedTutorialIDs.append(forgePulseUnlockTutorialID)
        }
        forgePulseCurrentUser.novaPulseGoldCoinCount -= forgePulseUnlockCost

        do {
            try forgePulseUserStore.novaPulseUpdateUser(forgePulseCurrentUser)
            self.forgePulseCurrentUser = forgePulseCurrentUser
            forgePulseShowsPayDialog = false
            novaPulseFeedbackHub.novaPulseShowToast(
                "Tutorial unlocked successfully.",
                style: .success
            )
            forgePulsePlayTutorial()
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to unlock this tutorial right now.",
                style: .error
            )
        }
    }

    private func forgePulsePlayTutorial() {
        guard let forgePulseTutorial else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "This tutorial is unavailable right now.",
                style: .error
            )
            return
        }

        let forgePulseVideoAddress = forgePulseTutorial
            .forgeLiftVideoURL
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !forgePulseVideoAddress.isEmpty,
              let forgePulseVideoURL = forgePulseResolvedVideoURL(
                from: forgePulseVideoAddress
              ) else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Video source is unavailable.",
                style: .error
            )
            return
        }

        forgePulseCleanupVideoPlayback()

        let forgePulseVideoItem = AVPlayerItem(url: forgePulseVideoURL)
        forgePulseVideoPlaybackState = .loading
        forgePulseConfigureVideoObservers(for: forgePulseVideoItem)
        forgePulseVideoPlayer = AVPlayer(playerItem: forgePulseVideoItem)
        forgePulseShowsVideoPlayer = true
        forgePulseStartVideoLoadTimeout()
    }

    private func forgePulseResolvedVideoURL(
        from forgePulseVideoAddress: String
    ) -> URL? {
        if forgePulseVideoAddress.hasPrefix("http://")
            || forgePulseVideoAddress.hasPrefix("https://") {
            return URL(string: forgePulseVideoAddress)
        }

        if forgePulseVideoAddress.hasPrefix("file://") {
            return URL(string: forgePulseVideoAddress)
        }

        if forgePulseVideoAddress.hasPrefix("/") {
            return URL(fileURLWithPath: forgePulseVideoAddress)
        }

        return Bundle.main.url(
            forResource: forgePulseVideoAddress,
            withExtension: nil
        )
    }

    private func forgePulseConfigureVideoObservers(
        for forgePulseVideoItem: AVPlayerItem
    ) {
        forgePulseVideoStatusObserver?.invalidate()
        forgePulseVideoStatusObserver = forgePulseVideoItem.observe(
            \.status,
            options: [.initial, .new]
        ) { forgePulseObservedItem, _ in
            DispatchQueue.main.async {
                switch forgePulseObservedItem.status {
                case .readyToPlay:
                    forgePulseVideoLoadTimeoutTask?.cancel()
                    forgePulseVideoPlaybackState = .ready
                    forgePulseVideoPlayer?.play()
                case .failed:
                    let forgePulseErrorMessage = forgePulseObservedItem
                        .error?
                        .localizedDescription
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    forgePulseHandleVideoLoadFailure(
                        message: forgePulseErrorMessage?.isEmpty == false
                        ? forgePulseErrorMessage!
                        : "Video failed to load."
                    )
                case .unknown:
                    break
                @unknown default:
                    forgePulseHandleVideoLoadFailure(
                        message: "Video playback is unavailable right now."
                    )
                }
            }
        }

        if let forgePulsePlaybackStalledObserver {
            NotificationCenter.default.removeObserver(forgePulsePlaybackStalledObserver)
        }

        forgePulsePlaybackStalledObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemPlaybackStalled,
            object: forgePulseVideoItem,
            queue: .main
        ) { _ in
            forgePulseHandleVideoLoadFailure(
                message: "Video playback stalled. Please try again."
            )
        }

        if let forgePulsePlaybackEndedObserver {
            NotificationCenter.default.removeObserver(forgePulsePlaybackEndedObserver)
        }

        forgePulsePlaybackEndedObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: forgePulseVideoItem,
            queue: .main
        ) { _ in
            forgePulseVideoPlayer?.seek(to: .zero)
            forgePulseVideoPlayer?.play()
        }
    }

    private func forgePulseStartVideoLoadTimeout() {
        forgePulseVideoLoadTimeoutTask?.cancel()
        forgePulseVideoLoadTimeoutTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 12_000_000_000)

            guard !Task.isCancelled,
                  forgePulseShowsVideoPlayer,
                  forgePulseVideoPlaybackState == .loading else {
                return
            }

            forgePulseHandleVideoLoadFailure(
                message: "Video loading timed out. Please try again."
            )
        }
    }

    private func forgePulseHandleVideoLoadFailure(
        message forgePulseMessage: String
    ) {
        forgePulseCleanupVideoPlayback()
        forgePulseShowsVideoPlayer = false
        novaPulseFeedbackHub.novaPulseShowToast(
            forgePulseMessage,
            style: .error
        )
    }

    private func forgePulseCleanupVideoPlayback() {
        forgePulseVideoLoadTimeoutTask?.cancel()
        forgePulseVideoLoadTimeoutTask = nil

        forgePulseVideoStatusObserver?.invalidate()
        forgePulseVideoStatusObserver = nil

        if let forgePulsePlaybackStalledObserver {
            NotificationCenter.default.removeObserver(forgePulsePlaybackStalledObserver)
            self.forgePulsePlaybackStalledObserver = nil
        }

        if let forgePulsePlaybackEndedObserver {
            NotificationCenter.default.removeObserver(forgePulsePlaybackEndedObserver)
            self.forgePulsePlaybackEndedObserver = nil
        }

        forgePulseVideoPlayer?.pause()
        forgePulseVideoPlayer = nil
        forgePulseVideoPlaybackState = .idle
    }
}

#Preview {
    ForgePulseTutorialDetailPage(forgePulseTutorialID: "tutorial_001")
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
        .environmentObject(VealvjaiAixVisitorGateHub())
}
