import Foundation

enum VealvjaiAixVisitorAccessGate {
    static func vealvjaiAixCurrentUser() -> NovaPulseUser? {
        guard let vealvjaiAixLoggedInUserID = LiftVaultPersistenceStore
            .liftVaultLoadLoggedInUserID()?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !vealvjaiAixLoggedInUserID.isEmpty else {
            return nil
        }

        return try? NovaPulseUserStore().novaPulseFetchUser(
            byID: vealvjaiAixLoggedInUserID
        )
    }

    static func vealvjaiAixIsGuestUser() -> Bool {
        vealvjaiAixCurrentUser()?.novaPulseIsGuest == true
    }
}

