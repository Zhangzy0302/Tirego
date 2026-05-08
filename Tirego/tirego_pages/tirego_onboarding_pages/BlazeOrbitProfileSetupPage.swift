import PhotosUI
import SwiftUI

struct BlazeOrbitProfileSetupPage: View {
    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub
    private let blazeOrbitUserStore = NovaPulseUserStore()
    let blazeOrbitEmail: String
    let blazeOrbitPassword: String

    private enum BlazeOrbitGenderOption: String, CaseIterable {
        case male = "Male"
        case female = "Female"

        var blazeOrbitSymbolName: String {
            switch self {
            case .male:
                return "TIREGOMale"
            case .female:
                return "TIREGOFemale"
            }
        }
    }

    @State private var blazeOrbitNickname = ""
    @State private var blazeOrbitBirthday = Date(timeIntervalSince1970: 1_041_897_600)
    @State private var blazeOrbitLocation = "La"
    @State private var blazeOrbitGender: BlazeOrbitGenderOption = .male
    @State private var blazeOrbitShowsBirthdayPicker = false
    @State private var blazeOrbitShowsLocationPicker = false
    @State private var blazeOrbitAvatarPickerItem: PhotosPickerItem?
    @State private var blazeOrbitAvatarPath = ""
    @FocusState private var blazeOrbitNicknameFocused: Bool

    private let blazeOrbitLocationOptions = ["La", "New York", "San Francisco", "Chicago", "Seattle"]

