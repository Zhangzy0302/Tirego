import Foundation
import CommonCrypto

enum ForgeNovaAESError: LocalizedError {
    case forgeNovaInvalidUTF8Input
    case forgeNovaInvalidHexInput
    case forgeNovaInvalidKeyLength
    case forgeNovaInvalidIVLength
    case forgeNovaCryptFailed(status: CCCryptorStatus)

    var errorDescription: String? {
        switch self {
        case .forgeNovaInvalidUTF8Input:
            return "Unable to encode or decode UTF-8 content."
        case .forgeNovaInvalidHexInput:
            return "The provided hex string is invalid."
        case .forgeNovaInvalidKeyLength:
            return "AES key length must be 16, 24, or 32 bytes."
        case .forgeNovaInvalidIVLength:
            return "AES CBC IV length must be 16 bytes."
        case let .forgeNovaCryptFailed(status):
            return "AES operation failed with status: \(status)."
        }
    }
}

struct ForgeNovaAESCenter {
    static let forgeNovaDefaultKey = "wdsl6weea10byfxb"
    static let forgeNovaDefaultIV = "57bx21ypvla56szp"

    static func forgeNovaEncrypt(
        _ forgeNovaPlainText: String,
        key forgeNovaKey: String = forgeNovaDefaultKey,
        iv forgeNovaIV: String = forgeNovaDefaultIV
    ) throws -> String {
        guard let forgeNovaPlainData = forgeNovaPlainText.data(using: .utf8) else {
            throw ForgeNovaAESError.forgeNovaInvalidUTF8Input
        }

        let forgeNovaCipherData = try forgeNovaCrypt(
            operation: CCOperation(kCCEncrypt),
            inputData: forgeNovaPlainData,
            key: forgeNovaKey,
            iv: forgeNovaIV
        )

        return forgeNovaCipherData.map { String(format: "%02x", $0) }.joined()
    }

    static func forgeNovaDecrypt(
        _ forgeNovaHexCipherText: String,
        key forgeNovaKey: String = forgeNovaDefaultKey,
        iv forgeNovaIV: String = forgeNovaDefaultIV
    ) throws -> String {
        let forgeNovaCipherData = try forgeNovaData(fromHex: forgeNovaHexCipherText)

        let forgeNovaPlainData = try forgeNovaCrypt(
            operation: CCOperation(kCCDecrypt),
            inputData: forgeNovaCipherData,
            key: forgeNovaKey,
            iv: forgeNovaIV
        )

        guard let forgeNovaPlainText = String(data: forgeNovaPlainData, encoding: .utf8) else {
            throw ForgeNovaAESError.forgeNovaInvalidUTF8Input
        }

        return forgeNovaPlainText
    }

    static func forgeNovaEncryptValue(
        _ forgeNovaPlainText: String,
        key forgeNovaKey: String = forgeNovaDefaultKey,
        iv forgeNovaIV: String = forgeNovaDefaultIV,
        fallback forgeNovaFallback: String = ""
    ) -> String {
        (try? forgeNovaEncrypt(
            forgeNovaPlainText,
            key: forgeNovaKey,
            iv: forgeNovaIV
        )) ?? forgeNovaFallback
    }

    static func forgeNovaDecryptValue(
        _ forgeNovaHexCipherText: String,
        key forgeNovaKey: String = forgeNovaDefaultKey,
        iv forgeNovaIV: String = forgeNovaDefaultIV,
        fallback forgeNovaFallback: String = ""
    ) -> String {
        (try? forgeNovaDecrypt(
            forgeNovaHexCipherText,
            key: forgeNovaKey,
            iv: forgeNovaIV
        )) ?? forgeNovaFallback
    }

