import Foundation

struct BlazePulseChatMessage: Codable, Identifiable, Equatable {
    let id: String
    var blazePulseChatRoomID: String
    var blazePulseSenderUserID: String
    var blazePulseTextMessage: String
    var blazePulseVoiceMessageURL: String
    var blazePulseVoiceDuration: TimeInterval
    var blazePulseSentAt: Date
}

final class BlazePulseChatMessageStore {
    private let blazePulseFileName = "blaze_pulse_chat_messages.json"

    func blazePulseCreateChatMessage(_ blazePulseChatMessage: BlazePulseChatMessage) throws {
        var blazePulseChatMessages = try blazePulseFetchAllChatMessages()
        blazePulseChatMessages.append(blazePulseChatMessage)
        try PulseCacheStore.pulseCacheSaveCollection(
            blazePulseChatMessages,
            fileName: blazePulseFileName
        )
    }

    func blazePulseFetchAllChatMessages() throws -> [BlazePulseChatMessage] {
        try PulseCacheStore.pulseCacheLoadCollection(
            fileName: blazePulseFileName
        )
    }

    func blazePulseFetchChatMessage(
        byID blazePulseChatMessageID: String
    ) throws -> BlazePulseChatMessage? {
        try blazePulseFetchAllChatMessages().first { $0.id == blazePulseChatMessageID }
    }

    func blazePulseFetchChatMessages(
        byChatRoomID blazePulseChatRoomID: String
    ) throws -> [BlazePulseChatMessage] {
        try blazePulseFetchAllChatMessages()
            .filter { $0.blazePulseChatRoomID == blazePulseChatRoomID }
            .sorted { $0.blazePulseSentAt < $1.blazePulseSentAt }
    }

    func blazePulseFetchLatestChatMessage(
        byChatRoomID blazePulseChatRoomID: String
    ) throws -> BlazePulseChatMessage? {
        try blazePulseFetchChatMessages(byChatRoomID: blazePulseChatRoomID).last
    }

    func blazePulseUpdateChatMessage(_ blazePulseChatMessage: BlazePulseChatMessage) throws {
        var blazePulseChatMessages = try blazePulseFetchAllChatMessages()
        guard let blazePulseIndex = blazePulseChatMessages.firstIndex(where: { $0.id == blazePulseChatMessage.id }) else {
            throw PulseCacheStoreError.pulseCacheItemNotFound
        }

        blazePulseChatMessages[blazePulseIndex] = blazePulseChatMessage
        try PulseCacheStore.pulseCacheSaveCollection(
            blazePulseChatMessages,
            fileName: blazePulseFileName
        )
    }

    func blazePulseDeleteChatMessage(
        byID blazePulseChatMessageID: String
    ) throws {
        let blazePulseChatMessages = try blazePulseFetchAllChatMessages().filter { $0.id != blazePulseChatMessageID }
        try PulseCacheStore.pulseCacheSaveCollection(
            blazePulseChatMessages,
            fileName: blazePulseFileName
        )
    }

    func blazePulseDeleteChatMessages(
        byChatRoomID blazePulseChatRoomID: String
    ) throws {
        let blazePulseChatMessages = try blazePulseFetchAllChatMessages().filter {
            $0.blazePulseChatRoomID != blazePulseChatRoomID
        }
        try PulseCacheStore.pulseCacheSaveCollection(
            blazePulseChatMessages,
            fileName: blazePulseFileName
        )
    }

    func blazePulseReplaceAllChatMessages(
        with blazePulseChatMessages: [BlazePulseChatMessage]
    ) throws {
        try PulseCacheStore.pulseCacheSaveCollection(
            blazePulseChatMessages,
            fileName: blazePulseFileName
        )
    }
}
