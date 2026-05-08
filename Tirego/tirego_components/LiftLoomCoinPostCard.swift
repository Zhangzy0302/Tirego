import SwiftUI

struct LiftLoomCoinPostCard: View {
    var liftLoomImagePath: String = ""
    var liftLoomTitle: String = "Your gold coins are not enough to complete."
    var liftLoomAvatarPath: String = ""
    var liftLoomUserName: String = "Thomas"
    var liftLoomShowsMoreButton = true
    var liftLoomTapAction: (() -> Void)? = nil
    var liftLoomMoreTapAction: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            OrbitNovaSmartImage(orbitNovaImagePath: liftLoomImagePath) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.1))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color.chalkMist)
                    }
            }
            .frame(width: 104, height: 104)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 10) {
                Text(liftLoomTitle)
                    .font(.pulseRobotoRegular(size: 14))
                    .foregroundStyle(Color.chalkPureWhite)
                    .lineLimit(2)

                Spacer()

                HStack(spacing: 8) {
                    OrbitNovaSmartImage(orbitNovaImagePath: liftLoomAvatarPath) {
                        Circle()
                            .fill(Color.orange.opacity(0.9))
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 8))
                                    .foregroundStyle(Color.chalkPureWhite)
                            }
                    }
                    .frame(width: 18, height: 18)
                    .clipShape(Circle())

                    Text(liftLoomUserName)
                        .font(.pulseRobotoRegular(size: 12))
                        .foregroundStyle(Color.chalkMist)

                    Spacer()

                    if liftLoomShowsMoreButton {
                        Button(action: {
                            liftLoomMoreTapAction?()
                        }) {
                            Image("TIREGOMore")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .padding(10)
        .background(Color.white.opacity(0.11))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture {
            liftLoomTapAction?()
        }
    }
}
