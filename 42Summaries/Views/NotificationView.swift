//
//  NotificationView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 05.10.24.
//
import SwiftUI

struct NotificationView: View {
    let message: String
    let type: NotificationType
    let dismissAction: () -> Void
    
    enum NotificationType {
        case success, warning, info
    }
    
    var body: some View {
        HStack(spacing: 16) {
            icon
            
            VStack(alignment: .leading, spacing: 4) {
                Text(type.title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Button(action: dismissAction) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(type.backgroundColor)
        .cornerRadius(8)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private var icon: some View {
        Image(systemName: type.iconName)
            .font(.system(size: 24))
            .foregroundColor(type.iconColor)
    }
}

extension NotificationView.NotificationType {
    var title: String {
        switch self {
        case .success: return "Success"
        case .warning: return "Warning"
        case .info: return "Information"
        }
    }
    
    var iconName: String {
        switch self {
        case .success: return "checkmark.circle"
        case .warning: return "exclamationmark.triangle"
        case .info: return "info.circle"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .success: return .green
        case .warning: return .yellow
        case .info: return .blue
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .success: return .green.opacity(0.1)
        case .warning: return .yellow.opacity(0.1)
        case .info: return .blue.opacity(0.1)
        }
    }
}

