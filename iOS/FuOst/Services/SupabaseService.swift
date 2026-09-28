import Foundation
import Supabase // Necesitarás añadir el paquete supabase-swift a tu proyecto Xcode

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    // Configura esto con la URL y la Anon Key de tu proyecto Supabase
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://ynmcbedphfqmtnytioxb.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlubWNiZWRwaGZxbXRueXRpb3hiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA2MDEzNDEsImV4cCI6MjEwNjE3NzM0MX0.PXokPXMPQZxWKbi0jbaux1aXz9yj7Ihu0qEhbcD4XPk"
    )
    
    @Published var currentUser: User?
    
    private init() {}
    
    // MARK: - Autenticación (Ejemplo básico con Email/Password)
    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        DispatchQueue.main.async {
            self.currentUser = session.user
        }
    }
    
    // MARK: - Gastos (Expenses)
    func addExpense(amount: Decimal, categoryId: UUID?, note: String?, origin: ExpenseOrigin = .manual) async throws {
        guard let userId = client.auth.currentUser?.id else { return }
        
        let newExpense = Expense(
            id: UUID(),
            userId: userId,
            amount: amount,
            date: Date(),
            categoryId: categoryId,
            note: note,
            origin: origin,
            createdAt: Date()
        )
        
        try await client
            .from("expenses")
            .insert(newExpense)
            .execute()
    }
    
    func fetchExpenses() async throws -> [Expense] {
        return try await client
            .from("expenses")
            .select()
            .order("date", ascending: false)
            .execute()
            .value
    }
    
    // MARK: - Categorías (Categories)
    func fetchCategories() async throws -> [Category] {
        return try await client
            .from("categories")
            .select()
            .order("name", ascending: true)
            .execute()
            .value
    }
}
