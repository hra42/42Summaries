//
//  FileSelectionView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI
import UniformTypeIdentifiers

struct FileSelectionView: View {
    @State private var selectedFile: URL?
    @State private var isFilePickerPresented = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select an Audio or Video File")
                .font(.title)
            
            Button(action: {
                isFilePickerPresented = true
            }) {
                Label("Choose File", systemImage: "doc.badge.plus")
            }
            .buttonStyle(.bordered)
            
            FileDragAndDropArea(selectedFile: $selectedFile)
            
            if let selectedFile = selectedFile {
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
                selectedFile = files.first
            case .failure(let error):
                print("Error selecting file: \(error.localizedDescription)")
            }
        }
    }
}

struct FileDragAndDropArea: View {
    @Binding var selectedFile: URL?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundColor(.secondary)
            
            VStack {
                Image(systemName: "arrow.down.doc")
                    .font(.largeTitle)
                Text("Drag and drop your file here")
                    .font(.headline)
            }
        }
        .frame(height: 150)
        .onDrop(of: [.audio, .movie], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            
            provider.loadItem(forTypeIdentifier: UTType.audio.identifier) { item, _ in
                if let url = item as? URL {
                    selectedFile = url
                }
            }
            
            return true
        }
    }
}

struct FileInfoView: View {
    let url: URL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
}
