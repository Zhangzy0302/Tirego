
import SwiftUI

@main
struct TiregoApp: App {
    init() {

        do {
            try TiregoSeedPortal.tiregoInitializeGlobalLocalData()
        } catch {
            assertionFailure("Failed to initialize local seed data: \(error)")
        }

        PulseNovaStoreKitCenter.shared.pulseNovaRegisterPaymentObserver()
        PulseNovaStoreKitCenter.shared.pulseNovaStartBackgroundProductWarmup()
    }

    var body: some Scene {
        WindowGroup {
            NovaPulseFeedbackHost {
                ForgeTrailNavigationHost()
            }
        }
    }
}
