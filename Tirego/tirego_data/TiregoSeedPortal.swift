import Foundation

enum TiregoSeedPortal {
    private static var tiregoSeedTodayDate: Date {
        Date()
    }

    private static var tiregoSeedCheckedInDateKeys: [String] {
        let tiregoCalendar = Calendar(identifier: .gregorian)
        let tiregoFormatter = DateFormatter()
        tiregoFormatter.calendar = tiregoCalendar
        tiregoFormatter.timeZone = .current
        tiregoFormatter.dateFormat = "yyyy-MM-dd"

        let tiregoToday = tiregoSeedTodayDate
        let tiregoYesterday = tiregoCalendar.date(byAdding: .day, value: -1, to: tiregoToday) ?? tiregoToday
        let tiregoThreeDaysAgo = tiregoCalendar.date(byAdding: .day, value: -3, to: tiregoToday) ?? tiregoToday

        return [
            tiregoFormatter.string(from: tiregoThreeDaysAgo),
            tiregoFormatter.string(from: tiregoYesterday),
            tiregoFormatter.string(from: tiregoToday)
        ]
    }

    static let tiregoSeedUsers: [NovaPulseUser] = [
        // Fill your user seed data here.
        // Example:
         NovaPulseUser(
             id: "user_001",
             novaPulseEmail: "tirego@gmail.com",
             novaPulsePassword: "123456",
             novaPulseAvatar: "TIRExoa_avatar_0",
             novaPulseUserName: "lifewscarr",
             novaPulseBirthdayDate: Date(timeIntervalSince1970: 1_041_897_600),
             novaPulseLocation: "La",
             novaPulseGender: .female,
             novaPulseFollowerIDs: ["user_002", "user_004"],
             novaPulseFollowingIDs: ["user_002"],
             novaPulseBlockedIDs: [],
             novaPulsePurchasedTutorialIDs: [],
             novaPulseCheckedInDateKeys: tiregoSeedCheckedInDateKeys,
             novaPulseCheckInStreakCount: 2,
             novaPulseGoldCoinCount: 0,
             novaPulseIsGuest: false
         ),
         NovaPulseUser(
             id: "user_002",
             novaPulseEmail: "sceadabr@gmail.com",
             novaPulsePassword: "awkcno2df12",
             novaPulseAvatar: "TIRExoa_avatar_1",
             novaPulseUserName: "nasinwright",
             novaPulseBirthdayDate: Date(timeIntervalSince1970: 1_041_897_600),
             novaPulseLocation: "La",
             novaPulseGender: .female,
             novaPulseFollowerIDs: ["user_001"],
             novaPulseFollowingIDs: ["user_001"],
             novaPulseBlockedIDs: [],
             novaPulsePurchasedTutorialIDs: [],
             novaPulseCheckedInDateKeys: tiregoSeedCheckedInDateKeys,
             novaPulseCheckInStreakCount: 2,
             novaPulseGoldCoinCount: 0,
             novaPulseIsGuest: false
         ),
         NovaPulseUser(
             id: "user_003",
             novaPulseEmail: "tirego@gmail.com",
             novaPulsePassword: "bnel02jd",
             novaPulseAvatar: "TIRExoa_avatar_2",
             novaPulseUserName: "maiahenryfit",
             novaPulseBirthdayDate: Date(timeIntervalSince1970: 1_041_897_600),
             novaPulseLocation: "La",
             novaPulseGender: .female,
             novaPulseFollowerIDs: [],
             novaPulseFollowingIDs: [],
             novaPulseBlockedIDs: [],
             novaPulsePurchasedTutorialIDs: [],
             novaPulseCheckedInDateKeys: tiregoSeedCheckedInDateKeys,
             novaPulseCheckInStreakCount: 2,
             novaPulseGoldCoinCount: 0,
             novaPulseIsGuest: false
         ),
         NovaPulseUser(
             id: "user_004",
             novaPulseEmail: "tirego@gmail.com",
             novaPulsePassword: "vc9hjjkv3",
             novaPulseAvatar: "TIRExoa_avatar_3",
             novaPulseUserName: "mezdhax",
             novaPulseBirthdayDate: Date(timeIntervalSince1970: 1_041_897_600),
             novaPulseLocation: "La",
             novaPulseGender: .female,
             novaPulseFollowerIDs: [],
             novaPulseFollowingIDs: ["user_001"],
             novaPulseBlockedIDs: [],
             novaPulsePurchasedTutorialIDs: [],
             novaPulseCheckedInDateKeys: tiregoSeedCheckedInDateKeys,
             novaPulseCheckInStreakCount: 2,
             novaPulseGoldCoinCount: 0,
             novaPulseIsGuest: false
         ),
         NovaPulseUser(
             id: "user_005",
             novaPulseEmail: "vasc3sd@gmail.com",
             novaPulsePassword: "asf3hvb427",
             novaPulseAvatar: "TIRExoa_avatar_4",
             novaPulseUserName: "charlie_plourde",
             novaPulseBirthdayDate: Date(timeIntervalSince1970: 1_041_897_600),
             novaPulseLocation: "La",
             novaPulseGender: .female,
             novaPulseFollowerIDs: [],
             novaPulseFollowingIDs: [],
             novaPulseBlockedIDs: [],
             novaPulsePurchasedTutorialIDs: [],
             novaPulseCheckedInDateKeys: tiregoSeedCheckedInDateKeys,
             novaPulseCheckInStreakCount: 2,
             novaPulseGoldCoinCount: 0,
             novaPulseIsGuest: false
         )
    ]

