import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    @Published var isNotificationPermissionGranted = false

    init() {
        checkNotificationAuthorization()
    }
    
    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.requestAuthorization()
                case .denied:
                    self.isNotificationPermissionGranted = false
                case .authorized, .provisional, .ephemeral:
                    self.isNotificationPermissionGranted = true
                @unknown default:
                    break
                }
            }
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.isNotificationPermissionGranted = true
                } else if let error = error {
                    self.isNotificationPermissionGranted = false
                }
            }
        }
    }
    
    func showNotification(title: String, body: String) {
        if isNotificationPermissionGranted {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default
            content.interruptionLevel = .timeSensitive
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                }
            }
        } else {
            requestAuthorization()
        }
    }
}
