import Foundation

struct BlazeNovaBlockResult {
    let blazeNovaCurrentUser: NovaPulseUser
    let blazeNovaWasAlreadyBlocked: Bool
}

enum BlazeNovaBlockCenter {
    static func blazeNovaBlockUser(
        currentUserID blazeNovaCurrentUserID: String,
        targetUserID blazeNovaTargetUserID: String,
        userStore blazeNovaUserStore: NovaPulseUserStore = NovaPulseUserStore()
    ) throws -> BlazeNovaBlockResult {
        guard var blazeNovaCurrentUser = try blazeNovaUserStore.novaPulseFetchUser(
            byID: blazeNovaCurrentUserID
        ) else {
            throw PulseCacheStoreError.pulseCacheItemNotFound
        }

        let blazeNovaTrimmedTargetUserID = blazeNovaTargetUserID
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !blazeNovaTrimmedTargetUserID.isEmpty,
              blazeNovaTrimmedTargetUserID != blazeNovaCurrentUserID else {
            return BlazeNovaBlockResult(
                blazeNovaCurrentUser: blazeNovaCurrentUser,
                blazeNovaWasAlreadyBlocked: true
            )
        }

        let blazeNovaWasAlreadyBlocked = blazeNovaCurrentUser.novaPulseBlockedIDs.contains(
            blazeNovaTrimmedTargetUserID
        )

        if blazeNovaWasAlreadyBlocked {
            return BlazeNovaBlockResult(
                blazeNovaCurrentUser: blazeNovaCurrentUser,
                blazeNovaWasAlreadyBlocked: true
            )
        }

        if !blazeNovaCurrentUser.novaPulseBlockedIDs.contains(
            blazeNovaTrimmedTargetUserID
        ) {
            blazeNovaCurrentUser.novaPulseBlockedIDs.append(
                blazeNovaTrimmedTargetUserID
            )
        }

        blazeNovaCurrentUser.novaPulseFollowingIDs.removeAll {
            $0 == blazeNovaTrimmedTargetUserID
        }
        blazeNovaCurrentUser.novaPulseFollowerIDs.removeAll {
            $0 == blazeNovaTrimmedTargetUserID
        }

        try blazeNovaUserStore.novaPulseUpdateUser(blazeNovaCurrentUser)

        if var blazeNovaTargetUser = try blazeNovaUserStore.novaPulseFetchUser(
            byID: blazeNovaTrimmedTargetUserID
        ) {
            blazeNovaTargetUser.novaPulseFollowerIDs.removeAll {
                $0 == blazeNovaCurrentUserID
            }
            blazeNovaTargetUser.novaPulseFollowingIDs.removeAll {
                $0 == blazeNovaCurrentUserID
            }

            try blazeNovaUserStore.novaPulseUpdateUser(blazeNovaTargetUser)
        }

        return BlazeNovaBlockResult(
            blazeNovaCurrentUser: blazeNovaCurrentUser,
            blazeNovaWasAlreadyBlocked: false
        )
    }
}
