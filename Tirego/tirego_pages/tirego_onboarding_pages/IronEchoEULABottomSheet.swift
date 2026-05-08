import SwiftUI

struct IronEchoEULABottomSheet: View {
    private struct IronEchoEULASection: Identifiable {
        let id = UUID()
        let ironEchoTitle: String
        let ironEchoParagraphs: [String]
        var ironEchoBulletItems: [String] = []
    }

    private enum IronEchoSecureCopyVault {
        static let ironEchoIntroParagraph =
            "83dab1e15c4d7c43d21d929d71dae2fd296c0dc0b5a28227353c384fb9e5e281c0d6e751dffcc28f20d141b2e2a049fcdb4cb97368333b4affe9ac9b793d5c7eb518c0003efbb53f68029ae089ab76b535c644c055ce55acb5658bfd30a3eef87db3ed572e183ff7af27598c71be7504d8b3ea1465201e2d5856619177e40a9a6af527a02598d066e0b257d0c8a0ce8b044ae083e2fcaf291e06cfa721967b2d14a7999845069ba5b3d0b2866a8733a295a9fab35d8898b7850b989784abab856aa3f69c7fd5f9d00729cdab593c96238f673344e105c4600a35ad9fd3460bd3f1021dfce997fe6aa820f9b49e45ebb5"

