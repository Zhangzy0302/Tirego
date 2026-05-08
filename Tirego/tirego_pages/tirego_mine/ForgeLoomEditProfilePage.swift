import PhotosUI
import SwiftUI

struct ForgeLoomEditProfilePage: View {
    @Environment(\.dismiss) private var forgeLoomDismiss
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub

    private let forgeLoomUserStore = NovaPulseUserStore()

    private enum ForgeLoomGenderOption: String, CaseIterable {
        case male = "Male"
        case female = "Female"

        var forgeLoomSymbolName: String {
            switch self {
            case .male:
                return "TIREGOMale"
            case .female:
                return "TIREGOFemale"
            }
        }
    }

    @State private var forgeLoomNickname = ""
    @State private var forgeLoomBirthday = Date(timeIntervalSince1970: 1_041_897_600)
    @State private var forgeLoomLocation = "La"
    @State private var forgeLoomGender: ForgeLoomGenderOption = .male
    @State private var forgeLoomCurrentUser: NovaPulseUser?
    @State private var forgeLoomShowsBirthdayPicker = false
    @State private var forgeLoomShowsLocationPicker = false
    @State private var forgeLoomAvatarPickerItem: PhotosPickerItem?
    @State private var forgeLoomAvatarPath = ""
    @FocusState private var forgeLoomNicknameFocused: Bool

