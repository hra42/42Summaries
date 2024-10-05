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
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(notificationManager)
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
