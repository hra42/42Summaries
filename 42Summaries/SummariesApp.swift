//
//  42SummariesApp.swift
//  42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI

@main
struct SummariesApp: App {
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(notificationManager)
        }
    }
}