        static let ironEchoSectionPayloads: [(String, [String], [String])] = [
            (
                "ea4cc6d42e80a1296b15bd764c864806bbe6d758acb6d2cce7f045e891caea9e",
                [
                    "3b508c6576aa49af045deaaaae7b733ff153fc2e7f8fbfa490c2c89a0660c4c9444dcdcf2a253b2b75dd257ba9bff6fefd6e6d805df316ae3756331318438bd479e2664cb7c845669f8d70824b6f39ff8bc7906a8e6373ee2f4edf1593fca544758ba8a21afbf1de62a3adc29ee3b813f41bd360f905afad33f77ee2d64cb4ab23920c8b69f39df184fe80537278ac428052fa3a794cee8eb585c4e7a0ab8de2c9ba335680eb1927cc2eaa6368588ae9b03962f165b34cf42c00f8a8da92f7fd"
                ],
                []
            ),
            (
                "d03c3cd8d740874215ffe38f91d99f94c75eee40757cc7c49d50908f0f9606c5",
                [
                    "2b16da7512633fdbc7b201bd4eb9301379bd8c92a700c8149ebb4e6f9bd9ff9b2b8e0f6977ad75671eb8e41558e260d82339974d73b597fd88fdf4a5ff571d0cd8b0de5ea8bd46503d689fb219a0ea5f573fd6bc0c8160d053634d9672c74f45d1f364a64552e2ca30d8faa4c122d26406866294692f789ca47d6d7c74e06234",
                    "a2c2eb099154f65111336331081261cc26539d1f5e6206217b4d3a551c4be6dff6f49bb3720fbedd36c1aa2a0b35a2664e0cfbb066bb8d328299103b0d9c3e058a67ed4de6ada56420356860752e18d0"
                ],
                []
            ),
            (
                "2e5623ce809f36918ee201575e03082b4b699d29255b627b9fdc3cc7cc04304e",
                [
                    "28dfcee3bf7f9359fa06e458969422542148e7f863a3b46721275904641d2c4dbf14f9e8bdcd5cf0aff3e1023c59988de05ea018ab2feb4738c6ef52cb317444b0abc3c6d936748ff793d725e83133b0d16e2430a44cc20b11fca851798599768f6c7948bc57138632820d9230f9259c"
                ],
                [
                    "9e8f8caf91b1a60f34e2811248f4570b235478bc130f7e0f56576711bb6a7c46f6cd49386f67a8d6484f14d4abfe5ecd2832e616da3f643a327f6b9b839c7b07",
                    "3cfbd69bfc253ee3d92acfedd44603d5b948a2700503063e16418f42de7c3c3ad2dcf63478484ec18be204c2471d850e",
                    "f70140772f315fd39fbd6518491ee9da8ac0eae9506a39b8f5f8cd0fe1b1030dae45949a58fac83acc626e822ae1ddce94852ca4c672f4af2731c8fe3a113e16288165231d0eae095b67008c4872811cc536a7af978e74e6e80f49d0ed98d77f",
                    "a9fe114b141a7a0d95177da49e0c45fbc4e53adaab24837d3140331ad270878c28acc21486e576e3aa5cb1acec8be742c496d760b50d093770b5b83b896b0df4269efd89828af123519a6a0eb0672e560ad7ed623877090e433a417e66b8eae3b59a3769c43f0024c4ecc310f1498585",
                    "36e810f6b0ba511cb5ca11ccd453f886be01d4dbf776d483ce80ad33b94b2b2f85ce84ec32880ad193b4e5403ff258cd"
                ]
            ),
            (
                "a1723abcbe90148fdfd67a827dc0d19e288c97cf9866b23c295bcfd5e3262938",
                [
                    "f4f6de971b9ed0fefa86bc580d26a7c899007d0b1601251e1b04b49a55c178a3bdace5629d5a0cddf03422d10cc8f1bb15d8e2ef3ce3b1bbe83b2649a1018bb66aa246151bada2105190bf67a1672577173bbc9377096ba4e1c641b9900f88cf6433743f50381d66b812364b143861fb95417cd5516ae3757ffd85cc6e45e5bcf184810fe8742e495815347930371fd4435f6d4a1f0e352c80a5735dda91c45744294f2da2e11d6439d3cb467eb87f35dae20504cc65286d943f66cee19a15de05a8c97603fde31a2f1ad266b76eaaf56ae239a551f2c77ef55352760aefb42d"
                ],
                []
            ),
            (
                "67b3cafc4daa26fd9563aef7cf0a25ed9ffb84b99fcaacb0e64ac8177d61363ecbcb11a7841d9acbfa984b2f848acd28",
                [],
                []
            ),
            (
                "d14c6f28852e294aa0db1a3d3dea7d061bf417f6c7db1051930b64178a1c5083",
                [
                    "2464d29fa7e5cd0cde0353151c550e36e5673817735ef777d4a3ec91ea5971b7ba42fe6da47075fca76bf62898bd35e3f198f5324d87cb199174c7c69c1c3a660e9160e61be44f65a90b011d224621b874778a1b0a47c6ceb16f8b4e0affcaf1b9794a3c732c1f05001062955079ae1a"
                ],
                []
            ),
            (
                "769a479fb72364e29b1817021fefb29256f180d2c2f0e412903abc83489f6b26",
                [
                    "b28537ddb854ad3799f17b56831683a31854b134550db614845948910258dce921147cab090045c66c31b467630648c2a6c1f594cc82f0c206529906a95bdda86d7c863644e0d0d5ca96360597263d692898f9a8a20ffc2378ab6d86e168220019b9e49b35969b858da88d22201b0ea4dbb953d7316c55ef1df781eac1f343aba25283515b1eb184bac71957860be0bd6eff4f102f8d57def469e583d712ad844478b2854c2d857d318233775ff13d668141d410ba5c33d7eae1ba8d2737b9386cafe0f63274d6dc215ade445bf1475b"
                ],
                []
            ),
            (
                "bb634ba3a8ac170c8106b8781a687f78573224639348ea3eb5cc3c387defc59a",
                [
                    "3b508c6576aa49af045deaaaae7b733f9ecdfcf1b878c3044eec608fb3ed4fed5b17877f7a7a372672a2422a1a7dcc02c02faafaabe7ea0c7a5283bdb016f8ddd7671352e1f4111cad10abfc4d89cb6b42c121e905f79c260b943b960533460b524b55d5743247d69533013bd87bec7eee346aeebce2a0e36c5aac0d87ebb2fbec09d22c76bdeeaaa547ddbffdd6e791f1819d3e341089d0ccf6d81b3cbbe46b"
                ],
                []
            ),
            (
                "f248b1d8b8e67709a14e99019292e048",
                [
                    "ca7ac7fe4c9c1846b2efcbe5c0e13a2b214493ff24dba6acf1b847ec74f4b0505a9a38136afd174434d2df291464fe916dad5b30f210832a94b1d57376bccae0c6c32f687fafa569d8a5dd56d6a9754d9c86b30374aeda2505a0e90aa6e92743d92f3dc8b39ca8fe8b376ad32a2929a93889cefc40a4909fb889a963aebff3bad28487df38ee71f7e7824618c78eff286ef2d333d488ca5817424bf7778a19a2"
                ],
                []
            ),
            (
                "64ef8379257e7c68a760cee40475f3da77daabb25937808e7e1c0d791d132e4224b14e66279b62959a8e18bee6c20409",
                [
                    "2787d49f0d59258db97c47a27a20b428d22e512306d52a8d7268ff872d86233c6a45d3eb7548d805c34b2767d51dc8530cad7cf09254621c5db38c61c46271bd22b782b09b9dcfda1c0d441b30bc9ad57a3a5f4f4bd4055071c7a1a7cc5b982410e87c2e27a839d6cbc77f6ac9d4763cb038e66b6446b086a521ce0d2740f5bb5dc8a9b58783418a3515f69b9302d400"
                ],
                []
            ),
            (
                "90bde29d49f2a49f9e9b50a9ce7776e4",
                [
                    "1cf502ebe175d93757d5a27d1df11b66d63b115d2ea9fa2d05ae025ee2e5171ce6c46d49c1577646666ca7ccd5b47fbdf4d04477662f12f34144bb818f036177ae110e1a0cd1675507c0ab51664145ed7c181424b317403e15b73ddc9658d72f2c71ee234951f2fbbdd50cdd4863b1163567a298c01adef37e98c083dfda25be2b82823a1dd7b47a26521c118f6d326ce52a7e2febc20fa04df7e23b59ebd7cf"
                ],
                []
            ),
            (
                "3eaa4e81cb9630250fe81ac9905cc2e9eee65f9e9144afb83713fcc7a610d496",
                [
                    "3084ef4a4360c70d6eb209669e6e02d43a17c74f62469480f7b61c582707afd17a8d73e639554b1f5204b360c9ea2fd75ffd214beb192817e4cc62dbfe2c6e5b1c36e59044b362b6aaa95ae6e84219140fcfe5573cbd6c2052f655745bc865b630d8577a6427af61215deac56987c9acdc0f5ecef830974b842fb0ee667d8fd5"
                ],
                []
            )
        ]
    }

    let ironEchoDisagreeAction: () -> Void
    let ironEchoAgreeAction: () -> Void

    private var ironEchoIntroParagraph: String {
        IronEchoSecureCopyVault.ironEchoIntroParagraph.forgeNovaAESDecrypted()
    }

    private var ironEchoAgreementSections: [IronEchoEULASection] {
        IronEchoSecureCopyVault.ironEchoSectionPayloads.map { ironEchoPayload in
            IronEchoEULASection(
                ironEchoTitle: ironEchoPayload.0.forgeNovaAESDecrypted(),
                ironEchoParagraphs: ironEchoPayload.1.map {
                    $0.forgeNovaAESDecrypted()
                },
                ironEchoBulletItems: ironEchoPayload.2.map {
                    $0.forgeNovaAESDecrypted()
                }
            )
        }
    }

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
