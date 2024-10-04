//
//  SummaryView.swift
//  App42Summaries
//
//  Created by Henry Rausch on 04.10.24.
//
import SwiftUI
import AppKit

class SummaryViewModel: ObservableObject {
    @Published var summary: String
    @Published var fontSize: CGFloat
    @Published var textAlignment: TextAlignment
    @Published var showFormatting: Bool
    @Published var showExportOptions: Bool
    
    init(summary: String? = nil) {
        self.summary = summary ?? "This is a sample summary of the transcribed content. It highlights key points and main ideas from the audio or video file."
        self.fontSize = 16
        self.textAlignment = .leading
        self.showFormatting = false
        self.showExportOptions = false
    }
    
    func toggleFormatting() {
        showFormatting.toggle()
    }
    
    func toggleExportOptions() {
        showExportOptions.toggle()
    }
    
    func copySummary() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(summary, forType: .string)
    }
}

struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Summary")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            ScrollView {
                Text(viewModel.summary)
                    .font(.system(size: viewModel.fontSize))
                    .multilineTextAlignment(viewModel.textAlignment)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: viewModel.textAlignment == .center ? .center : (viewModel.textAlignment == .trailing ? .trailing : .leading))
            }
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            
            HStack {
                Button(action: viewModel.toggleFormatting) {
                    Label("Format", systemImage: "textformat")
                }
                
                Spacer()
                
                Button(action: viewModel.copySummary) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                
                Button(action: viewModel.toggleExportOptions) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
            .padding(.horizontal)
            
            if viewModel.showFormatting {
                VStack {
                    Slider(value: $viewModel.fontSize, in: 12...24, step: 1) {
                        Text("Font Size: \(Int(viewModel.fontSize))")
                    }
                    
                    Picker("Text Alignment", selection: $viewModel.textAlignment) {
                        Text("Left").tag(TextAlignment.leading)
                        Text("Center").tag(TextAlignment.center)
                        Text("Right").tag(TextAlignment.trailing)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $viewModel.showExportOptions) {
            ExportOptionsView(viewModel: viewModel)
        }
    }
}

#Preview {
    SummaryView()
}
