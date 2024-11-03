import SwiftUI

struct ExportOptionsView: View {
    enum ExportSource {
        case transcription
        case summary
    }
    
    let content: String
    let fileName: String
    let selectedPrompt: String?
    let source: ExportSource
    @Binding var fontSize: CGFloat
    @Binding var textAlignment: TextAlignment
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var notificationManager: NotificationManager
    @State private var showingChatGPTInstructions = false
    @State private var showingClaudeAIInstructions = false
    @State private var showingPerplexityInstructions: Bool = false
    @State private var showingTeamsSelection = false
    @AppStorage("teamsClientId") private var teamsClientId = ""
    @AppStorage("teamsTenantId") private var teamsTenantId = ""
    
    @State private var teams: [Team] = []
    @State private var channels: [Channel] = []
    @State private var selectedTeam: Team?
    @State private var selectedChannel: Channel?
    @State private var isLoadingTeams = false
    @State private var isLoadingChannels = false
    @State private var teamsError: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Options")
                .font(.title)
                .fontWeight(.bold)
            
            if source == .transcription {
                Button("Export to ChatGPT") {
                    showingChatGPTInstructions = true
                }
                
                Button("Export to Claude") {
                    showingClaudeAIInstructions = true
                }
                
                Button("Export to Perplexity") {
                    showingPerplexityInstructions = true
                }
            }
            
            if source == .summary {
                Button("Export to Teams") {
                    loadTeams()
                    showingTeamsSelection = true
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
                presentationMode.wrappedValue.dismiss()
            }
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
        .sheet(isPresented: $showingTeamsSelection) {
            TeamsSelectionView(
                content: content,
                teams: teams,
                channels: channels,
                selectedTeam: $selectedTeam,
                selectedChannel: $selectedChannel,
                isLoadingTeams: isLoadingTeams,
                isLoadingChannels: isLoadingChannels,
                error: teamsError,
                onTeamSelected: { team in
                    Task {
                        await loadChannels(for: team)
                    }
                },
                onExport: exportToTeams
            )
        }
    }
    
    private func exportToChatGPT() {
        let providerURL = "https://chat.openai.com"
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
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
    
    private func loadTeams() {
        guard !teamsClientId.isEmpty && !teamsTenantId.isEmpty else {
            teamsError = "Please configure Teams Client ID and Tenant ID in Settings"
            return
        }
        
        isLoadingTeams = true
        teamsError = nil
        
        Task {
            do {
                let client = try await TeamsAuthManager.shared.getTeamsClient(
                    clientId: teamsClientId,
                    tenantId: teamsTenantId
                )
                teams = try await client.getTeams()
                
                if let team = teams.first {
                    selectedTeam = team
                    await loadChannels(for: team)
                }
            } catch {
                await MainActor.run {
                    teamsError = error.localizedDescription
                }
            }
            
            await MainActor.run {
                isLoadingTeams = false
            }
        }
    }
    
    private func loadChannels(for team: Team) async {
        await MainActor.run {
            isLoadingChannels = true
            teamsError = nil
        }
        
        do {
            let client = try await TeamsAuthManager.shared.getTeamsClient(
                clientId: teamsClientId,
                tenantId: teamsTenantId
            )
            channels = try await client.getChannels(teamId: team.id)
            
            if let channel = channels.first {
                selectedChannel = channel
            }
        } catch {
            await MainActor.run {
                teamsError = error.localizedDescription
            }
        }
        
        await MainActor.run {
            isLoadingChannels = false
        }
    }
    
    private func exportToTeams() {
        guard let team = selectedTeam,
              let channel = selectedChannel else {
            return
        }
        
        Task {
            do {
                let client = try await TeamsAuthManager.shared.getTeamsClient(
                    clientId: teamsClientId,
                    tenantId: teamsTenantId
                )
                
                try await client.sendFormattedMessage(
                    channelId: channel.id,
                    teamId: team.id,
                    content: content
                )
                
                await MainActor.run {
                    notificationManager.showNotification(
                        title: "Success",
                        body: "Content exported to Teams"
                    )
                    showingTeamsSelection = false
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                await MainActor.run {
                    teamsError = error.localizedDescription
                    notificationManager.showNotification(
                        title: "Error",
                        body: "Failed to export to Teams: \(error.localizedDescription)"
                    )
                }
            }
        }
    }
}

struct TeamsSelectionView: View {
    let content: String
    let teams: [Team]
    let channels: [Channel]
    @Binding var selectedTeam: Team?
    @Binding var selectedChannel: Channel?
    let isLoadingTeams: Bool
    let isLoadingChannels: Bool
    let error: String?
    let onTeamSelected: (Team) -> Void
    let onExport: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export to Teams")
                .font(.title2)
                .fontWeight(.bold)
            
            if isLoadingTeams {
                ProgressView("Loading teams...")
            } else if isLoadingChannels {
                ProgressView("Loading channels...")
            } else if let error = error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                Picker("Select Team", selection: $selectedTeam) {
                    ForEach(teams) { team in
                        Text(team.displayName).tag(Optional(team))
                    }
                }
                .onChange(of: selectedTeam) { _, newTeam in
                    if let team = newTeam {
                        onTeamSelected(team)
                    }
                }
                
                if !channels.isEmpty {
                    Picker("Select Channel", selection: $selectedChannel) {
                        ForEach(channels) { channel in
                            Text(channel.displayName).tag(Optional(channel))
                        }
                    }
                }
                
                Button("Export") {
                    onExport()
                }
                .disabled(selectedTeam == nil || selectedChannel == nil)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
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
