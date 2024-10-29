import Foundation
import MSAL

class TeamsAPIClient {
    private let accessToken: String
    private let baseURL = "https://graph.microsoft.com/v1.0"
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func getTeams() async throws -> [Team] {
        let endpoint = "\(baseURL)/me/joinedTeams"
        
        guard let url = URL(string: endpoint) else {
            throw TeamsAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TeamsAPIError.requestFailed
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            print("Teams API Error: \(String(data: data, encoding: .utf8) ?? "")")
            throw TeamsAPIError.httpError(httpResponse.statusCode)
        }
        
        let teamsResponse = try JSONDecoder().decode(TeamsResponse.self, from: data)
        return teamsResponse.value
    }
    
    func getChannels(teamId: String) async throws -> [Channel] {
        let endpoint = "\(baseURL)/teams/\(teamId)/channels"
        
        guard let url = URL(string: endpoint) else {
            throw TeamsAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TeamsAPIError.requestFailed
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            print("Teams API Error: \(String(data: data, encoding: .utf8) ?? "")")
            throw TeamsAPIError.httpError(httpResponse.statusCode)
        }
        
        let channelsResponse = try JSONDecoder().decode(ChannelsResponse.self, from: data)
        return channelsResponse.value
    }

    struct Attachment: Codable {
        var contentType = "application/vnd.microsoft.card.adaptive"
        var contentUrl: String?
        var content: AdaptiveCard
        
        init(content: AdaptiveCard) {
            self.contentUrl = nil
            self.content = content
        }
    }

    struct AdaptiveCard: Codable {
        var schema = "$schema"
        var type = "AdaptiveCard"
        var version = "1.5"
        let body: [CardElement]
    }

    struct CardElement: Codable {
        let type: String
        let text: String?
        let weight: String?
        let size: String?
        let wrap: Bool?
        let style: String?
        let items: [CardElement]?
        let spacing: String?
        
        init(type: String,
             text: String? = nil,
             weight: String? = nil,
             size: String? = nil,
             wrap: Bool? = nil,
             style: String? = nil,
             items: [CardElement]? = nil,
             spacing: String? = nil) {
            self.type = type
            self.text = text
            self.weight = weight
            self.size = size
            self.wrap = wrap
            self.style = style
            self.items = items
            self.spacing = spacing
        }
    }
    
    func sendFormattedMessage(channelId: String, teamId: String, content: String) async throws {
        let endpoint = "\(baseURL)/teams/\(teamId)/channels/\(channelId)/messages"
        
        guard let url = URL(string: endpoint) else {
            throw TeamsAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Parse content into lines
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Create the adaptive card structure
        var cardBody: [[String: Any]] = [
            // Header with logo and app name
            [
                "type": "ColumnSet",
                "columns": [
                    [
                        "type": "Column",
                        "items": [
                            [
                                "type": "Image",
                                "url": "https://42summaries.com/logo_new.png",
                                "size": "large"
                            ]
                        ],
                        "verticalContentAlignment": "Center"
                    ],
                    [
                        "type": "Column",
                        "width": "stretch",
                        "items": [
                            [
                                "type": "TextBlock",
                                "text": "Summaries",
                                "size": "Large",
                                "weight": "Bolder",
                                "color": "Default"
                            ]
                        ],
                        "verticalContentAlignment": "Center"
                    ]
                ],
                "spacing": "None",
                "style": "default"
            ]
        ]
        
        var isFirstContentLine = true
        
        // Process all lines
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip the title line if it's "Summaries"
            if trimmedLine == "Summaries" {
                continue
            }
            
            if isFirstContentLine {
                isFirstContentLine = false
                cardBody.append([
                    "type": "TextBlock",
                    "text": trimmedLine,
                    "wrap": true,
                    "size": "Medium",
                    "weight": "Bolder",
                    "spacing": "Medium"
                ])
            } else {
                // Handle bullet points and other content
                if trimmedLine.hasPrefix("* ") {
                    // Main bullet points
                    let content = String(trimmedLine.dropFirst(2))
                    cardBody.append([
                        "type": "TextBlock",
                        "text": "• \(content)",
                        "wrap": true,
                        "spacing": "Small"
                    ])
                } else if trimmedLine.hasPrefix("  - ") {
                    // Sub-bullet points
                    let content = trimmedLine.replacingOccurrences(of: "  - ", with: "")
                    cardBody.append([
                        "type": "TextBlock",
                        "text": "  ‣ \(content)",
                        "wrap": true,
                        "spacing": "Small",
                        "isSubtle": true
                    ])
                } else {
                    // Handle lines that start with bullet points but without the "* " prefix
                    if trimmedLine.hasPrefix("•") {
                        let content = trimmedLine.replacingOccurrences(of: "•", with: "").trimmingCharacters(in: .whitespaces)
                        cardBody.append([
                            "type": "TextBlock",
                            "text": "• \(content)",
                            "wrap": true,
                            "spacing": "Small"
                        ])
                    } else {
                        // Regular text
                        cardBody.append([
                            "type": "TextBlock",
                            "text": trimmedLine,
                            "wrap": true,
                            "spacing": "Small"
                        ])
                    }
                }
            }
        }
        
        // Create the complete adaptive card
        let adaptiveCard: [String: Any] = [
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": cardBody
        ]
        
        // Generate unique message ID and create the final message structure
        let messageId = UUID().uuidString
        let adaptiveCardData = try JSONSerialization.data(withJSONObject: adaptiveCard)
        let adaptiveCardString = String(data: adaptiveCardData, encoding: .utf8)!
        
        let message: [String: Any] = [
            "body": [
                "contentType": "html",
                "content": "<attachment id=\"\(messageId)\"></attachment>"
            ],
            "attachments": [
                [
                    "id": messageId,
                    "contentType": "application/vnd.microsoft.card.adaptive",
                    "contentUrl": nil,
                    "content": adaptiveCardString
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: message)
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TeamsAPIError.requestFailed
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            print("Teams API Error: \(String(data: responseData, encoding: .utf8) ?? "")")
            throw TeamsAPIError.httpError(httpResponse.statusCode)
        }
    }
}


struct Team: Codable, Identifiable, Hashable {
    let id: String
    let displayName: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
}

struct Channel: Codable, Identifiable, Hashable {
    let id: String
    let displayName: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
    }
}

