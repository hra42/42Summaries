import SwiftUI
import UserNotifications

@main
struct _42Summaries: App {
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isModelReady = false
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isModelReady {
                    MainWindowView()
                        .environmentObject(notificationManager)
                        .environmentObject(appState)
                } else {
                    LaunchScreenView(progress: $appState.modelDownloadProgress)
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
                try await appState.initializeWhisperKit { progress in
                    DispatchQueue.main.async {
                        appState.modelDownloadProgress = progress
                    }
                }
                isModelReady = true
            } catch {
                print("Error initializing WhisperKit: \(error)")
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
