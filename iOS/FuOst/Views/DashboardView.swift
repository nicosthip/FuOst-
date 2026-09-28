import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var supabase: SupabaseService
    @State private var expenses: [Expense] = []
    @State private var chatText: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo más vibrante y degradado juguetón
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Mascota / Avatar estilo Mon AI
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("¡Hola de nuevo!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Tu balance mensual")
                                        .font(.title2)
                                        .bold()
                                }
                                Spacer()
                                Image(systemName: "face.smiling.inverse")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.purple)
                                    .background(Circle().fill(Color.purple.opacity(0.2)))
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Tarjeta Principal de Balance (Muy colorida)
                            ZStack {
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(
                                        LinearGradient(gradient: Gradient(colors: [.purple, .indigo]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .shadow(color: .purple.opacity(0.4), radius: 15, x: 0, y: 10)
                                
                                VStack(spacing: 5) {
                                    Text("Has gastado")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("$\(totalExpenses(), specifier: "%.2f")")
                                        .font(.system(size: 45, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 30)
                            }
                            .padding(.horizontal)
                            
                            // Lista de Gastos
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Últimos movimientos")
                                    .font(.title3)
                                    .bold()
                                    .padding(.horizontal)
                                
                                if expenses.isEmpty {
                                    Text("Aún no tienes gastos. ¡Escríbeme uno abajo!")
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                } else {
                                    ForEach(expenses) { expense in
                                        ExpenseCard(expense: expense)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 90) // Espacio para la barra
                    }
                    
                    // Barra Inferior de Chat Estilo Mon AI
                    quickEntryBar
                }
            }
        }
    }
    
    private var quickEntryBar: some View {
        HStack {
            TextField("P. ej: 20 dólares en café", text: $chatText)
                .padding(15)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            
            Button(action: {
                chatText = ""
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(15)
                    .background(Color.purple)
                    .clipShape(Circle())
                    .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
            }
        }
        .padding()
        .background(Color.clear)
    }
    
    private func totalExpenses() -> Double {
        return expenses.reduce(0) { $0 + NSDecimalNumber(decimal: $1.amount).doubleValue }
    }
}

// Tarjeta Individual de Gasto
struct ExpenseCard: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: "cart.fill") // Icono temporal
                    .foregroundColor(.orange)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.note ?? "Gasto")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("- $\(NSDecimalNumber(decimal: expense.amount).doubleValue, specifier: "%.2f")")
                .font(.system(.body, design: .rounded).bold())
                .foregroundColor(.red)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
        .padding(.horizontal)
    }
}
