import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @StateObject private var workplaceManager = WorkplaceManager()
    
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("カレンダー")
                }
                .environmentObject(appState)
                .environmentObject(workplaceManager)
            
            TaskListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("タスク")
                }
                .environmentObject(appState)
            
            TimetableView()
                .tabItem {
                    Image(systemName: "table")
                    Text("時間割")
                }
                .environmentObject(appState)
            
            ShiftView()
                .tabItem {
                    Image(systemName: "briefcase")
                    Text("シフト")
                }
                .environmentObject(appState)
                .environmentObject(workplaceManager)
        }
    }
}

#Preview {
    ContentView()
}