    init(
        blazeOrbitEmail: String = "",
        blazeOrbitPassword: String = ""
    ) {
        self.blazeOrbitEmail = blazeOrbitEmail
        self.blazeOrbitPassword = blazeOrbitPassword
    }

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    blazeOrbitNicknameFocused = false
                }

            VStack(alignment: .leading, spacing: 0) {
                BlazeOrbitTopBar()

                blazeOrbitAvatarSection
                    .padding(.top, 18)

                blazeOrbitFormSection
                    .padding(.top, 32)

                PulseActionButton(
                    pulseTitle: "Save",
                    pulseStyle: .burnPrimary,
                    pulseHorizontalPadding: 11,
                    pulseTapAction: {
                        blazeOrbitNicknameFocused = false
                        blazeOrbitHandleSave()
                    }
                )
                .padding(.top, 44)

                Spacer()
            }
            .padding(.horizontal, 19)
        }
        .sheet(isPresented: $blazeOrbitShowsBirthdayPicker) {
            NavigationStack {
                VStack {
                    DatePicker(
                        "",
                        selection: $blazeOrbitBirthday,
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
                            blazeOrbitShowsBirthdayPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.height(320)])
        }
        .sheet(isPresented: $blazeOrbitShowsLocationPicker) {
            NavigationStack {
                List(blazeOrbitLocationOptions, id: \.self) { blazeOrbitCityName in
                    Button(action: {
                        blazeOrbitLocation = blazeOrbitCityName
                        blazeOrbitShowsLocationPicker = false
                    }) {
                        HStack {
                            Text(blazeOrbitCityName)
                                .foregroundStyle(Color.white)

                            Spacer()

                            if blazeOrbitLocation == blazeOrbitCityName {
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
        .onChange(of: blazeOrbitAvatarPickerItem) { blazeOrbitNewItem in
            guard let blazeOrbitNewItem else {
                return
            }

            blazeOrbitHandleAvatarSelection(blazeOrbitNewItem)
        }
    }

    private var blazeOrbitAvatarSection: some View {
        HStack {
            Spacer()
            PhotosPicker(
                selection: $blazeOrbitAvatarPickerItem,
                matching: .images
            ) {
                ZStack(alignment: .bottomTrailing) {
                    OrbitNovaSmartImage(
                        orbitNovaImagePath: blazeOrbitDisplayAvatarPath
                    ) {
                        Circle()
                            .fill(Color.white.opacity(0.96))
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 34))
                                    .foregroundStyle(Color.black.opacity(0.22))
                            }
                    }
                        .frame(width: 98, height: 98)
                        .clipShape(Circle())
                    Image("TIREGOEditCircle")
                        .resizable()
                        .frame(width: 26, height: 26)
                    
                }
            }
            .buttonStyle(.plain)
            

            Spacer()
        }
    }

    private var blazeOrbitFormSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            blazeOrbitInputBlock(
                title: "Nlckname:"
            ) {
                CoreLiftEntryField(
                    coreLiftPlaceholder: "Please enter",
                    coreLiftText: $blazeOrbitNickname,
                    coreLiftFocusState: $blazeOrbitNicknameFocused
                )
            }

            blazeOrbitInputBlock(
                title: "Birthday:"
            ) {
                BlazeOrbitSelectField(
                    blazeOrbitValueText: blazeOrbitBirthdayText,
                    blazeOrbitTapAction: {
                        blazeOrbitNicknameFocused = false
                        blazeOrbitShowsBirthdayPicker = true
                    }
                )
            }

            blazeOrbitInputBlock(
                title: "Location:"
            ) {
                BlazeOrbitSelectField(
                    blazeOrbitValueText: blazeOrbitLocation,
                    blazeOrbitTapAction: {
                        blazeOrbitNicknameFocused = false
                        blazeOrbitShowsLocationPicker = true
                    }
                )
            }

            VStack(alignment: .leading, spacing: 17) {
                Text("Gender:")
                    .font(.pulseRobotoBold(size: 15))
                    .foregroundStyle(Color.chalkPureWhite)

                HStack(spacing: 54) {
                    ForEach(BlazeOrbitGenderOption.allCases, id: \.self) { blazeOrbitOption in
                        BlazeOrbitGenderBadge(
                            blazeOrbitTitle: blazeOrbitOption.rawValue,
                            blazeOrbitSymbolName: blazeOrbitOption.blazeOrbitSymbolName,
                            blazeOrbitIsSelected: blazeOrbitGender == blazeOrbitOption,
                            blazeOrbitTapAction: {
                                blazeOrbitNicknameFocused = false
                                blazeOrbitGender = blazeOrbitOption
                            }
                        )
                    }
                }
                .padding(.leading, 7)
            }
        }
    }

    private func blazeOrbitInputBlock<BlazeOrbitContent: View>(
        title: String,
        @ViewBuilder content: () -> BlazeOrbitContent
    ) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(title)
                .font(.pulseRobotoBold(size: 15))
                .foregroundStyle(Color.chalkPureWhite)

            content()
        }
    }

    private var blazeOrbitBirthdayText: String {
        let blazeOrbitFormatter = DateFormatter()
        blazeOrbitFormatter.dateFormat = "yyyy-MM-dd"
        return blazeOrbitFormatter.string(from: blazeOrbitBirthday)
    }

    private var blazeOrbitDisplayAvatarPath: String {
        blazeOrbitAvatarPath.isEmpty ? "TIREGODefaultAvatar" : blazeOrbitAvatarPath
    }

    private func blazeOrbitHandleSave() {
        let blazeOrbitNormalizedNickname = blazeOrbitNickname
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let blazeOrbitNormalizedEmail = blazeOrbitEmail
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let blazeOrbitNormalizedPassword = blazeOrbitPassword
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !blazeOrbitNormalizedEmail.isEmpty, !blazeOrbitNormalizedPassword.isEmpty else {
            blazeOrbitPresentAlert("ac8a089854662b80f16481da253b158382f33474928b96c40083c2d59b9424d1dbb5bb4020d3f2d7cb6997478ee14f2ab45c631e1da4acec727842a0e9fca149".forgeNovaAESDecrypted())
            return
        }

        guard !blazeOrbitNormalizedNickname.isEmpty else {
            blazeOrbitPresentAlert("8ec188fe8bd186835ff7c7ba0157023f5097ab5642ea7295623cee093b4656d3".forgeNovaAESDecrypted())
            return
        }

        novaPulseFeedbackHub.novaPulseShowLoading(message: "Creating account...")

        do {
            if try blazeOrbitUserStore.novaPulseFetchUser(byEmail: blazeOrbitNormalizedEmail) != nil {
                novaPulseFeedbackHub.novaPulseHideLoading()
                blazeOrbitPresentAlert("ab68297ee65143282de11448c9763876ea963caf70d7fae382f25305d77998157c2527eed88073f1a95695c397f6012b".forgeNovaAESDecrypted())
                return
            }

            let blazeOrbitNewUser = NovaPulseUser(
                id: "user_\(UUID().uuidString.lowercased())",
                novaPulseEmail: blazeOrbitNormalizedEmail,
                novaPulsePassword: blazeOrbitNormalizedPassword,
                novaPulseAvatar: blazeOrbitDisplayAvatarPath,
                novaPulseUserName: blazeOrbitNormalizedNickname,
                novaPulseBirthdayDate: blazeOrbitBirthday,
                novaPulseLocation: blazeOrbitLocation,
                novaPulseGender: blazeOrbitMappedGender,
                novaPulseFollowerIDs: [],
                novaPulseFollowingIDs: [],
                novaPulseBlockedIDs: [],
                novaPulsePurchasedTutorialIDs: [],
                novaPulseCheckedInDateKeys: [],
                novaPulseCheckInStreakCount: 0,
                novaPulseGoldCoinCount: 0,
                novaPulseIsGuest: false
            )

            try blazeOrbitUserStore.novaPulseCreateUser(blazeOrbitNewUser)
            LiftVaultPersistenceStore.liftVaultSaveLoggedInUserID(blazeOrbitNewUser.id)
            blazeOrbitHandleSuccessTransition()
        } catch {
            novaPulseFeedbackHub.novaPulseHideLoading()
            blazeOrbitPresentAlert("Unable to complete registration right now.")
        }
    }

    private func blazeOrbitHandleAvatarSelection(
        _ blazeOrbitPickerItem: PhotosPickerItem
    ) {
        Task {
            do {
                guard let blazeOrbitImageData = try await blazeOrbitPickerItem.loadTransferable(
                    type: Data.self
                ), let blazeOrbitImage = UIImage(data: blazeOrbitImageData) else {
                    await MainActor.run {
                        novaPulseFeedbackHub.novaPulseShowToast(
                            "Unable to load this photo.",
                            style: .error
                        )
                    }
                    return
                }

                let blazeOrbitSavedAvatarPath = try PulseCacheStore.pulseCacheSaveImage(
                    blazeOrbitImage,
                    fileNamePrefix: "blaze_orbit_avatar"
                )

                await MainActor.run {
                    blazeOrbitAvatarPath = blazeOrbitSavedAvatarPath
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

    private var blazeOrbitMappedGender: NovaPulseUser.NovaPulseGender {
        switch blazeOrbitGender {
        case .male:
            return .male
        case .female:
            return .female
        }
    }

    private func blazeOrbitPresentAlert(_ blazeOrbitMessage: String) {
        novaPulseFeedbackHub.novaPulseShowToast(
            blazeOrbitMessage,
            style: .error
        )
    }

    private func blazeOrbitHandleSuccessTransition() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            novaPulseFeedbackHub.novaPulseHideLoading()
            novaPulseFeedbackHub.novaPulseShowToast(
                "Registration successful.",
                style: .success
            )
            try? await Task.sleep(nanoseconds: 650_000_000)
            pulseNovaRouter.pulseNovaPresent(.novaTrailTabShell)
        }
    }
}

private struct BlazeOrbitSelectField: View {
    let blazeOrbitValueText: String
    let blazeOrbitTapAction: () -> Void

    var body: some View {
        Button(action: blazeOrbitTapAction) {
            HStack {
                Text(blazeOrbitValueText)
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

private struct BlazeOrbitGenderBadge: View {
    let blazeOrbitTitle: String
    let blazeOrbitSymbolName: String
    let blazeOrbitIsSelected: Bool
    let blazeOrbitTapAction: () -> Void

    var body: some View {
        Button(action: blazeOrbitTapAction) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(blazeOrbitIsSelected ? Color.burnSignalYellow : Color.white)
                        .frame(width: 48, height: 48)

                    Image(blazeOrbitSymbolName)
                        .resizable()
                        .frame(width: 24, height: 24)
                        
                }

                Text(blazeOrbitTitle)
                    .font(.pulseRobotoRegular(size: 13))
                    .foregroundStyle(Color.chalkPureWhite)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BlazeOrbitProfileSetupPage()
        .environmentObject(PulseNovaRouter())
        .environmentObject(NovaPulseFeedbackHub())
}
