import SwiftUI

struct TirevOxaejjEmptyData: View {
    var body: some View {
        HStack {
            Spacer()

            VStack(spacing: 16) {
                Image("TIREGOCharacter")
                    .resizable()
                    .frame(width: 79, height: 79)

                Text("No data")
                    .font(.pulseInputText())
                    .foregroundStyle(.white)
            }

            Spacer()
        }
    }
}
