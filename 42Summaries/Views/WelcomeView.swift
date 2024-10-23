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
            Text("Please follow the getting started guide to get started")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("https://42summaries.com/#get-started")
                .font(.caption)
                .foregroundColor(.secondary)
                .underline()
            Text("If you followed the guide please click on select file to get started with trasforming your content")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
