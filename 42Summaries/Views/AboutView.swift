//
//  AboutView.swift
//  42Summaries
//
//  Created by Henry Rausch on 05.10.24.
//
import SwiftUI

struct AboutView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                appHeader
                appDescription
                howToUseSection
                creditsSection
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 500)
    }
    
    private var appHeader: some View {
        VStack {
            Image("AppIconImage") // Make sure you have an app icon image in your asset catalog
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("42Summaries")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Transcribe and Summarize with Ease")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var appDescription: some View {
        Text("42Summaries is a powerful macOS application that transcribes audio and video files, then generates concise summaries using Ollama. Streamline your workflow and save time with automated transcription and summarization.")
            .font(.body)
            .multilineTextAlignment(.center)
    }
    
    private var howToUseSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How to Use")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 5) {
                bulletPoint("Select an audio or video file")
                bulletPoint("Wait for transcription to complete")
                bulletPoint("Review the generated summary")
                bulletPoint("Export or copy the summary as needed")
            }
        }
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text)
        }
    }
    
    private var creditsSection: some View {
        VStack {
            Text("Credits")
                .font(.headline)
            
            Text("Developed by Henry Rausch")
            
            Link("Visit the 42 Summaries website", destination: URL(string: "https://www.42summaries.com")!)
                .padding(.top, 5)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
