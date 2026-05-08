import SwiftUI
import Combine

@MainActor
final class NovaPulseFeedbackHub: ObservableObject {
    enum NovaPulseToastStyle {
        case normal
        case error
        case success

        var novaPulseBackgroundColor: Color {
            switch self {
            case .normal:
                return Color.chalkInk.opacity(0.96)
            case .error:
                return Color(red: 181 / 255, green: 34 / 255, blue: 34 / 255)
            case .success:
                return Color(red: 31 / 255, green: 141 / 255, blue: 74 / 255)
            }
        }

        var novaPulseSymbolName: String {
            switch self {
            case .normal:
                return "bell.fill"
            case .error:
                return "xmark.octagon.fill"
            case .success:
                return "checkmark.circle.fill"
            }
        }
    }

    struct NovaPulseToastState: Equatable {
        let id = UUID()
        let novaPulseMessage: String
        let novaPulseStyle: NovaPulseToastStyle
    }

    struct NovaPulseLoadingState: Equatable {
        let novaPulseMessage: String?
        let novaPulseShowsMask: Bool
    }

    @Published private(set) var novaPulseToastState: NovaPulseToastState?
    @Published private(set) var novaPulseLoadingState: NovaPulseLoadingState?

    private var novaPulseToastDismissTask: Task<Void, Never>?

    func novaPulseShowToast(
        _ novaPulseMessage: String,
        style novaPulseStyle: NovaPulseToastStyle = .normal
    ) {
        novaPulseToastDismissTask?.cancel()
        novaPulseToastState = NovaPulseToastState(
            novaPulseMessage: novaPulseMessage,
            novaPulseStyle: novaPulseStyle
        )

        novaPulseToastDismissTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            guard !Task.isCancelled else {
                return
            }

            self?.novaPulseHideToast()
        }
    }

    func novaPulseHideToast() {
        novaPulseToastDismissTask?.cancel()
        novaPulseToastDismissTask = nil

        withAnimation(.easeInOut(duration: 0.2)) {
            novaPulseToastState = nil
        }
    }

    func novaPulseShowLoading(
        message novaPulseMessage: String? = nil,
        showsMask novaPulseShowsMask: Bool = true
    ) {
        withAnimation(.easeInOut(duration: 0.2)) {
            novaPulseLoadingState = NovaPulseLoadingState(
                novaPulseMessage: novaPulseMessage,
                novaPulseShowsMask: novaPulseShowsMask
            )
        }
    }

    func novaPulseHideLoading() {
        withAnimation(.easeInOut(duration: 0.2)) {
            novaPulseLoadingState = nil
        }
    }
}

struct NovaPulseFeedbackHost<Content: View>: View {
    @StateObject private var novaPulseFeedbackHub = NovaPulseFeedbackHub()
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            content
                .environmentObject(novaPulseFeedbackHub)

            if let novaPulseLoadingState = novaPulseFeedbackHub.novaPulseLoadingState {
                NovaPulseLoadingOverlay(
                    novaPulseLoadingState: novaPulseLoadingState
                )
                .transition(.opacity)
                .zIndex(2)
            }

            if let novaPulseToastState = novaPulseFeedbackHub.novaPulseToastState {
                NovaPulseToastOverlay(
                    novaPulseToastState: novaPulseToastState,
                    novaPulseDismissAction: {
                        novaPulseFeedbackHub.novaPulseHideToast()
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .zIndex(3)
            }
        }
        .environmentObject(novaPulseFeedbackHub)
    }
}

private struct NovaPulseToastOverlay: View {
    let novaPulseToastState: NovaPulseFeedbackHub.NovaPulseToastState
    let novaPulseDismissAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    novaPulseDismissAction()
                }

            HStack(spacing: 10) {
                Image(systemName: novaPulseToastState.novaPulseStyle.novaPulseSymbolName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.chalkPureWhite)

                Text(novaPulseToastState.novaPulseMessage)
                    .font(.pulseRobotoRegular(size: 14))
                    .foregroundStyle(Color.chalkPureWhite)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: 320, alignment: .leading)
            .background(novaPulseToastState.novaPulseStyle.novaPulseBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.24), radius: 14, y: 6)
            .padding(.horizontal, 24)
            .padding(.top, 72)
            .onTapGesture {
                novaPulseDismissAction()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: novaPulseToastState.id)
    }
}

private struct NovaPulseLoadingOverlay: View {
    let novaPulseLoadingState: NovaPulseFeedbackHub.NovaPulseLoadingState

    var body: some View {
        ZStack {
            (novaPulseLoadingState.novaPulseShowsMask ? Color.black.opacity(0.32) : Color.clear)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {}

            VStack(spacing: 14) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.burnSignalYellow)
                    .scaleEffect(1.2)

                if let novaPulseMessage = novaPulseLoadingState.novaPulseMessage,
                   !novaPulseMessage.isEmpty {
                    Text(novaPulseMessage)
                        .font(.pulseRobotoRegular(size: 14))
                        .foregroundStyle(Color.chalkPureWhite)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
            .background(Color.chalkInk.opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.24), radius: 14, y: 6)
        }
    }
}
