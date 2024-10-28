import SwiftUI

struct ExportOptionsView: View {
    enum ExportSource {
        case transcription
        case summary
    }
    
    let content: String
    let fileName: String
    let selectedPrompt: String?
    let source: ExportSource // New parameter
    @Binding var fontSize: CGFloat
    @Binding var textAlignment: TextAlignment
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var notificationManager: NotificationManager
    @State private var showingChatGPTInstructions = false
    @State private var showingClaudeAIInstructions = false
    @State private var showingPerplexityInstructions: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Options")
                .font(.title)
                .fontWeight(.bold)
            
            if source == .transcription {
                Button("Export to ChatGPT") {
                    showingChatGPTInstructions = true
                }
            }
            
            if source == .transcription {
                Button("Export to Claude") {
                    showingClaudeAIInstructions = true
                }
            }
            
            if source == .transcription {
                Button("Export to Perplexity") {
                    showingPerplexityInstructions = true
                }
            }
            
            Button("Export as PDF") {
                ExportManager.exportAsPDF(content: content, fontSize: fontSize, alignment: textAlignment.toNSTextAlignment(), fileName: fileName)
                presentationMode.wrappedValue.dismiss()
            }
            
            Button("Export as TXT") {
                ExportManager.exportAsTXT(content: content, fileName: fileName)
                presentationMode.wrappedValue.dismiss()
            }
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .alert("Export to ChatGPT", isPresented: $showingChatGPTInstructions) {
            Button("Continue") {
                exportToChatGPT()
                presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("""
                 The content has been copied to your clipboard.
                 After clicking Continue:\n
                 1. ChatGPT will open in your browser
                 2. Wait for the page to load
                 3. Click in the chat input field
                 4. Press Cmd+V to paste
                 """)
        }
        .alert("Export to Claude", isPresented: $showingClaudeAIInstructions) {
            Button("Continue") {
                exportToClaudeAI()
                presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("""
                The content has been copied to your clipboard.
                After clicking Continue:\n
                1. Claude will open in your browser
                2. Wait for the page to load
                3. Click in the chat input field
                4. Press Cmd+V to paste
                """)
            }
        .alert("Export to Perplexity", isPresented: $showingPerplexityInstructions) {
            Button("Continue") {
                exportToPPLX()
                presentationMode.wrappedValue.dismiss() }
            Button("Cancel", role: .cancel) { }
        } message: {
                Text("""
                The content has been copied to your clipboard.
                After clicking Continue:\n
                1. Perplexity will open in your browser
                2. Wait for the page to load
                3. Click in the chat input field
                4. Select Writing Focus
                5. Deactivate Pro Mode
                6. Press Cmd+V to paste
                """)
            }
        }
    
    private func exportToChatGPT() {
        let providerURL = "https://chat.openai.com"
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        // Format the content with the prompt if available
        var exportContent = ""
        if let prompt = selectedPrompt {
            exportContent += prompt + "\n\n"
        }
        exportContent += content
        
        pasteboard.setString(exportContent, forType: .string)
        
        if let url = URL(string: providerURL) {
            NSWorkspace.shared.open(url)
        }
        
        notificationManager.showNotification(
            title: "Content Copied",
            body: "ChatGPT is opening. Press Cmd+V to paste when ready."
        )
    }
    
    private func exportToClaudeAI() {
        let providerURL = "https://claude.ai"
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        // Format the content with the prompt if available
        var exportContent = ""
        if let prompt = selectedPrompt {
            exportContent += prompt + "\n\n"
        }
        exportContent += content
        
        pasteboard.setString(exportContent, forType: .string)
        
        if let url = URL(string: providerURL) {
            NSWorkspace.shared.open(url)
        }
        
        notificationManager.showNotification(
            title: "Content Copied",
            body: "Claude is opening. Press Cmd+V to paste when ready."
        )
    }
    
    private func exportToPPLX() {
        let providerURL = "https://www.perplexity.ai/search?mode=writing"
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        // Format the content with the prompt if available
        var exportContent = ""
        if let prompt = selectedPrompt {
            exportContent += prompt + "\n\n"
        }
        exportContent += content
        
        pasteboard.setString(exportContent, forType: .string)
        
        if let url = URL(string: providerURL) {
            NSWorkspace.shared.open(url)
        }
        
        notificationManager.showNotification(
            title: "Content Copied",
            body: "Perplexity is opening. Press Cmd+V to paste when ready."
        )
    }
}

extension TextAlignment {
    func toNSTextAlignment() -> NSTextAlignment {
        switch self {
        case .leading:
            return .left
        case .center:
            return .center
        case .trailing:
            return .right
        }
    }
}
