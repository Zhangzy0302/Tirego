import Foundation
import UIKit

enum PulseCacheStoreError: Error {
    case pulseCacheItemNotFound
}

enum PulseCacheStore {
    private static let pulseCacheEncoder: JSONEncoder = {
        let pulseCacheEncoder = JSONEncoder()
        pulseCacheEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        pulseCacheEncoder.dateEncodingStrategy = .iso8601
        return pulseCacheEncoder
    }()

    private static let pulseCacheDecoder: JSONDecoder = {
        let pulseCacheDecoder = JSONDecoder()
        pulseCacheDecoder.dateDecodingStrategy = .iso8601
        return pulseCacheDecoder
    }()

    static func pulseCacheLoadCollection<Item: Codable>(
        fileName pulseCacheFileName: String,
        as pulseCacheType: [Item].Type = [Item].self
    ) throws -> [Item] {
        let pulseCacheURL = try pulseCacheFileURL(fileName: pulseCacheFileName)
        guard FileManager.default.fileExists(atPath: pulseCacheURL.path) else {
            return []
        }

        let pulseCacheData = try Data(contentsOf: pulseCacheURL)
        return try pulseCacheDecoder.decode(pulseCacheType, from: pulseCacheData)
    }

    static func pulseCacheSaveCollection<Item: Codable>(
        _ pulseCacheItems: [Item],
        fileName pulseCacheFileName: String
    ) throws {
        let pulseCacheURL = try pulseCacheFileURL(fileName: pulseCacheFileName)
        let pulseCacheDirectoryURL = pulseCacheURL.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: pulseCacheDirectoryURL.path) {
            try FileManager.default.createDirectory(
                at: pulseCacheDirectoryURL,
                withIntermediateDirectories: true
            )
        }

        let pulseCacheData = try pulseCacheEncoder.encode(pulseCacheItems)
        try pulseCacheData.write(to: pulseCacheURL, options: .atomic)
    }

    static func pulseCacheLocalDataDirectory() throws -> URL {
        try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("TiregoLocalData", isDirectory: true)
    }

    static func pulseCacheSaveImage(
        _ pulseCacheImage: UIImage,
        fileNamePrefix pulseCacheFileNamePrefix: String,
        compressionQuality pulseCacheCompressionQuality: CGFloat = 0.88
    ) throws -> String {
        let pulseCacheImageDirectoryURL = try pulseCacheLocalDataDirectory()
            .appendingPathComponent("profile_images", isDirectory: true)

        if !FileManager.default.fileExists(atPath: pulseCacheImageDirectoryURL.path) {
            try FileManager.default.createDirectory(
                at: pulseCacheImageDirectoryURL,
                withIntermediateDirectories: true
            )
        }

        guard let pulseCacheImageData = pulseCacheImage.jpegData(
            compressionQuality: pulseCacheCompressionQuality
        ) else {
            throw PulseCacheStoreError.pulseCacheItemNotFound
        }

        let pulseCacheFileURL = pulseCacheImageDirectoryURL.appendingPathComponent(
            "\(pulseCacheFileNamePrefix)_\(UUID().uuidString.lowercased()).jpg"
        )

        try pulseCacheImageData.write(to: pulseCacheFileURL, options: .atomic)
        return pulseCacheFileURL.path
    }

    private static func pulseCacheFileURL(fileName pulseCacheFileName: String) throws -> URL {
        return try pulseCacheLocalDataDirectory()
            .appendingPathComponent(pulseCacheFileName)
    }
}
