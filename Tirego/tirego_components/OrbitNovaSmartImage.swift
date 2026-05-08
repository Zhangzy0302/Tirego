import SwiftUI
import UIKit

struct OrbitNovaSmartImage<OrbitNovaPlaceholder: View>: View {
    private enum OrbitNovaImageSource {
        case remote(URL)
        case localFile(String)
        case asset(String)
        case unavailable
    }

    let orbitNovaImagePath: String
    var orbitNovaContentMode: ContentMode = .fill
    @ViewBuilder let orbitNovaPlaceholder: () -> OrbitNovaPlaceholder

    init(
        orbitNovaImagePath: String,
        orbitNovaContentMode: ContentMode = .fill,
        @ViewBuilder orbitNovaPlaceholder: @escaping () -> OrbitNovaPlaceholder = {
            OrbitNovaSmartImageFallbackView()
        }
    ) {
        self.orbitNovaImagePath = orbitNovaImagePath
        self.orbitNovaContentMode = orbitNovaContentMode
        self.orbitNovaPlaceholder = orbitNovaPlaceholder
    }

    var body: some View {
        Group {
            switch orbitNovaResolvedSource {
            case let .remote(orbitNovaURL):
                AsyncImage(url: orbitNovaURL) { orbitNovaPhase in
                    switch orbitNovaPhase {
                    case let .success(orbitNovaImage):
                        orbitNovaConfiguredImageView(orbitNovaImage)
                    case .empty, .failure:
                        orbitNovaPlaceholder()
                    @unknown default:
                        orbitNovaPlaceholder()
                    }
                }
            case let .localFile(orbitNovaFilePath):
                if let orbitNovaUIImage = UIImage(contentsOfFile: orbitNovaFilePath) {
                    orbitNovaConfiguredImageView(Image(uiImage: orbitNovaUIImage))
                } else {
                    orbitNovaPlaceholder()
                }
            case let .asset(orbitNovaAssetName):
                if UIImage(named: orbitNovaAssetName) != nil {
                    orbitNovaConfiguredImageView(Image(orbitNovaAssetName))
                } else {
                    orbitNovaPlaceholder()
                }
            case .unavailable:
                orbitNovaPlaceholder()
            }
        }
    }

    private var orbitNovaResolvedSource: OrbitNovaImageSource {
        let orbitNovaTrimmedPath = orbitNovaImagePath.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !orbitNovaTrimmedPath.isEmpty else {
            return .unavailable
        }

        if let orbitNovaURL = URL(string: orbitNovaTrimmedPath),
           let orbitNovaScheme = orbitNovaURL.scheme?.lowercased() {
            if orbitNovaScheme == "http" || orbitNovaScheme == "https" {
                return .remote(orbitNovaURL)
            }

            if orbitNovaScheme == "file" {
                return .localFile(orbitNovaURL.path)
            }
        }

        if orbitNovaTrimmedPath.hasPrefix("/") {
            return .localFile(orbitNovaTrimmedPath)
        }

        return .asset(orbitNovaTrimmedPath)
    }

    private func orbitNovaConfiguredImageView(_ orbitNovaImage: Image) -> some View {
        orbitNovaImage
            .resizable()
            .aspectRatio(contentMode: orbitNovaContentMode)
    }
}

struct OrbitNovaSmartImageFallbackView: View {
    var body: some View {
        ZStack {
            Color.white.opacity(0.08)

            Image(systemName: "photo")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.chalkMist)
        }
    }
}

#Preview("Asset") {
    OrbitNovaSmartImage(orbitNovaImagePath: "TIREGOCoin")
        .frame(width: 120, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .burnStageBackground()
}
