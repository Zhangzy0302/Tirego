import SwiftUI
import PhotosUI
import UIKit

struct BlazeOrbitPostComposerPage: View {
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub

    private let blazeOrbitPostStore = BlazeEchoPostStore()
    private let blazeOrbitUserStore = NovaPulseUserStore()

    @State private var blazeOrbitPostText = ""
    @State private var blazeOrbitSelectedPhotoItems: [PhotosPickerItem] = []
    @State private var blazeOrbitSavedImagePaths: [String] = []
    @FocusState private var blazeOrbitPostFocused: Bool

    private var blazeOrbitTrimmedPostText: String {
        blazeOrbitPostText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    blazeOrbitPostFocused = false
                }

            VStack(alignment: .leading, spacing: 0) {
                BlazeOrbitTopBar(blazeOrbitTitle: "Post")
                    .padding(.top, 16)

                blazeOrbitTextEditorCard
                    .padding(.top, 30)

                blazeOrbitImagePickerCard
                    .padding(.top, 30)

                Spacer()

                PulseActionButton(
                    pulseTitle: "Post",
                    pulseStyle: .burnPrimary,
                    pulseHorizontalPadding: 12,
                    pulseTapAction: {
                        blazeOrbitPostFocused = false
                        blazeOrbitSubmitPost()
                    }
                )
                .padding(.bottom, 42)
            }
            .padding(.horizontal, 18)
        }
        .onChange(of: blazeOrbitSelectedPhotoItems) { blazeOrbitNewItems in
            Task {
                await blazeOrbitHandlePhotoSelection(
                    blazeOrbitNewItems
                )
            }
        }
        .burnStageBackground()
        .preferredColorScheme(.dark)
    }

    private var blazeOrbitTextEditorCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.chalkPureWhite)
                .frame(height: 170)

            TextEditor(text: $blazeOrbitPostText)
                .font(.pulseRobotoRegular(size: 14))
                .foregroundStyle(Color.chalkInk)
                .tint(.black)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(height: 170)
                .focused($blazeOrbitPostFocused)

            if blazeOrbitPostText.isEmpty {
                Text("Say something...")
                    .font(.pulsePlaceholderText(size: 14))
                    .foregroundStyle(Color.repPlaceholderGray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .allowsHitTesting(false)
            }
        }
    }

    private var blazeOrbitImagePickerCard: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                PhotosPicker(
                    selection: $blazeOrbitSelectedPhotoItems,
                    maxSelectionCount: 3,
                    matching: .images
                ) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.chalkPureWhite)
                        .frame(width: 135, height: 165)
                        .overlay {
                            Circle()
                                .fill(Color.burnSignalYellow)
                                .frame(width: 46, height: 46)
                                .overlay {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(Color.chalkJetBlack)
                                }
                        }
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        blazeOrbitPostFocused = false
                    }
                )

                ForEach(Array(blazeOrbitSavedImagePaths.enumerated()), id: \.offset) { blazeOrbitIndex, blazeOrbitImagePath in
                    ZStack(alignment: .topTrailing) {
                        OrbitNovaSmartImage(
                            orbitNovaImagePath: blazeOrbitImagePath
                        ) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.chalkPureWhite.opacity(0.12))
                                .overlay {
                                    Image(systemName: "photo")
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundStyle(Color.chalkMist)
                                }
                        }
                        .frame(width: 135, height: 165)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 20,
                                style: .continuous
                            )
                        )

                        Button(action: {
                            blazeOrbitDeleteSelectedImage(
                                at: blazeOrbitIndex
                            )
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.chalkPureWhite)
                                .frame(width: 26, height: 26)
                                .background(Color.black.opacity(0.72))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                        .padding(.trailing, 8)
                    }
                }
            }
        }
    }

    private func blazeOrbitHandlePhotoSelection(
        _ blazeOrbitItems: [PhotosPickerItem]
    ) async {
        let blazeOrbitLimitedItems = Array(blazeOrbitItems.prefix(3))
        var blazeOrbitNewImagePaths: [String] = []

        for blazeOrbitItem in blazeOrbitLimitedItems {
            do {
                guard let blazeOrbitImageData = try await blazeOrbitItem.loadTransferable(
                    type: Data.self
                ) else {
                    continue
                }

                let blazeOrbitSavedPath = try blazeOrbitSaveImageDataToLocal(
                    blazeOrbitImageData
                )
                blazeOrbitNewImagePaths.append(blazeOrbitSavedPath)
            } catch {
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Unable to import this image.",
                    style: .error
                )
            }
        }

        blazeOrbitSavedImagePaths = blazeOrbitNewImagePaths
    }

    private func blazeOrbitSaveImageDataToLocal(
        _ blazeOrbitImageData: Data
    ) throws -> String {
        let blazeOrbitBaseDirectory = try PulseCacheStore
            .pulseCacheLocalDataDirectory()
            .appendingPathComponent(
                "blaze_orbit_post_images",
                isDirectory: true
            )

        try FileManager.default.createDirectory(
            at: blazeOrbitBaseDirectory,
            withIntermediateDirectories: true
        )

        let blazeOrbitFileURL = blazeOrbitBaseDirectory.appendingPathComponent(
            "\(UUID().uuidString).jpg"
        )

        if let blazeOrbitUIImage = UIImage(data: blazeOrbitImageData),
           let blazeOrbitJPEGData = blazeOrbitUIImage.jpegData(
            compressionQuality: 0.9
           ) {
            try blazeOrbitJPEGData.write(to: blazeOrbitFileURL, options: .atomic)
        } else {
            try blazeOrbitImageData.write(to: blazeOrbitFileURL, options: .atomic)
        }

        return blazeOrbitFileURL.path
    }

    private func blazeOrbitDeleteSelectedImage(at blazeOrbitIndex: Int) {
        guard blazeOrbitSavedImagePaths.indices.contains(blazeOrbitIndex) else {
            return
        }

        blazeOrbitSavedImagePaths.remove(at: blazeOrbitIndex)
        if blazeOrbitSelectedPhotoItems.indices.contains(blazeOrbitIndex) {
            blazeOrbitSelectedPhotoItems.remove(at: blazeOrbitIndex)
        }
    }

    private func blazeOrbitSubmitPost() {
        let blazeOrbitContentText = blazeOrbitTrimmedPostText

        guard !blazeOrbitContentText.isEmpty else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please enter something to post.",
                style: .error
            )
            return
        }

        guard (1...3).contains(blazeOrbitSavedImagePaths.count) else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please upload 1 to 3 images.",
                style: .error
            )
            return
        }

        guard let blazeOrbitCurrentUserID = LiftVaultPersistenceStore
            .liftVaultLoadLoggedInUserID()?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !blazeOrbitCurrentUserID.isEmpty else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please log in first.",
                style: .error
            )
            return
        }

        novaPulseFeedbackHub.novaPulseShowLoading(
            message: "Posting..."
        )

        Task { @MainActor in
            do {
                guard try blazeOrbitUserStore.novaPulseFetchUser(
                    byID: blazeOrbitCurrentUserID
                ) != nil else {
                    novaPulseFeedbackHub.novaPulseHideLoading()
                    novaPulseFeedbackHub.novaPulseShowToast(
                        "Current user not found.",
                        style: .error
                    )
                    return
                }

                try? await Task.sleep(nanoseconds: 1_000_000_000)

                let blazeOrbitNewPost = BlazeEchoPost(
                    id: UUID().uuidString,
                    blazeEchoPublisherID: blazeOrbitCurrentUserID,
                    blazeEchoImageList: blazeOrbitSavedImagePaths,
                    blazeEchoContentText: blazeOrbitContentText
                )

                try blazeOrbitPostStore.blazeEchoCreatePost(
                    blazeOrbitNewPost
                )

                novaPulseFeedbackHub.novaPulseHideLoading()
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Post published.",
                    style: .success
                )
                pulseNovaRouter.pulseNovaReplaceTop(
                    with: .forgeDriftPostDetail(
                        forgeDriftPostID: blazeOrbitNewPost.id
                    )
                )
            } catch {
                novaPulseFeedbackHub.novaPulseHideLoading()
                novaPulseFeedbackHub.novaPulseShowToast(
                    "Unable to publish this post.",
                    style: .error
                )
            }
        }
    }
}

#Preview {
    BlazeOrbitPostComposerPage()
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
}
