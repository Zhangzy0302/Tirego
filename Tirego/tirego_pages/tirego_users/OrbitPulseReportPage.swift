import SwiftUI

struct OrbitPulseReportPage: View {
    @Environment(\.dismiss) private var orbitPulseDismiss
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub

    private let orbitPulseReasonOptions: [OrbitPulseReasonOption] = [
        .init(
            orbitPulseTitle: "05996d8a58a9c0dd0e16cd150f96dc16".forgeNovaAESDecrypted(),
            orbitPulseIsMultiline: false
        ),
        .init(
            orbitPulseTitle: "639508aad9a20fac66b46f350bea2423db7cd518381c55c6fdb3c19a2fa4ef77".forgeNovaAESDecrypted(),
            orbitPulseIsMultiline: false
        ),
        .init(
            orbitPulseTitle: "c3d8f9106935ff41ec17aa47b215a6713e1fc583ec39f646df96f5a862b9184e".forgeNovaAESDecrypted(),
            orbitPulseIsMultiline: false
        ),
        .init(
            orbitPulseTitle: "17b1f2acd8f8682ba42e193b1eaa7337f50ddec2e8a4faabb297a0e19a49335a79d40d1300cd5a1000a2ce6bb0a90608957944e7b487d94b5c6bb6689abdc457".forgeNovaAESDecrypted(),
            orbitPulseIsMultiline: true
        )
    ]

    @State private var orbitPulseSelectedReasonID: UUID?
    @State private var orbitPulseReasonText = ""
    @FocusState private var orbitPulseReasonFocused: Bool

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    orbitPulseReasonFocused = false
                }

            VStack(alignment: .leading, spacing: 0) {
                BlazeOrbitTopBar(blazeOrbitTitle: "Report")
                    .padding(.top, 16)
                    .padding(.horizontal, 18)

                VStack(spacing: 12) {
                    ForEach(orbitPulseReasonOptions) { orbitPulseReasonOption in
                        orbitPulseReasonButton(orbitPulseReasonOption: orbitPulseReasonOption)
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)

                orbitPulseReasonEditor
                    .padding(.top, 28)
                    .padding(.horizontal, 16)

                Spacer()

                PulseActionButton(
                    pulseTitle: "Submit",
                    pulseStyle: .burnPrimary,
                    pulseHorizontalPadding: 16,
                    pulseTapAction: {
                        orbitPulseReasonFocused = false
                        orbitPulseSubmitReport()
                    }
                )
                .padding(.bottom, 20)
                .padding(.horizontal, 18)
            }
        }
        .burnStageBackground()
        .preferredColorScheme(.dark)
    }

    private func orbitPulseReasonButton(
        orbitPulseReasonOption: OrbitPulseReasonOption
    ) -> some View {
        let orbitPulseIsSelected = orbitPulseSelectedReasonID == orbitPulseReasonOption.id

        return Button(action: {
            orbitPulseSelectedReasonID = orbitPulseReasonOption.id
        }) {
            Text(orbitPulseReasonOption.orbitPulseTitle)
                .font(.pulseRobotoRegular(size: 15))
                .foregroundStyle(
                    orbitPulseIsSelected
                    ? Color.chalkJetBlack
                    : Color.chalkInk
                )
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: orbitPulseReasonOption.orbitPulseIsMultiline ? .leading : .center)
                
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    orbitPulseIsSelected
                    ? Color.burnSignalYellow
                    : Color.chalkPureWhite
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var orbitPulseReasonEditor: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.chalkPureWhite)

            if orbitPulseReasonText.isEmpty {
                Text("f65ced81f11d572c5772428ce68d5585f3eb210437717cd1c0ab6e7dc5ec6f6a".forgeNovaAESDecrypted())
                    .font(.pulsePlaceholderText(size: 14))
                    .foregroundStyle(Color.repPlaceholderGray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }

            TextEditor(text: $orbitPulseReasonText)
                .font(.pulseRobotoRegular(size: 14))
                .foregroundStyle(Color.chalkInk)
                .tint(.black)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .focused($orbitPulseReasonFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .frame(height: 142)
    }

    private var orbitPulseTrimmedReasonText: String {
        orbitPulseReasonText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private var orbitPulseSelectedReasonOption: OrbitPulseReasonOption? {
        orbitPulseReasonOptions.first {
            $0.id == orbitPulseSelectedReasonID
        }
    }

    private func orbitPulseSubmitReport() {
        guard let orbitPulseSelectedReasonOption else {
            novaPulseFeedbackHub.novaPulseShowToast(
                "8ef127d60934af904b5213e95f5ebfde6d85e8833d92f197fb6cbce15eb0b05e".forgeNovaAESDecrypted(),
                style: .error
            )
            return
        }

        if orbitPulseSelectedReasonOption.orbitPulseIsMultiline,
           orbitPulseTrimmedReasonText.isEmpty {
            novaPulseFeedbackHub.novaPulseShowToast(
                "8ec188fe8bd186835ff7c7ba0157023faa2fae9d947b5c4884f39bcfc5e399d690e1f07dca141af7ef9ea0c8d735093d".forgeNovaAESDecrypted(),
                style: .error
            )
            return
        }

        novaPulseFeedbackHub.novaPulseShowToast(
            "3d8e6700dc8600e132967f8122c08359b5e1ec0443e8c75df5ff93e63bb75250".forgeNovaAESDecrypted(),
            style: .success
        )
        orbitPulseDismiss()
    }
}

private struct OrbitPulseReasonOption: Identifiable {
    let id = UUID()
    let orbitPulseTitle: String
    let orbitPulseIsMultiline: Bool
}

