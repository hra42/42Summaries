//
//  FileSelectionView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI
import UniformTypeIdentifiers

struct FileSelectionView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isFilePickerPresented = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("File Selection")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Select an Audio or Video File")
                .font(.title)
            
            Button(action: {
                isFilePickerPresented = true
            }) {
                Label("Choose File", systemImage: "doc.badge.plus")
            }
            .buttonStyle(.bordered)
            
            if let selectedFile = appState.selectedFile {
                FileInfoView(url: selectedFile)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.audio, .movie],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                if let url = files.first {
                    if url.startAccessingSecurityScopedResource() {
                        let accessibleURL = url.standardizedFileURL
                        appState.selectedFile = accessibleURL
                        appState.transcriptionManager.setSelectedFile(accessibleURL)
                    }
                }
            case .failure(_):
                sleep(0)
            }
        }
    }
}

struct FileInfoView: View {
    let url: URL
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Selected File:")
                .font(.headline)
            Text("Name: \(url.lastPathComponent)")
            Text("Type: \(url.pathExtension.uppercased())")
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    FileSelectionView()
        .environmentObject(AppState())
}
