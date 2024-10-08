import SwiftUI

struct MainWindowView: View {
    @StateObject private var navigationManager = NavigationStateManager()
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationSplitView {
            SidebarView(navigationManager: navigationManager)
        } detail: {
            mainContent
        }
        .navigationTitle("")
        .onChange(of: navigationManager.selectedNavItem) { oldValue, newValue in
            print("MainWindowView detected change in selectedNavItem from \(oldValue) to \(newValue)")
        }
    }
    
    var mainContent: some View {
        NavigationStack {
            Group {
                switch navigationManager.selectedNavItem {
                case .fileSelection:
                    FileSelectionView()
                case .transcription:
                    TranscriptionView(transcriptionManager: appState.transcriptionManager)
                case .summary:
                    SummaryView()
                case .settings:
                    SettingsView()
                case .homeView:
                    WelcomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    HStack {
                        Image("AppIconImage")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32)
                        Text("42Summaries")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

struct MainWindowView_Previews: PreviewProvider {
    static var previews: some View {
        MainWindowView()
            .environmentObject(NotificationManager())
            .environmentObject(AppState())
    }
}
