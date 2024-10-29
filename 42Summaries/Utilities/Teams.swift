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

    func sendMessage(channelId: String, teamId: String, content: String) async throws {
        let endpoint = "\(baseURL)/teams/\(teamId)/channels/\(channelId)/messages"
        
        guard let url = URL(string: endpoint) else {
            throw TeamsAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let lines = content.components(separatedBy: "\n")
        let title = lines[0].trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        var bodyElements: [[String: Any]] = [
            [
                "type": "Container",
                "bleed": true,
                "items": [
                    [
                        "type": "Table",
                        "showGridLines": false,
                        "columns": [
                            ["width": 1],
                            ["width": 4]
                        ],
                        "rows": [
                            [
                                "type": "TableRow",
                                "cells": [
                                    [
                                        "type": "TableCell",
                                        "items": [
                                            [
                                                "type": "Image",
                                                "url": "https://public-files.postrausch.tech/Logo_new.png",
                                                "size": "Large"
                                            ]
                                        ]
                                    ],
                                    [
                                        "type": "TableCell",
                                        "items": [
                                            [
                                                "type": "TextBlock",
                                                "text": "42Summaries",
                                                "wrap": true,
                                                "size": "Large",
                                                "weight": "Bolder"
                                            ]
                                        ],
                                        "verticalContentAlignment": "Center",
                                        "spacing": "None"
                                    ]
                                ],
                                "style": "accent"
                            ]
                        ]
                    ]
                ],
                "minHeight": "0px",
                "backgroundImage": [
                    "url": "["
                ]
            ],
            [
                "type": "TextBlock",
                "text": title,
                "wrap": true,
                "style": "default"
            ]
        ]
        
        for line in lines.dropFirst() {
            let cleanLine = line.trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            
            if cleanLine.hasPrefix("* ") {
                let text = cleanLine.dropFirst(2)
                bodyElements.append([
                    "type": "ColumnSet",
                    "columns": [
                        [
                            "type": "Column",
                            "width": "auto",
                            "items": [
                                [
                                    "type": "TextBlock",
                                    "text": "•",
                                    "size": "Large",
                                    "weight": "Bolder",
                                    "horizontalAlignment": "Center"
                                ]
                            ]
                        ],
                        [
                            "type": "Column",
                            "width": "stretch",
                            "items": [
                                [
                                    "type": "TextBlock",
                                    "text": text,
                                    "wrap": true
                                ]
                            ],
                            "verticalContentAlignment": "Center"
                        ]
                    ]
                ])
            } else if cleanLine.hasPrefix("  - ") {
                let text = cleanLine.dropFirst(4)
                bodyElements.append([
                    "type": "ColumnSet",
                    "columns": [
                        [
                            "type": "Column",
                            "width": "auto",
                            "items": [
                                [
                                    "type": "TextBlock",
                                    "text": "‣",
                                    "size": "Large",
                                    "weight": "Bolder",
                                    "horizontalAlignment": "Right"
                                ]
                            ]
                        ],
                        [
                            "type": "Column",
                            "width": "stretch",
                            "items": [
                                [
                                    "type": "TextBlock",
                                    "text": text,
                                    "wrap": true,
                                    "isSubtle": true
                                ]
                            ],
                            "verticalContentAlignment": "Center"
                        ]
                    ],
                    "spacing": "Small"
                ])
            } else if !cleanLine.isEmpty {
                bodyElements.append([
                    "type": "TextBlock",
                    "text": cleanLine,
                    "wrap": true,
                    "style": "default"
                ])
            }
        }
        
        let adaptiveCard: [String: Any] = [
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": bodyElements
        ]
        
        let cardData = try JSONSerialization.data(withJSONObject: adaptiveCard)
        let cardString = String(data: cardData, encoding: .utf8)!
        
        let messageId = UUID().uuidString
        
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
                    "content": cardString
                ]
            ]
        ]
        
        let data = try JSONSerialization.data(withJSONObject: message)
        request.httpBody = data
        
        print("Request body: \(String(data: data, encoding: .utf8) ?? "")")
        
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
