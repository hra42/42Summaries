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
    var appState: AppState
    
    init(summaryService: SummaryService, appState: AppState) {
        self.summaryService = summaryService
        self.appState = appState
    }
    
    func generateSummary(from transcription: String) {
        isGeneratingSummary = true
        errorMessage = nil
        Task {
            do {
                let storedPrompts = UserDefaults.standard.data(forKey: "prompts")
                let prompts: [Prompt]
                
                if let storedPrompts = storedPrompts, !storedPrompts.isEmpty {
                    do {
                        prompts = try JSONDecoder().decode([Prompt].self, from: storedPrompts)
                    } catch {
                        print("Error decoding prompts in SummaryViewModel: \(error)")
                        prompts = SettingsView.defaultPrompts
                        // Save default prompts to fix the corrupted data
                        UserDefaults.standard.set(try? JSONEncoder().encode(prompts), forKey: "prompts")
                    }
                } else {
                    print("No stored prompts found, using defaults")
                    prompts = SettingsView.defaultPrompts
                    // Save default prompts
                    UserDefaults.standard.set(try? JSONEncoder().encode(prompts), forKey: "prompts")
                }

                let selectedPromptId = UserDefaults.standard.string(forKey: "selectedPromptId") ?? ""
                let selectedPrompt: Prompt
                if let prompt = prompts.first(where: { $0.id.uuidString == selectedPromptId }) {
                    selectedPrompt = prompt
                } else {
                    print("No matching prompt found for ID: \(selectedPromptId), using first prompt")
                    selectedPrompt = prompts[0]
                    // Save the first prompt as selected
                    UserDefaults.standard.set(selectedPrompt.id.uuidString, forKey: "selectedPromptId")
                }

                let generatedSummary = try await summaryService.generateSummary(from: transcription, using: selectedPrompt.content)
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
        // Use the @EnvironmentObject appState to create the viewModel
        _viewModel = StateObject(wrappedValue: SummaryViewModel(summaryService: AppState().summaryService, appState: AppState()))
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
        .onAppear {
            // Update the viewModel's appState reference when the view appears
            viewModel.appState = self.appState
        }
    }
}
