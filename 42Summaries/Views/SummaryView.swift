import SwiftUI
import AppKit

class SummaryViewModel: ObservableObject {
    @Published var fontSize: CGFloat = 16
    @Published var textAlignment: TextAlignment = .leading
    @Published var showFormatting: Bool = false
    @Published var showExportOptions: Bool = false
    @Published var isGeneratingSummary: Bool = false
    @Published var errorMessage: String?
    
    private let summaryService: SummaryService
    private let appState: AppState

    init(summaryService: SummaryService, appState: AppState) {
        self.summaryService = summaryService
        self.appState = appState
    }

    func generateSummary(from transcription: String) {
        isGeneratingSummary = true
        errorMessage = nil
        Task {
            do {
                let generatedSummary = try await summaryService.generateSummary(from: transcription)
                await MainActor.run {
                    self.appState.summary = generatedSummary
                    self.isGeneratingSummary = false
                }
            } catch let error as SummaryError {
                await MainActor.run {
                    self.errorMessage = error.description
                    self.isGeneratingSummary = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Unexpected error: \(error.localizedDescription)"
                    self.isGeneratingSummary = false
                }
            }
        }
    }
    
    func toggleFormatting() {
        showFormatting.toggle()
    }
    
    func toggleExportOptions() {
        showExportOptions.toggle()
    }
    
    func copySummary(summary: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(summary, forType: .string)
    }
}

struct SummaryView: View {
    @StateObject private var viewModel: SummaryViewModel
    @EnvironmentObject private var appState: AppState
    
    init() {
        let appState = AppState()
        _viewModel = StateObject(wrappedValue: SummaryViewModel(summaryService: appState.summaryService, appState: appState))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Summary")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            ZStack {
                ScrollView {
                    Text(appState.summary.isEmpty ? "No summary generated yet." : appState.summary)
                        .font(.system(size: viewModel.fontSize))
                        .multilineTextAlignment(viewModel.textAlignment)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: viewModel.textAlignment == .center ? .center : (viewModel.textAlignment == .trailing ? .trailing : .leading))
                }
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
                if viewModel.isGeneratingSummary {
                    ProgressView("Generating Summary...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.secondary.opacity(0.5))
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.secondary.opacity(0.5))
                }
            }
            .frame(height: 300)
            
            HStack {
                Button(action: {
                    viewModel.generateSummary(from: appState.transcriptionManager.transcriptionResult)
                }) {
                    Label("Generate Summary", systemImage: "wand.and.stars")
                }
                .disabled(appState.transcriptionManager.transcriptionResult.isEmpty || viewModel.isGeneratingSummary)
                
                Spacer()
                
                Button(action: viewModel.toggleFormatting) {
                    Label("Format", systemImage: "textformat")
                }
                
                Button(action: { viewModel.copySummary(summary: appState.summary) }) {
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
            ExportOptionsView(
                content: appState.summary,
                fileName: "Summary",
                fontSize: $viewModel.fontSize,
                textAlignment: $viewModel.textAlignment
            )
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
            .environmentObject(AppState())
    }
}
