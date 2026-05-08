import SwiftUI

struct CoreLiftEntryField: View {
    let coreLiftPlaceholder: String
    @Binding var coreLiftText: String
    var coreLiftIsSecure: Bool = false
    var coreLiftKeyboardType: UIKeyboardType = .default
    var coreLiftTextFont: Font = .pulseInputText()
    var coreLiftPlaceholderFont: Font = .pulsePlaceholderText()
    var coreLiftFocusState: FocusState<Bool>.Binding? = nil

    var body: some View {
        Group {
            if coreLiftIsSecure {
                coreLiftApplyFocus(
                    to: SecureField(
                    "",
                    text: $coreLiftText,
                    prompt: coreLiftPrompt
                    )
                )
            } else {
                coreLiftApplyFocus(
                    to: TextField(
                    "",
                    text: $coreLiftText,
                    prompt: coreLiftPrompt
                    )
                    .keyboardType(coreLiftKeyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                )
            }
        }
        .font(coreLiftTextFont)
        .foregroundStyle(Color.chalkJetBlack)
        .tint(.black)
        .padding(.horizontal, 18)
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(Capsule())
    }

    private var coreLiftPrompt: Text {
        Text(coreLiftPlaceholder)
            .font(coreLiftPlaceholderFont)
            .foregroundColor(Color.repPlaceholderGray)
    }

    @ViewBuilder
    private func coreLiftApplyFocus<CoreLiftField: View>(to coreLiftField: CoreLiftField) -> some View {
        if let coreLiftFocusState {
            coreLiftField.focused(coreLiftFocusState)
        } else {
            coreLiftField
        }
    }
}

#Preview {
    CoreLiftEntryFieldPreview()
}

private struct CoreLiftEntryFieldPreview: View {
    @State private var coreLiftEmail = ""
    @State private var coreLiftPassword = ""

    var body: some View {
        VStack(spacing: 16) {
            CoreLiftEntryField(
                coreLiftPlaceholder: "Please enter",
                coreLiftText: $coreLiftEmail,
                coreLiftKeyboardType: .emailAddress
            )

            CoreLiftEntryField(
                coreLiftPlaceholder: "Please enter",
                coreLiftText: $coreLiftPassword,
                coreLiftIsSecure: true
            )
        }
        .padding(24)
        .background(Color.flexPitchBlack)
    }
}
