import SwiftUI

@main
struct RoadFocusApp: App {
    @StateObject private var resolver = FocusRedirectResolver()
    
    init() {
        // Force light mode
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { $0.overrideUserInterfaceStyle = .light }
        }
        
        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.white
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        UITabBar.appearance().tintColor = UIColor(red: 212/255, green: 160/255, blue: 23/255, alpha: 1)
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        // Nav bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(red: 212/255, green: 160/255, blue: 23/255, alpha: 1)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 28)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 34)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        }
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().prefersLargeTitles = false
    }
    
    var body: some Scene {
        WindowGroup {
            rootView
                .onAppear {
                    // Force light mode on all windows
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap { $0.windows }
                        .forEach { $0.overrideUserInterfaceStyle = .light }
                    
                    resolver.resolve()
                    // Ensure timeout works
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                        if resolver.focusLinkStatus == .loading {
                            resolver.focusLinkStatus = .showApp
                        }
                    }
                }
                .preferredColorScheme(.light)
        }
    }
    
    @ViewBuilder
    var rootView: some View {
        switch resolver.focusLinkStatus {
        case .loading:
            FocusLaunchScreen()
        case .showApp:
            ContentView()
        case .showWeb:
            if let url = resolver.finalURL {
                FocusWebDisplay(url: url)
                    .edgesIgnoringSafeArea(.all)
            } else {
                ContentView()
            }
        }
    }
}
