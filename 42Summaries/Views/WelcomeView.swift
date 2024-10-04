//
//  WelcomeView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Image("AppIconImage") // Use the name you gave to the Image Set
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
            Text("Welcome to 42Summaries")
                .font(.title)
            Text("Select an item from the sidebar to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WelcomeView()
}
