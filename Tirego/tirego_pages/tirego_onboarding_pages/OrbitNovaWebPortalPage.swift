import SwiftUI
import WebKit

struct OrbitNovaWebPortalPage: View {
    let orbitNovaURLString: String
    var orbitNovaTitle: String? = nil

    @State private var orbitNovaIsLoading = true

    var body: some View {
        VStack(spacing: 0) {
            BlazeOrbitTopBar(blazeOrbitTitle: orbitNovaTitle)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

            if let orbitNovaURL = orbitNovaResolvedURL {
                ZStack {
                    OrbitNovaWebStageView(
                        orbitNovaURL: orbitNovaURL,
                        orbitNovaIsLoading: $orbitNovaIsLoading
                    )

                    if orbitNovaIsLoading {
                        VStack(spacing: 14) {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(Color.burnSignalYellow)
                                .scaleEffect(1.15)

                            Text("Loading...")
                                .font(.pulseRobotoRegular(size: 14))
                                .foregroundStyle(Color.chalkPureWhite)
                        }
                        .padding(.horizontal, 22)
                        .padding(.vertical, 20)
                        .background(Color.chalkInk.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            } else {
                orbitNovaInvalidStateView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .burnStageBackground()
        .preferredColorScheme(.dark)
    }

    private var orbitNovaResolvedURL: URL? {
        let orbitNovaTrimmedURLString = orbitNovaURLString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !orbitNovaTrimmedURLString.isEmpty else {
            return nil
        }

        if let orbitNovaDirectURL = URL(string: orbitNovaTrimmedURLString),
           orbitNovaDirectURL.scheme != nil {
            return orbitNovaDirectURL
        }

        return URL(string: "https://\(orbitNovaTrimmedURLString)")
    }

    private var orbitNovaInvalidStateView: some View {
        VStack(spacing: 14) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.burnSignalYellow)

            Text("Invalid web address")
                .font(.pulseRobotoBold(size: 18))
                .foregroundStyle(Color.chalkPureWhite)

            Text("Please pass in a valid URL string.")
                .font(.pulseRobotoRegular(size: 14))
                .foregroundStyle(Color.chalkMist)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private struct OrbitNovaWebStageView: UIViewRepresentable {
    let orbitNovaURL: URL
    @Binding var orbitNovaIsLoading: Bool

    func makeCoordinator() -> OrbitNovaWebStageCoordinator {
        OrbitNovaWebStageCoordinator(orbitNovaIsLoading: $orbitNovaIsLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let orbitNovaConfiguration = WKWebViewConfiguration()
        let orbitNovaWebView = WKWebView(frame: .zero, configuration: orbitNovaConfiguration)
        orbitNovaWebView.navigationDelegate = context.coordinator
        orbitNovaWebView.scrollView.contentInsetAdjustmentBehavior = .never
        orbitNovaWebView.backgroundColor = .white
        orbitNovaWebView.isOpaque = false
        orbitNovaWebView.load(URLRequest(url: orbitNovaURL))
        return orbitNovaWebView
    }

    func updateUIView(_ orbitNovaWebView: WKWebView, context: Context) {
        guard orbitNovaWebView.url != orbitNovaURL else {
            return
        }

        orbitNovaIsLoading = true
        orbitNovaWebView.load(URLRequest(url: orbitNovaURL))
    }
}

private final class OrbitNovaWebStageCoordinator: NSObject, WKNavigationDelegate {
    @Binding private var orbitNovaIsLoading: Bool

    init(orbitNovaIsLoading: Binding<Bool>) {
        _orbitNovaIsLoading = orbitNovaIsLoading
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        orbitNovaIsLoading = false
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        orbitNovaIsLoading = false
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        orbitNovaIsLoading = false
    }
}
