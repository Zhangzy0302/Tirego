import Foundation

struct ForgeLiftTutorial: Codable, Identifiable, Equatable {
    let id: String
    var forgeLiftVideoURL: String
    var forgeLiftCoverURL: String
    var forgeLiftTutorialText: String
    var forgeLiftNeedsPayment: Bool
}

final class ForgeLiftTutorialStore {
    private let forgeLiftFileName = "forge_lift_tutorials.json"

    func forgeLiftCreateTutorial(_ forgeLiftTutorial: ForgeLiftTutorial) throws {
        var forgeLiftTutorials = try forgeLiftFetchAllTutorials()
        forgeLiftTutorials.append(forgeLiftTutorial)
        try PulseCacheStore.pulseCacheSaveCollection(
            forgeLiftTutorials,
            fileName: forgeLiftFileName
        )
    }

    func forgeLiftFetchAllTutorials() throws -> [ForgeLiftTutorial] {
        try PulseCacheStore.pulseCacheLoadCollection(
            fileName: forgeLiftFileName
        )
    }

    func forgeLiftFetchTutorial(
        byID forgeLiftTutorialID: String
    ) throws -> ForgeLiftTutorial? {
        try forgeLiftFetchAllTutorials().first { $0.id == forgeLiftTutorialID }
    }

    func forgeLiftUpdateTutorial(_ forgeLiftTutorial: ForgeLiftTutorial) throws {
        var forgeLiftTutorials = try forgeLiftFetchAllTutorials()
        guard let forgeLiftIndex = forgeLiftTutorials.firstIndex(where: { $0.id == forgeLiftTutorial.id }) else {
            throw PulseCacheStoreError.pulseCacheItemNotFound
        }

        forgeLiftTutorials[forgeLiftIndex] = forgeLiftTutorial
        try PulseCacheStore.pulseCacheSaveCollection(
            forgeLiftTutorials,
            fileName: forgeLiftFileName
        )
    }

    func forgeLiftDeleteTutorial(
        byID forgeLiftTutorialID: String
    ) throws {
        let forgeLiftTutorials = try forgeLiftFetchAllTutorials().filter { $0.id != forgeLiftTutorialID }
        try PulseCacheStore.pulseCacheSaveCollection(
            forgeLiftTutorials,
            fileName: forgeLiftFileName
        )
    }

    func forgeLiftReplaceAllTutorials(
        with forgeLiftTutorials: [ForgeLiftTutorial]
    ) throws {
        try PulseCacheStore.pulseCacheSaveCollection(
            forgeLiftTutorials,
            fileName: forgeLiftFileName
        )
    }
}
