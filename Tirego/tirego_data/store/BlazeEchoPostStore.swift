import Foundation

struct BlazeEchoPost: Codable, Identifiable, Equatable {
    let id: String
    var blazeEchoPublisherID: String
    var blazeEchoImageList: [String]
    var blazeEchoContentText: String
}

final class BlazeEchoPostStore {
    private let blazeEchoFileName = "blaze_echo_posts.json"

    func blazeEchoCreatePost(_ blazeEchoPost: BlazeEchoPost) throws {
        var blazeEchoPosts = try blazeEchoFetchAllPosts()
        blazeEchoPosts.append(blazeEchoPost)
        try PulseCacheStore.pulseCacheSaveCollection(
            blazeEchoPosts,
            fileName: blazeEchoFileName
        )
    }

    func blazeEchoFetchAllPosts() throws -> [BlazeEchoPost] {
        try PulseCacheStore.pulseCacheLoadCollection(
            fileName: blazeEchoFileName
        )
    }

    func blazeEchoFetchPost(
        byID blazeEchoPostID: String
    ) throws -> BlazeEchoPost? {
        try blazeEchoFetchAllPosts().first { $0.id == blazeEchoPostID }
    }

    func blazeEchoFetchPosts(
        byPublisherID blazeEchoPublisherID: String
    ) throws -> [BlazeEchoPost] {
        try blazeEchoFetchAllPosts().filter { $0.blazeEchoPublisherID == blazeEchoPublisherID }
    }

    func blazeEchoUpdatePost(_ blazeEchoPost: BlazeEchoPost) throws {
        var blazeEchoPosts = try blazeEchoFetchAllPosts()
        guard let blazeEchoIndex = blazeEchoPosts.firstIndex(where: { $0.id == blazeEchoPost.id }) else {
            throw PulseCacheStoreError.pulseCacheItemNotFound
        }

        blazeEchoPosts[blazeEchoIndex] = blazeEchoPost
        try PulseCacheStore.pulseCacheSaveCollection(
            blazeEchoPosts,
            fileName: blazeEchoFileName
        )
    }

    func blazeEchoDeletePost(
        byID blazeEchoPostID: String
    ) throws {
        let blazeEchoPosts = try blazeEchoFetchAllPosts().filter { $0.id != blazeEchoPostID }
        try PulseCacheStore.pulseCacheSaveCollection(
            blazeEchoPosts,
            fileName: blazeEchoFileName
        )
    }

    func blazeEchoReplaceAllPosts(
        with blazeEchoPosts: [BlazeEchoPost]
    ) throws {
        try PulseCacheStore.pulseCacheSaveCollection(
            blazeEchoPosts,
            fileName: blazeEchoFileName
        )
    }
}
