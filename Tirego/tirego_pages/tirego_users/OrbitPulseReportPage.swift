import SwiftUI

struct OrbitPulseReportPage: View {
    @Environment(\.dismiss) private var orbitPulseDismiss
    @EnvironmentObject private var novaPulseFeedbackHub: NovaPulseFeedbackHub

    private let orbitPulseReasonOptions: [OrbitPulseReasonOption] = [
        .init(
            orbitPulseTitle: "Harassment",
            orbitPulseIsMultiline: false
        ),
        .init(
            orbitPulseTitle: "Inappropriate language",
            orbitPulseIsMultiline: false
        ),
        .init(
            orbitPulseTitle: "Spam or false information",
            orbitPulseIsMultiline: false
        ),
        .init(
            orbitPulseTitle: "Other (please specify in the description box below).",
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
                Text("Enter your reason here...")
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
                "Please select a report reason.",
                style: .error
            )
            return
        }

        if orbitPulseSelectedReasonOption.orbitPulseIsMultiline,
           orbitPulseTrimmedReasonText.isEmpty {
            novaPulseFeedbackHub.novaPulseShowToast(
                "Please enter your report details.",
                style: .error
            )
            return
        }

        novaPulseFeedbackHub.novaPulseShowToast(
            "Report submitted successfully.",
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

#Preview {
    OrbitPulseReportPage()
        .environmentObject(NovaPulseFeedbackHub())
}