    static let tiregoSeedPosts: [BlazeEchoPost] = [
        // Fill your post seed data here.
        // Example:
         BlazeEchoPost(
             id: "post_001",
             blazeEchoPublisherID: "user_002",
             blazeEchoImageList: [
                 "Tireohw_post_3",
                 "Tireohw_post_4",
                 "Tireohw_post_5"
             ],
             blazeEchoContentText: "Road to 90kg"
         ),
         BlazeEchoPost(
             id: "post_002",
             blazeEchoPublisherID: "user_001",
             blazeEchoImageList: [
                 "Tireohw_post_0",
                 "Tireohw_post_1",
                 "Tireohw_post_2"
             ],
             blazeEchoContentText: "morning workout 🩵"
         ),
         BlazeEchoPost(
             id: "post_003",
             blazeEchoPublisherID: "user_003",
             blazeEchoImageList: [
                 "Tireohw_post_6",
                 "Tireohw_post_7",
                 "Tireohw_post_8"
             ],
             blazeEchoContentText: "GYM SHOOTING."
         ),
         BlazeEchoPost(
             id: "post_004",
             blazeEchoPublisherID: "user_004",
             blazeEchoImageList: [
                 "Tireohw_post_9",
                 "Tireohw_post_10"
             ],
             blazeEchoContentText: "The state of healthy exercise is truly full of vitality"
         )
    ]

    static let tiregoSeedComments: [OrbitDriftComment] = [
        // Fill your comment seed data here.
        // Example:
         OrbitDriftComment(
             id: "comment_001",
             orbitDriftPostID: "post_001",
             orbitDriftPublisherID: "user_001",
             orbitDriftContentText: "This tutorial helped a lot.",
             orbitDriftCreatedAt: Date(timeIntervalSince1970: 1_041_897_600)
         )
    ]

    static let tiregoSeedChatRooms: [EchoNovaChatRoom] = [
        // Fill your chat room seed data here.
        // Example:
         EchoNovaChatRoom(
             id: "chat_room_001",
             echoNovaMemberUserIDs: ["user_001", "user_002"],
             echoNovaLastMessageSentAt: Date(timeIntervalSince1970: 1_041_897_600),
             echoNovaLastSenderUserID: "user_001",
             echoNovaLastMessageText: "Let’s train together tomorrow.",
             echoNovaUnreadMessageCount: 1
         )
    ]

    static let tiregoSeedChatMessages: [BlazePulseChatMessage] = [
        // Fill your chat message seed data here.
        // Example:
         BlazePulseChatMessage(
             id: "chat_message_001",
             blazePulseChatRoomID: "chat_room_001",
             blazePulseSenderUserID: "user_001",
             blazePulseTextMessage: "Let’s train together tomorrow.",
             blazePulseVoiceMessageURL: "",
             blazePulseVoiceDuration: 0,
             blazePulseSentAt: Date(timeIntervalSince1970: 1_041_897_600)
         )
    ]

