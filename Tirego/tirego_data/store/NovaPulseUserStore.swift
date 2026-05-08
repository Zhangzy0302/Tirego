import Foundation

struct NovaPulseUser: Codable, Identifiable, Equatable {
    enum NovaPulseGender: String, Codable, CaseIterable {
        case male
        case female
        case other
        case undisclosed
    }

    let id: String
    var novaPulseEmail: String
    var novaPulsePassword: String
    var novaPulseAvatar: String
    var novaPulseUserName: String
    var novaPulseBirthdayDate: Date
    var novaPulseLocation: String
    var novaPulseGender: NovaPulseGender
    var novaPulseFollowerIDs: [String]
    var novaPulseFollowingIDs: [String]
    var novaPulseBlockedIDs: [String]
    var novaPulsePurchasedTutorialIDs: [String]
    var novaPulseCheckedInDateKeys: [String]
    var novaPulseCheckInStreakCount: Int
    var novaPulseGoldCoinCount: Int
    var novaPulseIsGuest: Bool
}

final class NovaPulseUserStore {
    private let novaPulseFileName = "nova_pulse_users.json"

    func novaPulseCreateUser(_ novaPulseUser: NovaPulseUser) throws {
        var novaPulseUsers = try novaPulseFetchAllUsers()
        novaPulseUsers.append(novaPulseUser)
        try PulseCacheStore.pulseCacheSaveCollection(
            novaPulseUsers,
            fileName: novaPulseFileName
        )
    }

    func novaPulseFetchAllUsers() throws -> [NovaPulseUser] {
        try PulseCacheStore.pulseCacheLoadCollection(
            fileName: novaPulseFileName
        )
    }

    func novaPulseFetchUser(
        byID novaPulseUserID: String
    ) throws -> NovaPulseUser? {
        try novaPulseFetchAllUsers().first { $0.id == novaPulseUserID }
    }

    func novaPulseFetchUser(
        byEmail novaPulseEmail: String
    ) throws -> NovaPulseUser? {
        let novaPulseNormalizedEmail = novaPulseEmail
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return try novaPulseFetchAllUsers().first {
            $0.novaPulseEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            == novaPulseNormalizedEmail
        }
    }

    func novaPulseUpdateUser(_ novaPulseUser: NovaPulseUser) throws {
        var novaPulseUsers = try novaPulseFetchAllUsers()
        guard let novaPulseIndex = novaPulseUsers.firstIndex(where: { $0.id == novaPulseUser.id }) else {
            throw PulseCacheStoreError.pulseCacheItemNotFound
        }

        novaPulseUsers[novaPulseIndex] = novaPulseUser
        try PulseCacheStore.pulseCacheSaveCollection(
            novaPulseUsers,
            fileName: novaPulseFileName
        )
    }

    func novaPulseDeleteUser(
        byID novaPulseUserID: String
    ) throws {
        let novaPulseUsers = try novaPulseFetchAllUsers().filter { $0.id != novaPulseUserID }
        try PulseCacheStore.pulseCacheSaveCollection(
            novaPulseUsers,
            fileName: novaPulseFileName
        )
    }

    func novaPulseReplaceAllUsers(
        with novaPulseUsers: [NovaPulseUser]
    ) throws {
        try PulseCacheStore.pulseCacheSaveCollection(
            novaPulseUsers,
            fileName: novaPulseFileName
        )
    }
}
