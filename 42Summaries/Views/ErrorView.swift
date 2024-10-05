//
//  ErrorView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 05.10.24.
//
import SwiftUI

struct ErrorView: View {
    let error: Error
    let dismissAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
            
            Button("Dismiss") {
                dismissAction()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}
