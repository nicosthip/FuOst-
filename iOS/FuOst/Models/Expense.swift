import Foundation

enum ExpenseOrigin: String, Codable {
    case wallet
    case manual
    case message
}

struct Expense: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let amount: Decimal
    let date: Date
    let categoryId: UUID?
    let note: String?
    let origin: ExpenseOrigin
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case amount
        case date
        case categoryId = "category_id"
        case note
        case origin
        case createdAt = "created_at"
    }
}
