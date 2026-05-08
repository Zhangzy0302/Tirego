import Foundation

enum LiftVaultPersistenceStore {
    static let liftVaultHasAcceptedEULAKey = "liftVaultHasAcceptedEULA"
    static let liftVaultHasAcceptedEULADefaultValue = false
    static let liftVaultLoggedInUserIDKey = "liftVaultLoggedInUserID"

    static func liftVaultSaveLoggedInUserID(
        _ liftVaultUserID: String?
    ) {
        UserDefaults.standard.set(
            liftVaultUserID,
            forKey: liftVaultLoggedInUserIDKey
        )
    }

    static func liftVaultLoadLoggedInUserID() -> String? {
        UserDefaults.standard.string(forKey: liftVaultLoggedInUserIDKey)
    }

    static func liftVaultClearLoggedInUserID() {
        UserDefaults.standard.removeObject(
            forKey: liftVaultLoggedInUserIDKey
        )
    }
}
