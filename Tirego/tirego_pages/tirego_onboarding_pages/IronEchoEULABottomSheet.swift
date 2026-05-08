import SwiftUI

struct IronEchoEULABottomSheet: View {
    private struct IronEchoEULASection: Identifiable {
        let id = UUID()
        let ironEchoTitle: String
        let ironEchoParagraphs: [String]
        var ironEchoBulletItems: [String] = []
    }

    private let ironEchoIntroParagraph =
        "This End User License Agreement (EULA) governs your use of the Tirego Application (the \"App\"). By downloading, accessing or using the App, you agree to be bound by this Agreement. If you do not agree, you may not use the App."

    private let ironEchoAgreementSections: [IronEchoEULASection] = [
        IronEchoEULASection(
            ironEchoTitle: "1. Qualifications",
            ironEchoParagraphs: [
                "By using the App, you confirm that you are at least 18 years of age. You agree to provide true and accurate age information. If you are under 18, you are prohibited from using the App."
            ]
        ),
        IronEchoEULASection(
            ironEchoTitle: "2. User Generated Content",
            ironEchoParagraphs: [
                "This App allows users to post, share and view sports-related video content, including supporting text and pictures.",
                "By posting content (\"User Content\") on the App, you agree to the following:"
            ]
        ),
        IronEchoEULASection(
            ironEchoTitle: "2.1 Prohibited Content",
            ironEchoParagraphs: [
                "You may not post offensive, harmful, inappropriate or illegal content, including but not limited to:"
            ],
            ironEchoBulletItems: [
                "Hate speech, abuse, harassment, threats or personal attacks;",
                "Pornographic, explicit or vulgar content;",
                "Content promoting violence, discrimination, illegal activities or infringing others' rights;",
                "Content irrelevant to sports, violating public order and good customs, or used for unauthorized advertising;",
                "False or misleading information."
            ]
        ),
        IronEchoEULASection(
            ironEchoTitle: "2.2 Content Licensing",
            ironEchoParagraphs: [
                "You retain ownership of your User Content, but by posting it, you grant Tirego a non-exclusive, royalty-free license to use, distribute, display and promote such content within the App and its related services."
            ]
        ),
        IronEchoEULASection(
            ironEchoTitle: "3. Reporting and Response Mechanism",
            ironEchoParagraphs: []
        ),
        IronEchoEULASection(
            ironEchoTitle: "3.1 Your Responsibilities",
            ironEchoParagraphs: [
                "If you find content violating this EULA, report it immediately via the App's reporting mechanism."
            ]
        ),
        IronEchoEULASection(
            ironEchoTitle: "3.2 Our Response",
            ironEchoParagraphs: [
                "We will review reported content within 24 hours and take appropriate measures, such as removing content, warning users or banning users. Repeated violations may result in permanent account suspension."
            ]
        ),
        IronEchoEULASection(
            ironEchoTitle: "4. Privacy Policy",
            ironEchoParagraphs: [
                "By using the App, you acknowledge having read and agreed to our Privacy Policy, which details how we collect, use and protect your personal information."
            ]
        ),
        IronEchoEULASection(
            ironEchoTitle: "5. Termination",
            ironEchoParagraphs: [
                "We may terminate or suspend your access to the App at any time, with or without notice. You may stop using the App and delete your account at any time."
            ]
        ),
        IronEchoEULASection(
            ironEchoTitle: "6. Modification of the Agreement",
            ironEchoParagraphs: [
                "We may amend this Agreement at any time. Changes will be announced in the App, and your continued use constitutes acceptance of revised terms."
            ]
        ),
        IronEchoEULASection(
            ironEchoTitle: "7. Disclaimer",
            ironEchoParagraphs: [
                "The App is provided \"AS IS\" without any warranties. We do not guarantee it will be uninterrupted, error-free or secure, nor the accuracy of its content."
            ]
        ),
        IronEchoEULASection(
            ironEchoTitle: "8. Limitation of Liability",
            ironEchoParagraphs: [
                "To the fullest extent permitted by law, we are not liable for any damages arising from your use of the App or its content."
            ]
        )
    ]

    let ironEchoDisagreeAction: () -> Void
    let ironEchoAgreeAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    ironEchoDisagreeAction()
                }

            VStack(spacing: 0) {
                Text("EULA")
                    .font(.pulseRobotoBold(size: 22))
                    .foregroundStyle(Color.chalkInk)
                    .padding(.top, 28)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(ironEchoIntroParagraph)

                        ForEach(ironEchoAgreementSections) { ironEchoSection in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(ironEchoSection.ironEchoTitle)
                                    .font(.pulseRobotoBold(size: 15))

                                ForEach(ironEchoSection.ironEchoParagraphs, id: \.self) { ironEchoParagraph in
                                    Text(ironEchoParagraph)
                                }

                                ForEach(ironEchoSection.ironEchoBulletItems, id: \.self) { ironEchoBulletItem in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                        Text(ironEchoBulletItem)
                                    }
                                }
                            }
                        }
                    }
                    .font(.pulseRobotoRegular(size: 15))
                    .foregroundStyle(Color.chalkInk)
                    .lineSpacing(2)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
                .frame(maxHeight: 370)

                HStack(spacing: 43) {
                    PulseActionButton(
                        pulseTitle: "Disagree",
                        pulseStyle: .chalkMuted,
                        pulseHorizontalPadding: 0,
                        pulseHeight: 47,
                        pulseLabelFont: .pulseRobotoBold(size: 16),
                        pulseTapAction: ironEchoDisagreeAction
                    )

                    PulseActionButton(
                        pulseTitle: "Agree",
                        pulseStyle: .flexDark,
                        pulseHorizontalPadding: 0,
                        pulseHeight: 47,
                        pulseLabelFont: .pulseRobotoBold(size: 16),
                        pulseTapAction: ironEchoAgreeAction
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [
                Color.burnSignalYellow,
                .white
            ], startPoint: .top, endPoint: .bottom))
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    topTrailingRadius: 20
                )
            )
        }.ignoresSafeArea()
        .background(Color.black.opacity(0.24).ignoresSafeArea())
        
    }
}

#Preview {
    ZStack {
        Color.flexPitchBlack.ignoresSafeArea()

        IronEchoEULABottomSheet(
            ironEchoDisagreeAction: {},
            ironEchoAgreeAction: {}
        )
    }
}