    private let forgeLoomLocationOptions = ["La", "New York", "San Francisco", "Chicago", "Seattle"]

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    forgeLoomNicknameFocused = false
                }

            VStack(alignment: .leading, spacing: 0) {
                BlazeOrbitTopBar(blazeOrbitTitle: "Edit")

                forgeLoomAvatarSection
                    .padding(.top, 18)

                forgeLoomFormSection
                    .padding(.top, 18)

                PulseActionButton(
                    pulseTitle: "Save",
                    pulseStyle: .burnPrimary,
                    pulseHorizontalPadding: 11,
                    pulseTapAction: {
                        forgeLoomNicknameFocused = false
                        forgeLoomHandleSave()
                    }
                )
                .padding(.top, 44)

                Spacer()
            }
            .padding(.horizontal, 19)
        }
        .sheet(isPresented: $forgeLoomShowsBirthdayPicker) {
            NavigationStack {
                VStack {
                    DatePicker(
                        "",
                        selection: $forgeLoomBirthday,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                .padding(.top, 20)
                .navigationTitle("Birthday")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            forgeLoomShowsBirthdayPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.height(320)])
        }
        .sheet(isPresented: $forgeLoomShowsLocationPicker) {
            NavigationStack {
                List(forgeLoomLocationOptions, id: \.self) { forgeLoomCityName in
                    Button(action: {
                        forgeLoomLocation = forgeLoomCityName
                        forgeLoomShowsLocationPicker = false
                    }) {
                        HStack {
                            Text(forgeLoomCityName)
                                .foregroundStyle(Color.white)

                            Spacer()

                            if forgeLoomLocation == forgeLoomCityName {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.burnSignalYellow)
                            }
                        }.contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .navigationTitle("Location")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium])
        }
        .burnStageBackground()
        .preferredColorScheme(.dark)
        .task {
            forgeLoomLoadCurrentUserProfile()
        }
        .onChange(of: forgeLoomAvatarPickerItem) { forgeLoomNewItem in
            guard let forgeLoomNewItem else {
                return
            }

            forgeLoomHandleAvatarSelection(forgeLoomNewItem)
        }
    }

    private var forgeLoomAvatarSection: some View {
        HStack {
            Spacer()

            ZStack(alignment: .bottomTrailing) {
                OrbitNovaSmartImage(
                    orbitNovaImagePath: forgeLoomDisplayAvatarPath
                ) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.35), Color.orange.opacity(0.65)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(Color.chalkPureWhite.opacity(0.8))
                        }
                }
                .frame(width: 98, height: 98)
                .clipShape(Circle())

                PhotosPicker(
                    selection: $forgeLoomAvatarPickerItem,
                    matching: .images
                ) {
                    Circle()
                        .fill(Color.burnSignalYellow)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.chalkJetBlack)
                        }
                        .offset(x: 4, y: 2)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }

    private var forgeLoomFormSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            forgeLoomInputBlock(title: "Nlckname:") {
                CoreLiftEntryField(
                    coreLiftPlaceholder: "Please enter",
                    coreLiftText: $forgeLoomNickname,
                    coreLiftFocusState: $forgeLoomNicknameFocused
                )
            }

            forgeLoomInputBlock(title: "Birthday:") {
                ForgeLoomSelectField(
                    forgeLoomValueText: forgeLoomBirthdayText,
                    forgeLoomTapAction: {
                        forgeLoomNicknameFocused = false
                        forgeLoomShowsBirthdayPicker = true
                    }
                )
            }

            forgeLoomInputBlock(title: "Location:") {
                ForgeLoomSelectField(
                    forgeLoomValueText: forgeLoomLocation,
                    forgeLoomTapAction: {
                        forgeLoomNicknameFocused = false
                        forgeLoomShowsLocationPicker = true
                    }
                )
            }

            VStack(alignment: .leading, spacing: 17) {
                Text("Gender:")
                    .font(.pulseRobotoBold(size: 15))
                    .foregroundStyle(Color.chalkPureWhite)

                HStack(spacing: 54) {
                    ForEach(ForgeLoomGenderOption.allCases, id: \.self) { forgeLoomOption in
                        ForgeLoomGenderBadge(
                            forgeLoomTitle: forgeLoomOption.rawValue,
                            forgeLoomSymbolName: forgeLoomOption.forgeLoomSymbolName,
                            forgeLoomIsSelected: forgeLoomGender == forgeLoomOption,
                            forgeLoomTapAction: {
                                forgeLoomNicknameFocused = false
                                forgeLoomGender = forgeLoomOption
                            }
                        )
                    }
                }
                .padding(.leading, 7)
            }
        }
    }

    private func forgeLoomInputBlock<ForgeLoomContent: View>(
        title: String,
        @ViewBuilder content: () -> ForgeLoomContent
    ) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(title)
                .font(.pulseRobotoBold(size: 15))
                .foregroundStyle(Color.chalkPureWhite)

            content()
        }
    }

    private var forgeLoomBirthdayText: String {
        let forgeLoomFormatter = DateFormatter()
        forgeLoomFormatter.dateFormat = "yyyy-MM-dd"
        return forgeLoomFormatter.string(from: forgeLoomBirthday)
    }

    private var forgeLoomDisplayAvatarPath: String {
        if !forgeLoomAvatarPath.isEmpty {
            return forgeLoomAvatarPath
        }

        return forgeLoomCurrentUser?.novaPulseAvatar ?? ""
    }

    private func forgeLoomLoadCurrentUserProfile() {
        do {
            guard let forgeLoomLoggedInUserID = LiftVaultPersistenceStore
                .liftVaultLoadLoggedInUserID()?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !forgeLoomLoggedInUserID.isEmpty,
                let forgeLoomUser = try forgeLoomUserStore.novaPulseFetchUser(byID: forgeLoomLoggedInUserID) else {
                return
            }

            forgeLoomCurrentUser = forgeLoomUser
            forgeLoomAvatarPath = forgeLoomUser.novaPulseAvatar
            forgeLoomNickname = forgeLoomUser.novaPulseUserName
            forgeLoomBirthday = forgeLoomUser.novaPulseBirthdayDate
            forgeLoomLocation = forgeLoomUser.novaPulseLocation.isEmpty ? "La" : forgeLoomUser.novaPulseLocation
            forgeLoomGender = forgeLoomGenderOption(from: forgeLoomUser.novaPulseGender)
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load your profile right now.",
                style: .error
            )
        }
    }

    private func forgeLoomHandleSave() {
        guard var forgeLoomCurrentUser else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load your profile right now.",
                style: .error
            )
            return
        }

        let forgeLoomNormalizedNickname = forgeLoomNickname
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let forgeLoomNormalizedLocation = forgeLoomLocation
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !forgeLoomNormalizedNickname.isEmpty else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please enter your nickname.",
                style: .error
            )
            return
        }

        forgeLoomCurrentUser.novaPulseUserName = forgeLoomNormalizedNickname
        forgeLoomCurrentUser.novaPulseAvatar = forgeLoomDisplayAvatarPath
        forgeLoomCurrentUser.novaPulseBirthdayDate = forgeLoomBirthday
        forgeLoomCurrentUser.novaPulseLocation = forgeLoomNormalizedLocation
        forgeLoomCurrentUser.novaPulseGender = forgeLoomMappedGender

        do {
            try forgeLoomUserStore.novaPulseUpdateUser(forgeLoomCurrentUser)
            self.forgeLoomCurrentUser = forgeLoomCurrentUser
            novaPulseFeedbackHub.novaPulseShowToast(
                "Profile updated successfully.",
                style: .success
            )
            forgeLoomDismiss()
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to save your profile right now.",
                style: .error
            )
        }
    }

    private func forgeLoomGenderOption(
        from forgeLoomGender: NovaPulseUser.NovaPulseGender
    ) -> ForgeLoomGenderOption {
        switch forgeLoomGender {
        case .female:
            return .female
        case .male, .other, .undisclosed:
            return .male
        }
    }

    private func forgeLoomHandleAvatarSelection(
        _ forgeLoomPickerItem: PhotosPickerItem
    ) {
        Task {
            do {
                guard let forgeLoomImageData = try await forgeLoomPickerItem.loadTransferable(
                    type: Data.self
                ), let forgeLoomImage = UIImage(data: forgeLoomImageData) else {
                    await MainActor.run {
                        novaPulseFeedbackHub.novaPulseShowToast(
                            "Unable to load this photo.",
                            style: .error
                        )
                    }
                    return
                }

                let forgeLoomSavedAvatarPath = try PulseCacheStore.pulseCacheSaveImage(
                    forgeLoomImage,
                    fileNamePrefix: "forge_loom_avatar"
                )

                await MainActor.run {
                    forgeLoomAvatarPath = forgeLoomSavedAvatarPath
                }
            } catch {
                await MainActor.run {
                    novaPulseFeedbackHub.novaPulseShowToast(
                        "Unable to update your avatar right now.",
                        style: .error
                    )
                }
            }
        }
    }

    private var forgeLoomMappedGender: NovaPulseUser.NovaPulseGender {
        switch forgeLoomGender {
        case .male:
            return .male
        case .female:
            return .female
        }
    }
}

private struct ForgeLoomSelectField: View {
    let forgeLoomValueText: String
    let forgeLoomTapAction: () -> Void

    var body: some View {
        Button(action: forgeLoomTapAction) {
            HStack {
                Text(forgeLoomValueText)
                    .font(.pulseInputText())
                    .foregroundStyle(Color.chalkInk)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.3))
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Color.white)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct ForgeLoomGenderBadge: View {
    let forgeLoomTitle: String
    let forgeLoomSymbolName: String
    let forgeLoomIsSelected: Bool
    let forgeLoomTapAction: () -> Void

    var body: some View {
        Button(action: forgeLoomTapAction) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(forgeLoomIsSelected ? Color.burnSignalYellow : Color.white)
                        .frame(width: 48, height: 48)

                    Image(forgeLoomSymbolName)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.chalkJetBlack)
                }

                Text(forgeLoomTitle)
                    .font(.pulseRobotoRegular(size: 13))
                    .foregroundStyle(Color.chalkPureWhite)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ForgeLoomEditProfilePage()
        .environmentObject(NovaPulseFeedbackHub())
}
