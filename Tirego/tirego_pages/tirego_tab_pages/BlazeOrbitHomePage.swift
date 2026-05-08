import SwiftUI

struct BlazeOrbitHomePage: View {
    private let blazeOrbitMinimumTutorialCardHeight: CGFloat = 156
    private let blazeOrbitTutorialCardWidth: CGFloat = 268
    private let blazeOrbitBottomNavigationReservedHeight: CGFloat = 112

    @EnvironmentObject private var pulseNovaRouter: PulseNovaRouter
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub
    @EnvironmentObject private var vealvjaiAixVisitorGateHub: VealvjaiAixVisitorGateHub

    private let blazeOrbitUserStore = NovaPulseUserStore()
    private let blazeOrbitTutorialStore = ForgeLiftTutorialStore()

    @State private var blazeOrbitCurrentUser: NovaPulseUser?
    @State private var blazeOrbitTutorialItems: [ForgeLiftTutorial] = []
    @State private var blazeOrbitCurrentWeekDates: [Date] = []

    var body: some View {
        GeometryReader { blazeOrbitProxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    blazeOrbitHeader
                        .padding(.top, 20)
                        .padding(.horizontal, 21)

                    blazeOrbitCheckinCard
                        .padding(.top, 24)
                        .padding(.horizontal, 21)

                    Text("Video tutorial")
                        .font(.flexCarterDisplay(size: 18, relativeTo: .title))
                        .foregroundStyle(Color.burnSignalYellow)
                        .padding(.top, 32)
                        .padding(.horizontal, 21)

                    blazeOrbitTutorialRow(
                        blazeOrbitCardHeight: blazeOrbitTutorialCardHeight(
                            in: blazeOrbitProxy
                        )
                    )
                    .padding(.top, 14)
                }
                .frame(
                    minHeight: blazeOrbitContentMinHeight(
                        in: blazeOrbitProxy
                    ),
                    alignment: .top
                )
                .padding(.bottom, blazeOrbitBottomNavigationReservedHeight)
            }
        }
        .task {
            blazeOrbitRefreshHomeData()
        }
        .refreshable {
            blazeOrbitRefreshHomeData()
        }
    }

    private var blazeOrbitHeader: some View {
        HStack {
            Text("Tirego")
                .font(.flexCarterDisplay(size: 32, relativeTo: .largeTitle))
                .foregroundStyle(Color.burnSignalYellow)

            Spacer()

            OrbitNovaSmartImage(
                orbitNovaImagePath: blazeOrbitCurrentUser?.novaPulseAvatar ?? ""
            ) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.85), Color.yellow.opacity(0.45)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.chalkPureWhite)
                    }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
        }
    }

    private var blazeOrbitCheckinCard: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .top) {
                Text("Check-in")
                    .font(.flexCarterDisplay(size: 18, relativeTo: .title2))
                    .foregroundStyle(Color.burnSignalYellow)
                    .padding(.top, 16)

                Spacer()

                Image("TIREGODateCalendar")
                    .resizable()
                    .frame(width: 76, height: 76)
            }
            .padding(.horizontal, 18)
            

            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    ForEach(blazeOrbitCurrentWeekDates, id: \.self) { blazeOrbitDate in
                        let blazeOrbitChecked = blazeOrbitIsCheckedIn(on: blazeOrbitDate)
                        let blazeOrbitIsToday = blazeOrbitIsToday(blazeOrbitDate)

                        VStack(spacing: 8) {
                            Text(blazeOrbitWeekdaySymbol(for: blazeOrbitDate))
                                .font(.pulseRobotoRegular(size: 12))
                                .foregroundStyle(
                                    blazeOrbitIsToday
                                    ? Color.burnSignalYellow
                                    : Color.chalkPureWhite.opacity(0.55)
                                )

                            Text(blazeOrbitDayNumberText(for: blazeOrbitDate))
                                .font(.pulseRobotoBold(size: 13))
                                .foregroundStyle(
                                    blazeOrbitChecked
                                    ? Color.chalkJetBlack
                                    : Color.chalkPureWhite
                                )
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(
                                            blazeOrbitChecked
                                            ? Color.burnSignalYellow
                                            : Color.white.opacity(blazeOrbitIsToday ? 0.24 : 0.15)
                                        )
                                )
                        }
                    }
                }

                PulseActionButton(
                    pulseTitle: blazeOrbitCheckInButtonTitle,
                    pulseStyle: blazeOrbitHasCheckedInToday ? .ciwaonCheckStyle : .burnPrimary,
                    
                    pulseHorizontalPadding: 0,
                    pulseHeight: 48,
                    pulseLabelFont: .pulseRobotoBold(size: 16),
                    pulseTapAction: blazeOrbitHandleCheckIn
                )
            }
            .padding(16)
            .padding(.top, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 52 / 255, green: 50 / 255, blue: 29 / 255))
            )
            .padding(.top, 46)
        }
        .frame(height: 216)
        .background(Color(red: 18 / 255, green: 18 / 255, blue: 6 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func blazeOrbitTutorialRow(
        blazeOrbitCardHeight: CGFloat
    ) -> some View {
        Group {
            if blazeOrbitTutorialItems.isEmpty {
                blazeOrbitTutorialEmptyState(
                    blazeOrbitCardHeight: blazeOrbitCardHeight
                )
                    .padding(.horizontal, 21)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(blazeOrbitTutorialItems, id: \.id) { blazeOrbitTutorial in
                            blazeOrbitTutorialCard(
                                blazeOrbitTutorial,
                                blazeOrbitCardHeight: blazeOrbitCardHeight
                            )
                        }
                    }
                    .padding(.horizontal, 21)
                }
            }
        }
        .frame(height: blazeOrbitCardHeight)
    }

    private func blazeOrbitTutorialEmptyState(
        blazeOrbitCardHeight: CGFloat
    ) -> some View {
        TirevOxaejjEmptyData()
            .frame(height: blazeOrbitCardHeight)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func blazeOrbitTutorialCard(
        _ blazeOrbitTutorial: ForgeLiftTutorial,
        blazeOrbitCardHeight: CGFloat
    ) -> some View {
        Button(action: {
            pulseNovaRouter.pulseNovaPush(
                .forgePulseTutorialDetail(
                    forgePulseTutorialID: blazeOrbitTutorial.id
                )
            )
        }) {
            ZStack(alignment: .bottomLeading) {
                OrbitNovaSmartImage(
                    orbitNovaImagePath: blazeOrbitTutorial.forgeLiftCoverURL
                ) {
                    LinearGradient(
                        colors: blazeOrbitTutorial.forgeLiftNeedsPayment
                        ? [Color.gray, Color.black]
                        : [Color.blue.opacity(0.82), Color.white.opacity(0.86)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .frame(
                    width: blazeOrbitTutorialCardWidth,
                    height: blazeOrbitCardHeight
                )
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(blazeOrbitTutorial.forgeLiftNeedsPayment ? "Advanced" : "Beginner")
                            .font(.pulseRobotoBold(size: 9))
                            .foregroundStyle(Color.chalkJetBlack)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                !blazeOrbitTutorial.forgeLiftNeedsPayment
                                ? Color.chalkPureWhite
                                : Color.burnSignalYellow
                            )
                            .clipShape(Capsule())

                        Spacer()
                    }

                    Spacer()

                    HStack(alignment: .bottom) {
                        Text(blazeOrbitTutorial.forgeLiftTutorialText)
                            .font(.pulseRobotoRegular(size: 12))
                            .foregroundStyle(Color.chalkPureWhite)
                            .lineLimit(2)

                        Spacer(minLength: 8)

                        Circle()
                            .fill(
                                blazeOrbitTutorial.forgeLiftNeedsPayment
                                ? Color.burnSignalYellow
                                : Color.chalkPureWhite
                            )
                            .frame(width: 34, height: 34)
                            .overlay {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color.chalkJetBlack)
                            }
                    }
                }
                .padding(10)
            }
            .frame(
                width: blazeOrbitTutorialCardWidth,
                height: blazeOrbitCardHeight
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private func blazeOrbitContentMinHeight(
        in blazeOrbitProxy: GeometryProxy
    ) -> CGFloat {
        max(
            blazeOrbitProxy.size.height
            - blazeOrbitProxy.safeAreaInsets.bottom
            - blazeOrbitBottomNavigationReservedHeight,
            0
        )
    }

    private func blazeOrbitTutorialCardHeight(
        in blazeOrbitProxy: GeometryProxy
    ) -> CGFloat {
        let blazeOrbitFixedContentHeight: CGFloat = 378
        let blazeOrbitAvailableTutorialHeight = blazeOrbitContentMinHeight(
            in: blazeOrbitProxy
        ) - blazeOrbitFixedContentHeight

        return max(
            blazeOrbitMinimumTutorialCardHeight,
            blazeOrbitAvailableTutorialHeight
        )
    }

    private var blazeOrbitHasCheckedInToday: Bool {
        guard let blazeOrbitCurrentUser else {
            return false
        }

        return blazeOrbitCurrentUser.novaPulseCheckedInDateKeys.contains(blazeOrbitTodayDateKey)
    }

    private var blazeOrbitCheckInButtonTitle: String {
        blazeOrbitHasCheckedInToday ? "Checked Today" : "Check-in"
    }

    private var blazeOrbitCheckInSummaryText: String {
        if let blazeOrbitCurrentUser {
            if blazeOrbitHasCheckedInToday {
                return "Current streak: \(blazeOrbitCurrentUser.novaPulseCheckInStreakCount) day(s)"
            }

            return "Tap to keep your \(max(blazeOrbitCurrentUser.novaPulseCheckInStreakCount, 0))-day streak alive"
        }

        return "Check in with your local date each day"
    }

    private var blazeOrbitCalendar: Calendar {
        var blazeOrbitCalendar = Calendar(identifier: .gregorian)
        blazeOrbitCalendar.timeZone = .current
        blazeOrbitCalendar.firstWeekday = 2
        return blazeOrbitCalendar
    }

    private var blazeOrbitTodayDateKey: String {
        blazeOrbitDateKey(from: Date())
    }

    private func blazeOrbitRefreshHomeData() {
        blazeOrbitCurrentWeekDates = blazeOrbitWeekDates(for: Date())

        do {
            if let blazeOrbitLoggedInUserID = LiftVaultPersistenceStore.liftVaultLoadLoggedInUserID() {
                blazeOrbitCurrentUser = try blazeOrbitUserStore.novaPulseFetchUser(byID: blazeOrbitLoggedInUserID)
            }

            blazeOrbitTutorialItems = try blazeOrbitTutorialStore
                .forgeLiftFetchAllTutorials()
                .sorted { $0.id < $1.id }
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to load home data right now.",
                style: .error
            )
        }
    }

    private func blazeOrbitHandleCheckIn() {
        if VealvjaiAixVisitorAccessGate.vealvjaiAixIsGuestUser() {
            vealvjaiAixVisitorGateHub.vealvjaiAixShowVisitorAlert()
            return
        }

        guard var blazeOrbitCurrentUser else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please log in first.",
                style: .error
            )
            return
        }

        guard !blazeOrbitHasCheckedInToday else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "You have already checked in today."
            )
            return
        }

        let blazeOrbitYesterdayDate = blazeOrbitCalendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let blazeOrbitYesterdayDateKey = blazeOrbitDateKey(from: blazeOrbitYesterdayDate)
        let blazeOrbitCurrentTodayDateKey = blazeOrbitTodayDateKey

        var blazeOrbitUpdatedDateKeys = Set(blazeOrbitCurrentUser.novaPulseCheckedInDateKeys)
        blazeOrbitUpdatedDateKeys.insert(blazeOrbitCurrentTodayDateKey)

        blazeOrbitCurrentUser.novaPulseCheckedInDateKeys = blazeOrbitUpdatedDateKeys.sorted()
        blazeOrbitCurrentUser.novaPulseCheckInStreakCount = blazeOrbitCurrentUser.novaPulseCheckedInDateKeys.contains(blazeOrbitYesterdayDateKey)
            ? max(blazeOrbitCurrentUser.novaPulseCheckInStreakCount + 1, 1)
            : 1

        do {
            try blazeOrbitUserStore.novaPulseUpdateUser(blazeOrbitCurrentUser)
            self.blazeOrbitCurrentUser = blazeOrbitCurrentUser
            novaPulseFeedbackHub.novaPulseShowToast(
                "Check-in successful.",
                style: .success
            )
        } catch {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Unable to save your check-in.",
                style: .error
            )
        }
    }

    private func blazeOrbitWeekDates(for blazeOrbitDate: Date) -> [Date] {
        let blazeOrbitWeekComponents = blazeOrbitCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: blazeOrbitDate)
        guard let blazeOrbitWeekStartDate = blazeOrbitCalendar.date(from: blazeOrbitWeekComponents) else {
            return []
        }

        return (0..<7).compactMap { blazeOrbitOffset in
            blazeOrbitCalendar.date(byAdding: .day, value: blazeOrbitOffset, to: blazeOrbitWeekStartDate)
        }
    }

    private func blazeOrbitWeekdaySymbol(for blazeOrbitDate: Date) -> String {
        switch blazeOrbitCalendar.component(.weekday, from: blazeOrbitDate) {
        case 2:
            return "M"
        case 3:
            return "T"
        case 4:
            return "W"
        case 5:
            return "T"
        case 6:
            return "F"
        case 7:
            return "S"
        default:
            return "S"
        }
    }

    private func blazeOrbitDayNumberText(for blazeOrbitDate: Date) -> String {
        String(blazeOrbitCalendar.component(.day, from: blazeOrbitDate))
    }

    private func blazeOrbitDateKey(from blazeOrbitDate: Date) -> String {
        let blazeOrbitFormatter = DateFormatter()
        blazeOrbitFormatter.calendar = blazeOrbitCalendar
        blazeOrbitFormatter.timeZone = .current
        blazeOrbitFormatter.dateFormat = "yyyy-MM-dd"
        return blazeOrbitFormatter.string(from: blazeOrbitDate)
    }

    private func blazeOrbitIsCheckedIn(on blazeOrbitDate: Date) -> Bool {
        guard let blazeOrbitCurrentUser else {
            return false
        }

        return blazeOrbitCurrentUser.novaPulseCheckedInDateKeys.contains(
            blazeOrbitDateKey(from: blazeOrbitDate)
        )
    }

    private func blazeOrbitIsToday(_ blazeOrbitDate: Date) -> Bool {
        blazeOrbitCalendar.isDate(blazeOrbitDate, inSameDayAs: Date())
    }
}
