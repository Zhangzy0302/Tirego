import SwiftUI
import UIKit

struct ForgeTrailSwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ForgeTrailSwipeBackController {
        ForgeTrailSwipeBackController()
    }

    func updateUIViewController(
        _ uiViewController: ForgeTrailSwipeBackController,
        context: Context
    ) {
        uiViewController.forgeTrailEnableSwipeBackIfNeeded()
    }
}

final class ForgeTrailSwipeBackController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        forgeTrailEnableSwipeBackIfNeeded()
    }

    func forgeTrailEnableSwipeBackIfNeeded() {
        guard let forgeTrailNavigationController = navigationController else {
            return
        }

        forgeTrailNavigationController.interactivePopGestureRecognizer?.isEnabled =
        forgeTrailNavigationController.viewControllers.count > 1
        forgeTrailNavigationController.interactivePopGestureRecognizer?.delegate = nil
    }
}
