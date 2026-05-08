import Foundation

enum ForgeNovaAccountCenter {
    static func forgeNovaDeleteAccount(
        forgeNovaUserID: String,
        novaPulseUserStore: NovaPulseUserStore = NovaPulseUserStore(),
        blazeEchoPostStore: BlazeEchoPostStore = BlazeEchoPostStore(),
        orbitDriftCommentStore: OrbitDriftCommentStore = OrbitDriftCommentStore(),
        echoNovaChatRoomStore: EchoNovaChatRoomStore = EchoNovaChatRoomStore(),
        blazePulseChatMessageStore: BlazePulseChatMessageStore = BlazePulseChatMessageStore()
    ) throws {
        let forgeNovaPosts = try blazeEchoPostStore.blazeEchoFetchAllPosts()
        let forgeNovaPostIDsToDelete = Set(
            forgeNovaPosts
                .filter { $0.blazeEchoPublisherID == forgeNovaUserID }
                .map(\.id)
        )

        let forgeNovaFilteredPosts = forgeNovaPosts.filter {
            $0.blazeEchoPublisherID != forgeNovaUserID
        }
        try blazeEchoPostStore.blazeEchoReplaceAllPosts(
            with: forgeNovaFilteredPosts
        )

        let forgeNovaComments = try orbitDriftCommentStore.orbitDriftFetchAllComments()
        let forgeNovaFilteredComments = forgeNovaComments.filter {
            $0.orbitDriftPublisherID != forgeNovaUserID
            && !forgeNovaPostIDsToDelete.contains($0.orbitDriftPostID)
        }
        try orbitDriftCommentStore.orbitDriftReplaceAllComments(
            with: forgeNovaFilteredComments
        )

        let forgeNovaChatRooms = try echoNovaChatRoomStore.echoNovaFetchAllChatRooms()
        let forgeNovaChatRoomIDsToDelete = Set(
            forgeNovaChatRooms
                .filter { $0.echoNovaMemberUserIDs.contains(forgeNovaUserID) }
                .map(\.id)
        )
        let forgeNovaFilteredChatRooms = forgeNovaChatRooms.filter {
            !$0.echoNovaMemberUserIDs.contains(forgeNovaUserID)
        }
        try echoNovaChatRoomStore.echoNovaReplaceAllChatRooms(
            with: forgeNovaFilteredChatRooms
        )

        let forgeNovaChatMessages = try blazePulseChatMessageStore.blazePulseFetchAllChatMessages()
        let forgeNovaFilteredChatMessages = forgeNovaChatMessages.filter {
            $0.blazePulseSenderUserID != forgeNovaUserID
            && !forgeNovaChatRoomIDsToDelete.contains($0.blazePulseChatRoomID)
        }
        try blazePulseChatMessageStore.blazePulseReplaceAllChatMessages(
            with: forgeNovaFilteredChatMessages
        )

        var forgeNovaUsers = try novaPulseUserStore.novaPulseFetchAllUsers()
        forgeNovaUsers.removeAll { $0.id == forgeNovaUserID }
        forgeNovaUsers = forgeNovaUsers.map { forgeNovaUser in
            var forgeNovaUpdatedUser = forgeNovaUser
            forgeNovaUpdatedUser.novaPulseFollowerIDs.removeAll {
                $0 == forgeNovaUserID
            }
            forgeNovaUpdatedUser.novaPulseFollowingIDs.removeAll {
                $0 == forgeNovaUserID
            }
            forgeNovaUpdatedUser.novaPulseBlockedIDs.removeAll {
                $0 == forgeNovaUserID
            }
            return forgeNovaUpdatedUser
        }
        try novaPulseUserStore.novaPulseReplaceAllUsers(
            with: forgeNovaUsers
        )

        LiftVaultPersistenceStore.liftVaultClearLoggedInUserID()
    }

    static func forgeNovaLogOutAccount() {
        LiftVaultPersistenceStore.liftVaultClearLoggedInUserID()
    }
}
