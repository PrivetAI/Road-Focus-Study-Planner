import SwiftUI

struct ContentView: View {
    @StateObject private var store = DataStore.shared
    @State private var selectedTab: Int = {
        if let idx = ProcessInfo.processInfo.arguments.firstIndex(of: "-startTab"),
           idx + 1 < ProcessInfo.processInfo.arguments.count,
           let tab = Int(ProcessInfo.processInfo.arguments[idx + 1]) {
            return tab
        }
        return 0
    }()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleView()
                .environmentObject(store)
                .tabItem {
                    Image(uiImage: TabIcons.schedule)
                    Text("Schedule")
                }
                .tag(0)
            
            TasksView()
                .environmentObject(store)
                .tabItem {
                    Image(uiImage: TabIcons.tasks)
                    Text("Tasks")
                }
                .tag(1)
            
            StudyTimerView()
                .environmentObject(store)
                .tabItem {
                    Image(uiImage: TabIcons.timer)
                    Text("Timer")
                }
                .tag(2)
            
            StatsView()
                .environmentObject(store)
                .tabItem {
                    Image(uiImage: TabIcons.stats)
                    Text("Stats")
                }
                .tag(3)
            
            NotesView()
                .environmentObject(store)
                .tabItem {
                    Image(uiImage: TabIcons.notes)
                    Text("Notes")
                }
                .tag(4)
        }
        .accentColor(AppColors.gold)
        .preferredColorScheme(.light)
    }
}
