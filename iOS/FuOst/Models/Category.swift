import Foundation

struct Category: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID?
    let name: String
    let icon: String
    let color: String
    let isCustom: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case icon
        case color
        case isCustom = "is_custom"
        case createdAt = "created_at"
    }
}
