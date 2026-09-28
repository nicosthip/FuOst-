import SwiftUI

struct ContentView: View {
    @EnvironmentObject var supabase: SupabaseService
    @State private var expenses: [Expense] = []
    @State private var isLoading = false
    
    // Para el chat de ingreso rápido
    @State private var chatText: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo moderno
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Resumen Principal
                    summaryCard
                    
                    // Lista de Gastos
                    List {
                        Section(header: Text("Movimientos Recientes")) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else if expenses.isEmpty {
                                Text("No hay gastos registrados aún.")
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(expenses) { expense in
                                    ExpenseRow(expense: expense)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    // Chatbot / Ingreso rápido
                    quickEntryBar
                }
            }
            .navigationTitle("FuOst")
            .onAppear {
                Task {
                    await loadData()
                }
            }
        }
    }
    
    // MARK: - Componentes Visuales
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Gastado este mes")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("$\(totalExpenses(), specifier: "%.2f")")
                .font(.system(size: 40, weight: .bold, design: .rounded))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial) // Efecto translúcido moderno de iOS
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    private var quickEntryBar: some View {
        HStack {
            TextField("Ej: Gasté 150 en Uber...", text: $chatText)
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(20)
            
            Button(action: {
                // Aquí llamaremos a la Edge Function de IA
                submitChat()
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .disabled(chatText.isEmpty)
        }
        .padding()
        .background(.bar) // Efecto blur en la parte inferior
    }
    
    // MARK: - Lógica
    
    private func loadData() async {
        isLoading = true
        do {
            // Simularemos un error amigable si el usuario no está logueado
            expenses = try await supabase.fetchExpenses()
        } catch {
            print("Error cargando gastos: \(error)")
        }
        isLoading = false
    }
    
    private func totalExpenses() -> Double {
        // En una app real, sumaríamos los montos de tipo Decimal
        return expenses.reduce(0) { $0 + NSDecimalNumber(decimal: $1.amount).doubleValue }
    }
    
    private func submitChat() {
        print("Enviando a procesar por IA: \(chatText)")
        chatText = ""
        // TODO: Llamar a Supabase Edge Function
    }
}

// MARK: - Fila de Gasto
struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            // Icono según categoría (Placeholder por ahora)
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: "cart.fill") // Idealmente viene de expense.categoryId
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.note ?? "Gasto")
                    .font(.headline)
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(NSDecimalNumber(decimal: expense.amount).doubleValue, specifier: "%.2f")")
                .font(.system(.body, design: .rounded).bold())
        }
        .padding(.vertical, 4)
    }
}
