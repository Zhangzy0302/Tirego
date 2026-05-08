import SwiftUI

struct PulseActionButton: View {
    enum PulseActionStyle {
        case burnPrimary
        case chalkSecondary
        case chalkMuted
        case flexDark
        case ciwaonCheckStyle

        var backgroundColor: Color {
            switch self {
            case .burnPrimary:
                return .burnSignalYellow
            case .chalkSecondary:
                return .chalkCloud
            case .chalkMuted:
                return .chalkSteelGray
            case .flexDark:
                return .chalkJetBlack
            case .ciwaonCheckStyle:
                return Color(red: 93/255, green: 91/255, blue: 74/255)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .flexDark, .ciwaonCheckStyle:
                return .chalkPureWhite
            case .burnPrimary, .chalkSecondary, .chalkMuted:
                return .chalkJetBlack
            }
        }
    }

    let pulseTitle: String
    let pulseStyle: PulseActionStyle
    var pulseHorizontalPadding: CGFloat = 24
    var pulseWidth: CGFloat? = nil
    var pulseHeight: CGFloat = 52
    var pulseLabelFont: Font = .pulseButtonLabel()
    let pulseTapAction: () -> Void

    var body: some View {
        Button(action: pulseTapAction) {
            Text(pulseTitle)
                .font(pulseLabelFont)
                .foregroundStyle(pulseStyle.foregroundColor)
                .frame(maxWidth: pulseWidth == nil ? .infinity : nil)
                .frame(width: pulseWidth)
                .frame(height: pulseHeight)
                .background(pulseStyle.backgroundColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, pulseHorizontalPadding)
    }
}