    private static func forgeNovaCrypt(
        operation forgeNovaOperation: CCOperation,
        inputData forgeNovaInputData: Data,
        key forgeNovaKey: String,
        iv forgeNovaIV: String
    ) throws -> Data {
        let forgeNovaKeyData = Data(forgeNovaKey.utf8)
        let forgeNovaIVData = Data(forgeNovaIV.utf8)

        guard [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256].contains(forgeNovaKeyData.count) else {
            throw ForgeNovaAESError.forgeNovaInvalidKeyLength
        }

        guard forgeNovaIVData.count == kCCBlockSizeAES128 else {
            throw ForgeNovaAESError.forgeNovaInvalidIVLength
        }

        var forgeNovaOutputLength = 0
        var forgeNovaOutputData = Data(
            count: forgeNovaInputData.count + kCCBlockSizeAES128
        )
        let forgeNovaOutputBufferCount = forgeNovaOutputData.count

        let forgeNovaStatus = forgeNovaOutputData.withUnsafeMutableBytes { forgeNovaOutputBytes in
            forgeNovaInputData.withUnsafeBytes { forgeNovaInputBytes in
                forgeNovaKeyData.withUnsafeBytes { forgeNovaKeyBytes in
                    forgeNovaIVData.withUnsafeBytes { forgeNovaIVBytes in
                        CCCrypt(
                            forgeNovaOperation,
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            forgeNovaKeyBytes.baseAddress,
                            forgeNovaKeyData.count,
                            forgeNovaIVBytes.baseAddress,
                            forgeNovaInputBytes.baseAddress,
                            forgeNovaInputData.count,
                            forgeNovaOutputBytes.baseAddress,
                            forgeNovaOutputBufferCount,
                            &forgeNovaOutputLength
                        )
                    }
                }
            }
        }

        guard forgeNovaStatus == kCCSuccess else {
            throw ForgeNovaAESError.forgeNovaCryptFailed(status: forgeNovaStatus)
        }

        forgeNovaOutputData.removeSubrange(forgeNovaOutputLength..<forgeNovaOutputData.count)
        return forgeNovaOutputData
    }

    private static func forgeNovaData(fromHex forgeNovaHex: String) throws -> Data {
        let forgeNovaTrimmedHex = forgeNovaHex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !forgeNovaTrimmedHex.isEmpty,
              forgeNovaTrimmedHex.count.isMultiple(of: 2) else {
            throw ForgeNovaAESError.forgeNovaInvalidHexInput
        }

        var forgeNovaData = Data(capacity: forgeNovaTrimmedHex.count / 2)
        var forgeNovaIndex = forgeNovaTrimmedHex.startIndex

        while forgeNovaIndex < forgeNovaTrimmedHex.endIndex {
            let forgeNovaNextIndex = forgeNovaTrimmedHex.index(forgeNovaIndex, offsetBy: 2)
            let forgeNovaByteString = forgeNovaTrimmedHex[forgeNovaIndex..<forgeNovaNextIndex]

            guard let forgeNovaByte = UInt8(forgeNovaByteString, radix: 16) else {
                throw ForgeNovaAESError.forgeNovaInvalidHexInput
            }

            forgeNovaData.append(forgeNovaByte)
            forgeNovaIndex = forgeNovaNextIndex
        }

        return forgeNovaData
    }
}

extension String {
    func forgeNovaAESEncrypted(
        key forgeNovaKey: String = ForgeNovaAESCenter.forgeNovaDefaultKey,
        iv forgeNovaIV: String = ForgeNovaAESCenter.forgeNovaDefaultIV,
        fallback forgeNovaFallback: String = ""
    ) -> String {
        ForgeNovaAESCenter.forgeNovaEncryptValue(
            self,
            key: forgeNovaKey,
            iv: forgeNovaIV,
            fallback: forgeNovaFallback
        )
    }

    func forgeNovaAESDecrypted(
        key forgeNovaKey: String = ForgeNovaAESCenter.forgeNovaDefaultKey,
        iv forgeNovaIV: String = ForgeNovaAESCenter.forgeNovaDefaultIV,
        fallback forgeNovaFallback: String = ""
    ) -> String {
        ForgeNovaAESCenter.forgeNovaDecryptValue(
            self,
            key: forgeNovaKey,
            iv: forgeNovaIV,
            fallback: forgeNovaFallback
        )
    }
}
