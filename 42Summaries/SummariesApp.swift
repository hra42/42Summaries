//
//  42SummariesApp.swift
//  42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI
import UserNotifications

@main
struct _42Summaries: App {
    @StateObject private var notificationManager = NotificationManager()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isLaunchScreenDone = false
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLaunchScreenDone {
                    MainWindowView()
                        .environmentObject(notificationManager)
                } else {
                    LaunchScreenView()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isLaunchScreenDone = true
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
}

// ... (keep the existing NotificationHandler)


class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
