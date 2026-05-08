import AVFoundation
import SwiftUI

private let orbitEchoVoicePlaybackDidStartNotification = Notification.Name(
    "orbitEchoVoicePlaybackDidStartNotification"
)

struct OrbitEchoChatRoomPage: View {
    @Environment(\.dismiss) private var orbitEchoDismiss
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub
    @EnvironmentObject private var blazeNovaReportSheetHub: BlazeNovaReportSheetHub

    private enum OrbitEchoComposerMode {
        case text
        case voice
    }

    private let orbitEchoUserStore = NovaPulseUserStore()
    private let orbitEchoChatRoomStore = EchoNovaChatRoomStore()
    private let orbitEchoChatMessageStore = BlazePulseChatMessageStore()
    let orbitEchoChatRoomID: String

    @State private var orbitEchoChatRoom: EchoNovaChatRoom?
    @State private var orbitEchoCurrentUser: NovaPulseUser?
    @State private var orbitEchoPeerUser: NovaPulseUser?
    @State private var orbitEchoMessageItems: [BlazePulseChatMessage] = []
    @State private var orbitEchoComposerMode: OrbitEchoComposerMode = .text
    @State private var orbitEchoInputText = ""
    @State private var orbitEchoAudioRecorder: AVAudioRecorder?
    @State private var orbitEchoRecordingFileURL: URL?
    @State private var orbitEchoRecordingStartedAt: Date?
    @State private var orbitEchoIsRecording = false
    @State private var orbitEchoRecordingStatusText = "Hold to record"
    @State private var orbitEchoHasMicrophonePermission = false
    @State private var orbitEchoHasPreparedAudioSession = false
    @State private var orbitEchoIsPreparingVoiceComposer = false
    @FocusState private var orbitEchoInputFocused: Bool