    static let tiregoSeedTutorials: [ForgeLiftTutorial] = [
        // Fill your tutorial seed data here.
        // Example:
         
         ForgeLiftTutorial(
             id: "tutorial_001",
             forgeLiftVideoURL: "http://huanniuchat.oss-accelerate.aliyuncs.com/Tirego2026/TIRExoa_vido_1.mp4",
             forgeLiftCoverURL: "TIRExoa_vido_cover_1",
             forgeLiftTutorialText: "May of consumed 4 cookies before this",
             forgeLiftNeedsPayment: true
         ),
         ForgeLiftTutorial(
             id: "tutorial_002",
             forgeLiftVideoURL: "http://huanniuchat.oss-accelerate.aliyuncs.com/Tirego2026/TIRExoa_vido_0.mp4",
             forgeLiftCoverURL: "TIRExoa_vido_cover_0",
             forgeLiftTutorialText: "back & bis ☺️ fit ",
             forgeLiftNeedsPayment: false
         ),
         ForgeLiftTutorial(
             id: "tutorial_003",
             forgeLiftVideoURL: "http://huanniuchat.oss-accelerate.aliyuncs.com/Tirego2026/TIRExoa_vido_2.mp4",
             forgeLiftCoverURL: "TIRExoa_vido_cover_2",
             forgeLiftTutorialText: "Full body workout- day 3: plates edition! To tone & for fat loss🔥",
             forgeLiftNeedsPayment: true
         ),
         ForgeLiftTutorial(
             id: "tutorial_004",
             forgeLiftVideoURL: "http://huanniuchat.oss-accelerate.aliyuncs.com/Tirego2026/TIRExoa_vido_3.mp4",
             forgeLiftCoverURL: "TIRExoa_vido_cover_3",
             forgeLiftTutorialText: "we love a black fit 🤤🤤",
             forgeLiftNeedsPayment: true
         ),
         ForgeLiftTutorial(
             id: "tutorial_005",
             forgeLiftVideoURL: "http://huanniuchat.oss-accelerate.aliyuncs.com/Tirego2026/TIRExoa_vido_4.mp4",
             forgeLiftCoverURL: "TIRExoa_vido_cover_4",
             forgeLiftTutorialText: "Getting bigger",
             forgeLiftNeedsPayment: true
         )
    ]

    static func tiregoSeedAllLocalData() throws {
        try NovaPulseUserStore().novaPulseReplaceAllUsers(with: tiregoSeedUsers)
        try BlazeEchoPostStore().blazeEchoReplaceAllPosts(with: tiregoSeedPosts)
        try OrbitDriftCommentStore().orbitDriftReplaceAllComments(with: tiregoSeedComments)
        try EchoNovaChatRoomStore().echoNovaReplaceAllChatRooms(with: tiregoSeedChatRooms)
        try BlazePulseChatMessageStore().blazePulseReplaceAllChatMessages(with: tiregoSeedChatMessages)
        try ForgeLiftTutorialStore().forgeLiftReplaceAllTutorials(with: tiregoSeedTutorials)
    }

    static func tiregoInitializeGlobalLocalData() throws {
        let tiregoUserStore = NovaPulseUserStore()
        let tiregoPostStore = BlazeEchoPostStore()
        let tiregoCommentStore = OrbitDriftCommentStore()
        let tiregoChatRoomStore = EchoNovaChatRoomStore()
        let tiregoChatMessageStore = BlazePulseChatMessageStore()
        let tiregoTutorialStore = ForgeLiftTutorialStore()

        if try tiregoUserStore.novaPulseFetchAllUsers().isEmpty {
            try tiregoUserStore.novaPulseReplaceAllUsers(with: tiregoSeedUsers)
        }

        if try tiregoPostStore.blazeEchoFetchAllPosts().isEmpty {
            try tiregoPostStore.blazeEchoReplaceAllPosts(with: tiregoSeedPosts)
        }

        if try tiregoCommentStore.orbitDriftFetchAllComments().isEmpty {
            try tiregoCommentStore.orbitDriftReplaceAllComments(with: tiregoSeedComments)
        }

        if try tiregoChatRoomStore.echoNovaFetchAllChatRooms().isEmpty {
            try tiregoChatRoomStore.echoNovaReplaceAllChatRooms(with: tiregoSeedChatRooms)
        }

        if try tiregoChatMessageStore.blazePulseFetchAllChatMessages().isEmpty {
            try tiregoChatMessageStore.blazePulseReplaceAllChatMessages(with: tiregoSeedChatMessages)
        }

        if try tiregoTutorialStore.forgeLiftFetchAllTutorials().isEmpty {
            try tiregoTutorialStore.forgeLiftReplaceAllTutorials(with: tiregoSeedTutorials)
        }
    }
}
