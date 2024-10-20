import Foundation

struct Prompt: Codable, Identifiable {
    let id: UUID
    var name: String
    var content: String
}