    private var orbitEchoTrimmedInputText: String {
        orbitEchoInputText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    var body: some View {
        ZStack {
            Color.flexPitchBlack
                .ignoresSafeArea()
                .onTapGesture {
                    orbitEchoInputFocused = false
                }

            VStack(spacing: 0) {
                orbitEchoHeader
                    .padding(.horizontal, 14)
                    .padding(.top, 16)

                ScrollViewReader { orbitEchoScrollProxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 18) {
                            ForEach(orbitEchoMessageItems) { orbitEchoMessage in
                                OrbitEchoMessageBubbleView(
                                    orbitEchoMessage: orbitEchoMessage,
                                    orbitEchoCurrentUserID: orbitEchoCurrentUser?.id ?? "",
                                    orbitEchoCurrentAvatarPath: orbitEchoCurrentUser?.novaPulseAvatar ?? "",
                                    orbitEchoPeerAvatarPath: orbitEchoPeerUser?.novaPulseAvatar ?? ""
                                )
                                .id(orbitEchoMessage.id)
                            }

                            Spacer(minLength: 18)
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 18)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        orbitEchoInputFocused = false
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onAppear {
                        orbitEchoScrollToBottom(using: orbitEchoScrollProxy)
                    }
                    .onChange(of: orbitEchoMessageItems.count) { _ in
                        orbitEchoScrollToBottom(using: orbitEchoScrollProxy)
                    }
                }
            }

        }
        .burnStageBackground()
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.2), value: orbitEchoComposerMode == .voice)
        .background(ForgeTrailSwipeBackEnabler())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if orbitEchoComposerMode == .text {
                orbitEchoTextComposer
            } else {
                orbitEchoVoiceComposer
            }
        }
        .task {
            orbitEchoRefreshChatRoom()
        }
        .onDisappear {
            orbitEchoAudioRecorder?.stop()
            orbitEchoAudioRecorder = nil
        }
    }

    private var orbitEchoHeader: some View {
        HStack(spacing: 10) {
            Button(action: {
                orbitEchoDismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.chalkPureWhite)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            OrbitNovaSmartImage(
                orbitNovaImagePath: orbitEchoPeerUser?.novaPulseAvatar ?? ""
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
            .frame(width: 34, height: 34)
            .clipShape(Circle())

            Text(orbitEchoPeerDisplayName)
                .font(.pulseRobotoBold(size: 20))
                .foregroundStyle(Color.chalkPureWhite)

            Spacer()

            if orbitEchoPeerUser?.id != orbitEchoCurrentUser?.id {
                Button(action: {
                    orbitEchoShowReportSheet()
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

    private var orbitEchoTextComposer: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                TextField("", text: $orbitEchoInputText, prompt: orbitEchoPromptText)
                    .font(.pulseRobotoRegular(size: 14))
                    .foregroundStyle(Color.chalkPureWhite)
                    .tint(.white)
                    .focused($orbitEchoInputFocused)

                Button(action: orbitEchoPrepareVoiceComposer) {
                    ZStack {
                        if orbitEchoIsPreparingVoiceComposer {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.chalkPureWhite)
                        }
                    }
                    .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .disabled(orbitEchoIsPreparingVoiceComposer)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(Color.white.opacity(0.17))
            .clipShape(Capsule())

            Button(action: orbitEchoSendTextMessage) {
                Circle()
                    .fill(
                        orbitEchoTrimmedInputText.isEmpty
                        ? Color.burnSignalYellow.opacity(0.55)
                        : Color.burnSignalYellow
                    )
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.chalkJetBlack)
                            .offset(x: -1, y: 1)
                    }
            }
            .buttonStyle(.plain)
            .disabled(orbitEchoTrimmedInputText.isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .background(
            Rectangle()
                .fill(Color(red: 31 / 255, green: 31 / 255, blue: 31 / 255))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var orbitEchoVoiceComposer: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 31/255, green: 31/255, blue: 31/255))
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 18) {
                HStack {
                    Button(action: {
                        orbitEchoComposerMode = .text
                        orbitEchoHasPreparedAudioSession = false
                        try? AVAudioSession.sharedInstance().setActive(
                            false,
                            options: .notifyOthersOnDeactivation
                        )
                        orbitEchoRecordingStatusText = "Hold to record"
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
                }

                Text(orbitEchoRecordingStatusText)
                    .font(.pulseRobotoRegular(size: 14))
                    .foregroundStyle(Color.chalkPureWhite.opacity(0.85))

                ZStack {
                    Circle()
                        .fill(Color.burnSignalYellow.opacity(0.2))
                        .frame(width: 66, height: 66)

                    Circle()
                        .fill(orbitEchoIsRecording ? Color.red.opacity(0.88) : Color.burnSignalYellow)
                        .frame(width: 56, height: 56)
                        .overlay {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    orbitEchoIsRecording ? Color.chalkPureWhite : Color.chalkJetBlack
                                )
                        }
                }
                .frame(width: 108, height: 108)
                .contentShape(Circle())
                .highPriorityGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    orbitEchoBeginRecordingIfNeeded()
                                }
                                .onEnded { _ in
                                    orbitEchoFinishRecordingAndSend()
                                }
                        )
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
        .frame(height: 196)
    }

    private var orbitEchoPromptText: Text {
        Text("Say something...")
            .font(.pulsePlaceholderText(size: 14))
            .foregroundColor(Color.chalkPureWhite.opacity(0.7))
    }

    private var orbitEchoPeerDisplayName: String {
        let orbitEchoName = orbitEchoPeerUser?.novaPulseUserName
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return orbitEchoName.isEmpty ? "Unknown User" : orbitEchoName
    }

    private func orbitEchoRefreshChatRoom() {
        do {
            guard let orbitEchoLoggedInUserID = LiftVaultPersistenceStore
                .liftVaultLoadLoggedInUserID()?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !orbitEchoLoggedInUserID.isEmpty else {
                orbitEchoCurrentUser = nil
                orbitEchoPeerUser = nil
                orbitEchoChatRoom = nil
                orbitEchoMessageItems = []
                return
            }

            guard let orbitEchoLoadedCurrentUser = try orbitEchoUserStore.novaPulseFetchUser(
                byID: orbitEchoLoggedInUserID
            ), let orbitEchoChatRoom = try orbitEchoChatRoomStore.echoNovaFetchChatRoom(
                byID: orbitEchoChatRoomID
            ) else {
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Unable to load this chat room right now.",
                    style: .error
                )
                return
            }

            let orbitEchoPeerUserID = orbitEchoChatRoom.echoNovaMemberUserIDs.first {
                $0 != orbitEchoLoggedInUserID
            }

            orbitEchoCurrentUser = orbitEchoLoadedCurrentUser
            self.orbitEchoChatRoom = orbitEchoChatRoom
            orbitEchoPeerUser = try orbitEchoPeerUserID.flatMap {
                try orbitEchoUserStore.novaPulseFetchUser(byID: $0)
            }
            orbitEchoMessageItems = try orbitEchoChatMessageStore
                .blazePulseFetchChatMessages(byChatRoomID: orbitEchoChatRoomID)

            if orbitEchoChatRoom.echoNovaUnreadMessageCount > 0 {
                var orbitEchoUpdatedRoom = orbitEchoChatRoom
                orbitEchoUpdatedRoom.echoNovaUnreadMessageCount = 0
                try orbitEchoChatRoomStore.echoNovaUpdateChatRoom(
                    orbitEchoUpdatedRoom
                )
                self.orbitEchoChatRoom = orbitEchoUpdatedRoom
            }
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load this chat room right now.",
                style: .error
            )
        }
    }

    private func orbitEchoSendTextMessage() {
        let orbitEchoTextMessage = orbitEchoTrimmedInputText

        guard !orbitEchoTextMessage.isEmpty else {
            return
        }

        orbitEchoInputFocused = false

        let orbitEchoChatMessage = BlazePulseChatMessage(
            id: UUID().uuidString,
            blazePulseChatRoomID: orbitEchoChatRoomID,
            blazePulseSenderUserID: orbitEchoCurrentUser?.id ?? "",
            blazePulseTextMessage: orbitEchoTextMessage,
            blazePulseVoiceMessageURL: "",
            blazePulseVoiceDuration: 0,
            blazePulseSentAt: Date()
        )

        orbitEchoPersistMessage(
            orbitEchoChatMessage,
            orbitEchoLastMessagePreview: orbitEchoTextMessage
        )
        orbitEchoInputText = ""
    }

    private func orbitEchoPersistMessage(
        _ orbitEchoChatMessage: BlazePulseChatMessage,
        orbitEchoLastMessagePreview: String
    ) {
        do {
            guard var orbitEchoChatRoom,
                  let orbitEchoCurrentUser else {
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Unable to send message right now.",
                    style: .error
                )
                return
            }

            try orbitEchoChatMessageStore.blazePulseCreateChatMessage(
                orbitEchoChatMessage
            )

            orbitEchoChatRoom.echoNovaLastMessageSentAt = orbitEchoChatMessage.blazePulseSentAt
            orbitEchoChatRoom.echoNovaLastSenderUserID = orbitEchoCurrentUser.id
            orbitEchoChatRoom.echoNovaLastMessageText = orbitEchoLastMessagePreview
            orbitEchoChatRoom.echoNovaUnreadMessageCount = 0

            try orbitEchoChatRoomStore.echoNovaUpdateChatRoom(
                orbitEchoChatRoom
            )

            self.orbitEchoChatRoom = orbitEchoChatRoom
            orbitEchoMessageItems.append(orbitEchoChatMessage)
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to send message right now.",
                style: .error
            )
        }
    }

    private func orbitEchoBeginRecordingIfNeeded() {
        guard !orbitEchoIsRecording,
              orbitEchoComposerMode == .voice,
              orbitEchoHasMicrophonePermission,
              orbitEchoHasPreparedAudioSession,
              !orbitEchoIsPreparingVoiceComposer else {
            return
        }

        orbitEchoInputFocused = false

        do {
            let orbitEchoAudioSession = AVAudioSession.sharedInstance()
            try orbitEchoAudioSession.setActive(true)

            let orbitEchoFileURL = try orbitEchoCreateRecordingFileURL()
            let orbitEchoRecorder = try AVAudioRecorder(
                url: orbitEchoFileURL,
                settings: [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44_100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
            )

            orbitEchoRecorder.prepareToRecord()
            orbitEchoRecorder.record()

            orbitEchoAudioRecorder = orbitEchoRecorder
            orbitEchoRecordingFileURL = orbitEchoFileURL
            orbitEchoRecordingStartedAt = Date()
            orbitEchoIsRecording = true
            orbitEchoRecordingStatusText = "Release to send"
        } catch {
            orbitEchoRecordingStatusText = "Hold to record"
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to start recording right now.",
                style: .error
            )
        }
    }

    private func orbitEchoPrepareVoiceComposer() {
        guard !orbitEchoIsPreparingVoiceComposer else {
            return
        }

        orbitEchoInputFocused = false
        orbitEchoRecordingStatusText = "Preparing microphone..."
        orbitEchoIsPreparingVoiceComposer = true

        let orbitEchoAudioSession = AVAudioSession.sharedInstance()
        switch orbitEchoAudioSession.recordPermission {
        case .granted:
            orbitEchoHasMicrophonePermission = true
            orbitEchoWarmAudioSessionAndEnterVoiceComposer()
        case .denied:
            orbitEchoHasMicrophonePermission = false
            orbitEchoIsPreparingVoiceComposer = false
            orbitEchoRecordingStatusText = "Microphone permission denied"
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please allow microphone access first.",
                style: .error
            )
        case .undetermined:
            orbitEchoAudioSession.requestRecordPermission { orbitEchoGranted in
                DispatchQueue.main.async {
                    guard orbitEchoGranted else {
                        orbitEchoHasMicrophonePermission = false
                        orbitEchoIsPreparingVoiceComposer = false
                        orbitEchoRecordingStatusText = "Microphone permission denied"
                        novaPulseFeedbackHub.novaPulseShowToast(
                            "Please allow microphone access first.",
                            style: .error
                        )
                        return
                    }

                    orbitEchoHasMicrophonePermission = true
                    orbitEchoWarmAudioSessionAndEnterVoiceComposer()
                }
            }
        @unknown default:
            orbitEchoHasMicrophonePermission = false
            orbitEchoIsPreparingVoiceComposer = false
            orbitEchoRecordingStatusText = "Microphone unavailable"
            novaPulseFeedbackHub.novaPulseShowToast(
                "Microphone is unavailable right now.",
                style: .error
            )
        }
    }

    private func orbitEchoWarmAudioSessionAndEnterVoiceComposer() {
        Task {
            do {
                let orbitEchoAudioSession = AVAudioSession.sharedInstance()
                try orbitEchoAudioSession.setCategory(
                    .playAndRecord,
                    mode: .default,
                    options: [.defaultToSpeaker, .allowBluetoothHFP]
                )
                try orbitEchoAudioSession.setActive(true)

                await MainActor.run {
                    orbitEchoHasPreparedAudioSession = true
                    orbitEchoComposerMode = .voice
                    orbitEchoIsPreparingVoiceComposer = false
                    orbitEchoRecordingStatusText = "Hold to record"
                }
            } catch {
                await MainActor.run {
                    orbitEchoHasPreparedAudioSession = false
                    orbitEchoIsPreparingVoiceComposer = false
                    orbitEchoRecordingStatusText = "Hold to record"
                    novaPulseFeedbackHub.novaPulseShowToast(
                        "Unable to prepare the microphone right now.",
                        style: .error
                    )
                }
            }
        }
    }

    private func orbitEchoFinishRecordingAndSend() {
        guard orbitEchoIsRecording else {
            return
        }

        let orbitEchoDuration = Date().timeIntervalSince(
            orbitEchoRecordingStartedAt ?? Date()
        )
        let orbitEchoFileURL = orbitEchoRecordingFileURL

        orbitEchoAudioRecorder?.stop()
        orbitEchoAudioRecorder = nil
        orbitEchoRecordingStartedAt = nil
        orbitEchoRecordingFileURL = nil
        orbitEchoIsRecording = false
        orbitEchoRecordingStatusText = "Hold to record"

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )

        guard let orbitEchoFileURL else {
            return
        }

        guard orbitEchoDuration >= 0.2 else {
            try? FileManager.default.removeItem(at: orbitEchoFileURL)
            novaPulseFeedbackHub.novaPulseShowToast(
                "Recording is too short.",
                style: .error
            )
            return
        }

        let orbitEchoChatMessage = BlazePulseChatMessage(
            id: UUID().uuidString,
            blazePulseChatRoomID: orbitEchoChatRoomID,
            blazePulseSenderUserID: orbitEchoCurrentUser?.id ?? "",
            blazePulseTextMessage: "",
            blazePulseVoiceMessageURL: orbitEchoFileURL.path,
            blazePulseVoiceDuration: orbitEchoDuration,
            blazePulseSentAt: Date()
        )

        orbitEchoPersistMessage(
            orbitEchoChatMessage,
            orbitEchoLastMessagePreview: ""
        )
    }

    private func orbitEchoCreateRecordingFileURL() throws -> URL {
        let orbitEchoRootURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let orbitEchoDirectoryURL = orbitEchoRootURL
            .appendingPathComponent("TiregoLocalData", isDirectory: true)
            .appendingPathComponent("orbit_echo_voice_messages", isDirectory: true)

        if !FileManager.default.fileExists(atPath: orbitEchoDirectoryURL.path) {
            try FileManager.default.createDirectory(
                at: orbitEchoDirectoryURL,
                withIntermediateDirectories: true
            )
        }

        return orbitEchoDirectoryURL.appendingPathComponent(
            "\(UUID().uuidString).m4a"
        )
    }

    private func orbitEchoScrollToBottom(
        using orbitEchoScrollProxy: ScrollViewProxy
    ) {
        guard let orbitEchoLastMessageID = orbitEchoMessageItems.last?.id else {
            return
        }

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.2)) {
                orbitEchoScrollProxy.scrollTo(
                    orbitEchoLastMessageID,
                    anchor: .bottom
                )
            }
        }
    }

    private func orbitEchoBlockPeerUser() {
        guard let orbitEchoCurrentUserID = orbitEchoCurrentUser?.id,
              let orbitEchoPeerUserID = orbitEchoPeerUser?.id else {
            return
        }

        do {
            let orbitEchoBlockResult = try BlazeNovaBlockCenter.blazeNovaBlockUser(
                currentUserID: orbitEchoCurrentUserID,
                targetUserID: orbitEchoPeerUserID,
                userStore: orbitEchoUserStore
            )

            if orbitEchoBlockResult.blazeNovaWasAlreadyBlocked {
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

    private func orbitEchoShowReportSheet() {
        blazeNovaReportSheetHub.blazeNovaShowReportSheet(
            blazeNovaReportAction: {
                pulseNovaRouter.pulseNovaPush(.orbitPulseReport)
            },
            blazeNovaBlockAction: {
                orbitEchoBlockPeerUser()
            }
        )
    }
}

private struct OrbitEchoMessageBubbleView: View {
    let orbitEchoMessage: BlazePulseChatMessage
    let orbitEchoCurrentUserID: String
    let orbitEchoCurrentAvatarPath: String
    let orbitEchoPeerAvatarPath: String

    @State private var orbitEchoAudioPlayer: AVAudioPlayer?
    @State private var orbitEchoVoicePlaybackTask: Task<Void, Never>?
    @State private var orbitEchoIsPlayingVoice = false

    private var orbitEchoIsCurrentUser: Bool {
        orbitEchoMessage.blazePulseSenderUserID == orbitEchoCurrentUserID
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !orbitEchoIsCurrentUser {
                orbitEchoAvatar(path: orbitEchoPeerAvatarPath)
            } else {
                Spacer(minLength: 34)
            }

            VStack(
                alignment: orbitEchoIsCurrentUser ? .trailing : .leading,
                spacing: 8
            ) {
                if !orbitEchoMessage.blazePulseTextMessage
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty {
                    Text(orbitEchoMessage.blazePulseTextMessage)
                        .font(.pulseRobotoRegular(size: 16))
                        .foregroundStyle(
                            orbitEchoIsCurrentUser
                            ? Color.chalkJetBlack
                            : Color.chalkPureWhite
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            orbitEchoIsCurrentUser
                            ? Color.burnSignalYellow
                            : Color.white.opacity(0.12)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                } else {
                    orbitEchoVoiceBubble
                }
            }

            if orbitEchoIsCurrentUser {
                orbitEchoAvatar(path: orbitEchoCurrentAvatarPath)
            } else {
                Spacer(minLength: 34)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: orbitEchoIsCurrentUser ? .trailing : .leading
        )
        .onReceive(
            NotificationCenter.default.publisher(
                for: orbitEchoVoicePlaybackDidStartNotification
            )
        ) { orbitEchoNotification in
            guard let orbitEchoPlayingMessageID = orbitEchoNotification.object as? String,
                  orbitEchoPlayingMessageID != orbitEchoMessage.id else {
                return
            }

            orbitEchoStopVoicePlayback()
        }
        .onDisappear {
            orbitEchoStopVoicePlayback()
        }
    }

    private func orbitEchoAvatar(path: String) -> some View {
        OrbitNovaSmartImage(
            orbitNovaImagePath: path
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
                        .font(.system(size: 13))
                        .foregroundStyle(Color.chalkPureWhite)
                }
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
    }

    private var orbitEchoVoiceBubble: some View {
        Button(action: orbitEchoToggleVoicePlayback) {
            HStack(spacing: 12) {
                if orbitEchoIsCurrentUser {
                    Text(orbitEchoDurationText)
                        .font(.pulseRobotoRegular(size: 16))
                        .foregroundStyle(Color.chalkJetBlack)

                    Image(systemName: orbitEchoIsPlayingVoice ? "pause.fill" : "waveform")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.chalkJetBlack)
                } else {
                    Image(systemName: orbitEchoIsPlayingVoice ? "pause.fill" : "waveform")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.chalkPureWhite)

                    Text(orbitEchoDurationText)
                        .font(.pulseRobotoRegular(size: 16))
                        .foregroundStyle(Color.chalkPureWhite)
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 52)
            .background(
                orbitEchoIsCurrentUser
                ? Color.burnSignalYellow
                : Color.white.opacity(0.12)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private var orbitEchoDurationText: String {
        "\(max(Int(orbitEchoMessage.blazePulseVoiceDuration.rounded()), 1))''"
    }

    private func orbitEchoToggleVoicePlayback() {
        if orbitEchoIsPlayingVoice {
            orbitEchoStopVoicePlayback()
        } else {
            orbitEchoStartVoicePlayback()
        }
    }

    private func orbitEchoStartVoicePlayback() {
        let orbitEchoVoicePath = orbitEchoMessage.blazePulseVoiceMessageURL
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !orbitEchoVoicePath.isEmpty else {
            return
        }

        guard let orbitEchoVoiceURL = orbitEchoResolvedVoiceURL(
            from: orbitEchoVoicePath
        ) else {
            return
        }

        guard FileManager.default.fileExists(atPath: orbitEchoVoiceURL.path) else {
            return
        }

        do {
            let orbitEchoAudioSession = AVAudioSession.sharedInstance()
            try orbitEchoAudioSession.setCategory(
                .playback,
                mode: .default
            )
            try orbitEchoAudioSession.setActive(true)

            let orbitEchoAudioPlayer = try AVAudioPlayer(
                contentsOf: orbitEchoVoiceURL
            )
            orbitEchoAudioPlayer.prepareToPlay()
            orbitEchoAudioPlayer.play()

            NotificationCenter.default.post(
                name: orbitEchoVoicePlaybackDidStartNotification,
                object: orbitEchoMessage.id
            )

            self.orbitEchoAudioPlayer = orbitEchoAudioPlayer
            orbitEchoIsPlayingVoice = true

            orbitEchoVoicePlaybackTask?.cancel()
            orbitEchoVoicePlaybackTask = Task { @MainActor in
                try? await Task.sleep(
                    nanoseconds: UInt64(
                        max(orbitEchoAudioPlayer.duration, 0.2) * 1_000_000_000
                    )
                )

                guard !Task.isCancelled else {
                    return
                }

                orbitEchoStopVoicePlayback()
            }
        } catch {
            orbitEchoStopVoicePlayback()
        }
    }

    private func orbitEchoStopVoicePlayback() {
        orbitEchoVoicePlaybackTask?.cancel()
        orbitEchoVoicePlaybackTask = nil
        orbitEchoAudioPlayer?.stop()
        orbitEchoAudioPlayer = nil
        orbitEchoIsPlayingVoice = false

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }

    private func orbitEchoResolvedVoiceURL(
        from orbitEchoVoicePath: String
    ) -> URL? {
        if orbitEchoVoicePath.hasPrefix("file://") {
            return URL(string: orbitEchoVoicePath)
        }

        if orbitEchoVoicePath.hasPrefix("/") {
            return URL(fileURLWithPath: orbitEchoVoicePath)
        }

        return nil
    }
}

#Preview("Chat Room") {
    OrbitEchoChatRoomPage(orbitEchoChatRoomID: "chat_room_001")
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
        .environmentObject(BlazeNovaReportSheetHub())
}
