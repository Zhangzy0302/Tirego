import Foundation

struct EchoNovaChatRoom: Codable, Identifiable, Equatable {
    let id: String
    var echoNovaMemberUserIDs: [String]
    var echoNovaLastMessageSentAt: Date
    var echoNovaLastSenderUserID: String
    var echoNovaLastMessageText: String
    var echoNovaUnreadMessageCount: Int
}

final class EchoNovaChatRoomStore {
    private let echoNovaFileName = "echo_nova_chat_rooms.json"

    func echoNovaCreateChatRoom(_ echoNovaChatRoom: EchoNovaChatRoom) throws {
        var echoNovaChatRooms = try echoNovaFetchAllChatRooms()
        echoNovaChatRooms.append(echoNovaChatRoom)
        try PulseCacheStore.pulseCacheSaveCollection(
            echoNovaChatRooms,
            fileName: echoNovaFileName
        )
    }

    func echoNovaFetchAllChatRooms() throws -> [EchoNovaChatRoom] {
        try PulseCacheStore.pulseCacheLoadCollection(
            fileName: echoNovaFileName
        )
    }

    func echoNovaFetchChatRoom(
        byID echoNovaChatRoomID: String
    ) throws -> EchoNovaChatRoom? {
        try echoNovaFetchAllChatRooms().first { $0.id == echoNovaChatRoomID }
    }

    func echoNovaFetchChatRooms(
        byUserID echoNovaUserID: String
    ) throws -> [EchoNovaChatRoom] {
        try echoNovaFetchAllChatRooms()
            .filter { $0.echoNovaMemberUserIDs.contains(echoNovaUserID) }
            .sorted { $0.echoNovaLastMessageSentAt > $1.echoNovaLastMessageSentAt }
    }

    func echoNovaFetchChatRoom(
        byMemberUserIDs echoNovaMemberUserIDs: [String]
    ) throws -> EchoNovaChatRoom? {
        let echoNovaNormalizedMemberIDs = Set(echoNovaMemberUserIDs)

        return try echoNovaFetchAllChatRooms().first {
            Set($0.echoNovaMemberUserIDs) == echoNovaNormalizedMemberIDs
        }
    }

    func echoNovaUpdateChatRoom(_ echoNovaChatRoom: EchoNovaChatRoom) throws {
        var echoNovaChatRooms = try echoNovaFetchAllChatRooms()
        guard let echoNovaIndex = echoNovaChatRooms.firstIndex(where: { $0.id == echoNovaChatRoom.id }) else {
            throw PulseCacheStoreError.pulseCacheItemNotFound
        }

        echoNovaChatRooms[echoNovaIndex] = echoNovaChatRoom
        try PulseCacheStore.pulseCacheSaveCollection(
            echoNovaChatRooms,
            fileName: echoNovaFileName
        )
    }

    func echoNovaDeleteChatRoom(
        byID echoNovaChatRoomID: String
    ) throws {
        let echoNovaChatRooms = try echoNovaFetchAllChatRooms().filter { $0.id != echoNovaChatRoomID }
        try PulseCacheStore.pulseCacheSaveCollection(
            echoNovaChatRooms,
            fileName: echoNovaFileName
        )
    }

    func echoNovaReplaceAllChatRooms(
        with echoNovaChatRooms: [EchoNovaChatRoom]
    ) throws {
        try PulseCacheStore.pulseCacheSaveCollection(
            echoNovaChatRooms,
            fileName: echoNovaFileName
        )
    }
}
