import Foundation

struct OrbitDriftComment: Codable, Identifiable, Equatable {
    let id: String
    var orbitDriftPostID: String
    var orbitDriftPublisherID: String
    var orbitDriftContentText: String
    var orbitDriftCreatedAt: Date
}

final class OrbitDriftCommentStore {
    private let orbitDriftFileName = "orbit_drift_comments.json"

    func orbitDriftCreateComment(_ orbitDriftComment: OrbitDriftComment) throws {
        var orbitDriftComments = try orbitDriftFetchAllComments()
        orbitDriftComments.append(orbitDriftComment)
        try PulseCacheStore.pulseCacheSaveCollection(
            orbitDriftComments,
            fileName: orbitDriftFileName
        )
    }

    func orbitDriftFetchAllComments() throws -> [OrbitDriftComment] {
        try PulseCacheStore.pulseCacheLoadCollection(
            fileName: orbitDriftFileName
        )
    }

    func orbitDriftFetchComment(
        byID orbitDriftCommentID: String
    ) throws -> OrbitDriftComment? {
        try orbitDriftFetchAllComments().first { $0.id == orbitDriftCommentID }
    }

    func orbitDriftFetchComments(
        byPostID orbitDriftPostID: String
    ) throws -> [OrbitDriftComment] {
        try orbitDriftFetchAllComments().filter { $0.orbitDriftPostID == orbitDriftPostID }
    }

    func orbitDriftUpdateComment(_ orbitDriftComment: OrbitDriftComment) throws {
        var orbitDriftComments = try orbitDriftFetchAllComments()
        guard let orbitDriftIndex = orbitDriftComments.firstIndex(where: { $0.id == orbitDriftComment.id }) else {
            throw PulseCacheStoreError.pulseCacheItemNotFound
        }

        orbitDriftComments[orbitDriftIndex] = orbitDriftComment
        try PulseCacheStore.pulseCacheSaveCollection(
            orbitDriftComments,
            fileName: orbitDriftFileName
        )
    }

    func orbitDriftDeleteComment(
        byID orbitDriftCommentID: String
    ) throws {
        let orbitDriftComments = try orbitDriftFetchAllComments().filter { $0.id != orbitDriftCommentID }
        try PulseCacheStore.pulseCacheSaveCollection(
            orbitDriftComments,
            fileName: orbitDriftFileName
        )
    }

    func orbitDriftReplaceAllComments(
        with orbitDriftComments: [OrbitDriftComment]
    ) throws {
        try PulseCacheStore.pulseCacheSaveCollection(
            orbitDriftComments,
            fileName: orbitDriftFileName
        )
    }
}
