import SwiftUI

struct BlazeOrbitTopBar: View {
    @Environment(\.dismiss) private var blazeOrbitDismiss

    var blazeOrbitTitle: String? = nil
    var blazeOrbitBackAction: (() -> Void)? = nil

    var body: some View {
        ZStack {
            HStack {
                Button(action: blazeOrbitHandleBackTap) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.chalkPureWhite)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()
            }

            if let blazeOrbitTitle, !blazeOrbitTitle.isEmpty {
                Text(blazeOrbitTitle)
                    .font(.flexCarterDisplay(size: 28, relativeTo: .title))
                    .foregroundStyle(Color.burnSignalYellow)
            }
        }
        .background(ForgeTrailSwipeBackEnabler())
    }

    private func blazeOrbitHandleBackTap() {
        if let blazeOrbitBackAction {
            blazeOrbitBackAction()
            return
        }

        blazeOrbitDismiss()
    }
}

#Preview("With Title") {
    ZStack {
        Color.flexPitchBlack.ignoresSafeArea()

        VStack {
            BlazeOrbitTopBar(blazeOrbitTitle: "Post")
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 56)
    }
}

#Preview("No Title") {
    ZStack {
        Color.flexPitchBlack.ignoresSafeArea()

        VStack {
            BlazeOrbitTopBar()
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 56)
    }
}
