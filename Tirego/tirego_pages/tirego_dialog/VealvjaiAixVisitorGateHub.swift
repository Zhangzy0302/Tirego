import SwiftUI
import Combine

@MainActor
final class VealvjaiAixVisitorGateHub: ObservableObject {
    @Published private(set) var vealvjaiAixShowsVisitorAlert = false
    @Published private(set) var vealvjaiAixMessage = "You need to log in to perform this action."

    func vealvjaiAixShowVisitorAlert(
        message vealvjaiAixMessage: String = "You need to log in to perform this action."
    ) {
        self.vealvjaiAixMessage = vealvjaiAixMessage

        withAnimation(.easeInOut(duration: 0.2)) {
            vealvjaiAixShowsVisitorAlert = true
        }
    }

    func vealvjaiAixHideVisitorAlert() {
        withAnimation(.easeInOut(duration: 0.2)) {
            vealvjaiAixShowsVisitorAlert = false
        }
    }
}
