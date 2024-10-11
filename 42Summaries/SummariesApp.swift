import SwiftUI
import UserNotifications

@main
struct _42Summaries: App {
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.modelState == .loaded {
                    MainWindowView()
                        .environmentObject(notificationManager)
                        .environmentObject(appState)
                } else {
                    LaunchScreenView()
                        .environmentObject(appState)
                        .onAppear {
                            initializeWhisperKit()
                        }
                }
            }
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About 42Summaries") {
                    NSApp.sendAction(#selector(AppDelegate.showAboutView), to: nil, from: nil)
                }
            }
        }
    }
    
    private func initializeWhisperKit() {
        Task {
            do {
                try await appState.initializeWhisperKit()
            } catch {
            }
        }
    }
}

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