struct TeamsResponse: Codable {
    let value: [Team]
}

struct ChannelsResponse: Codable {
    let value: [Channel]
}

struct TeamsMessage: Codable {
    let body: MessageBody
    
    init(content: String) {
        self.body = MessageBody(content: content)
    }
}

struct MessageBody: Codable {
    let contentType: String
    let content: String
    
    init(content: String) {
        self.contentType = "html"
        self.content = content
    }
}

enum TeamsAPIError: LocalizedError {
    case invalidURL
    case requestFailed
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed:
            return "Request failed"
        case .httpError(let code):
            return "HTTP error: \(code)"
        }
    }
}

class TeamsAuthManager {
    static let shared = TeamsAuthManager()
    private var application: MSALPublicClientApplication?
    private var cachedToken: (token: String, expiration: Date)?
    private let scopes = [
        "https://graph.microsoft.com/ChannelMessage.Send",
        "https://graph.microsoft.com/Team.ReadBasic.All",
        "https://graph.microsoft.com/Channel.ReadBasic.All",
        "https://graph.microsoft.com/User.Read"
    ]
    
    private init() {}
    
    func configure(clientId: String, tenantId: String) {
        let authority = "https://login.microsoftonline.com/\(tenantId)"
        
        guard let authorityURL = URL(string: authority),
              let msalAuthority = try? MSALAADAuthority(url: authorityURL) else {
            print("Failed to create MSAL Authority")
            return
        }
        
        let redirectUri = "msauth.tech.postrausch.42Summaries://auth"
        
        let config = MSALPublicClientApplicationConfig(
            clientId: clientId,
            redirectUri: redirectUri,
            authority: msalAuthority
        )
        
        do {
            application = try MSALPublicClientApplication(configuration: config)
        } catch {
            print("Failed to initialize MSAL Application: \(error)")
        }
    }
    
    func getTeamsClient(clientId: String, tenantId: String) async throws -> TeamsAPIClient {
        // Check if we have a valid cached token
        if let cached = cachedToken, cached.expiration > Date() {
            return TeamsAPIClient(accessToken: cached.token)
        }
        
        // If not configured, configure with provided credentials
        if application == nil {
            configure(clientId: clientId, tenantId: tenantId)
        }
        
        // Try silent auth first
        do {
            let token = try await silentAuthenticate()
            cachedToken = (token, Date().addingTimeInterval(3600)) // Cache for 1 hour
            return TeamsAPIClient(accessToken: token)
        } catch {
            // Fall back to interactive auth
            let token = try await authenticate()
            cachedToken = (token, Date().addingTimeInterval(3600)) // Cache for 1 hour
            return TeamsAPIClient(accessToken: token)
        }
    }

    private func authenticate() async throws -> String {
        guard let application = application else {
            throw TeamsAuthError.applicationNotInitialized
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let webviewParameters = MSALWebviewParameters()
            webviewParameters.prefersEphemeralWebBrowserSession = false
            
            let interactiveParameters = MSALInteractiveTokenParameters(
                scopes: scopes,
                webviewParameters: webviewParameters
            )
            
            application.acquireToken(with: interactiveParameters) { (result, error) in
                if let error = error {
                    continuation.resume(throwing: TeamsAuthError.authenticationFailed(error))
                    return
                }
                
                guard let result = result else {
                    continuation.resume(throwing: TeamsAuthError.noResult)
                    return
                }
                
                continuation.resume(returning: result.accessToken)
            }
        }
    }
    
    private func silentAuthenticate() async throws -> String {
        guard let application = application else {
            throw TeamsAuthError.applicationNotInitialized
        }
        
        let accounts = try application.allAccounts()
        guard let account = accounts.first else {
            throw TeamsAuthError.noAccount
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: account)
            
            application.acquireTokenSilent(with: silentParameters) { (result, error) in
                if let error = error {
                    continuation.resume(throwing: TeamsAuthError.authenticationFailed(error))
                    return
                }
                
                guard let result = result else {
                    continuation.resume(throwing: TeamsAuthError.noResult)
                    return
                }
                
                continuation.resume(returning: result.accessToken)
            }
        }
    }
}

enum TeamsAuthError: LocalizedError {
    case applicationNotInitialized
    case authenticationFailed(Error)
    case noResult
    case noAccount
    
    var errorDescription: String? {
        switch self {
        case .applicationNotInitialized:
            return "Failed to initialize MSAL application"
        case .authenticationFailed(let error):
            return "Authentication failed: \(error.localizedDescription)"
        case .noResult:
            return "No authentication result received"
        case .noAccount:
            return "No account found"
        }
    }
}
