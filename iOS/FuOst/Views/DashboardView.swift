import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var supabase: SupabaseService
    @State private var expenses: [Expense] = []
    @State private var chatText: String = ""
    @State private var showAddCategory = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo con profundidad y compatibilidad Light/Dark
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Efecto de esferas desenfocadas (Profundidad)
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .blur(radius: 60)
                    .frame(width: 250, height: 250)
                    .offset(x: -100, y: -250)
                
                Circle()
                    .fill(Color.indigo.opacity(0.3))
                    .blur(radius: 60)
                    .frame(width: 250, height: 250)
                    .offset(x: 100, y: -100)
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            headerView
                            balanceCard
                            rankingView
                            expensesList
                        }
                        .padding(.bottom, 100)
                    }
                    
                    quickEntryBar
                }
            }
        }
    }
    
    // MARK: - Subvistas
    private var headerView: some View {
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
                .frame(width: 45, height: 45)
                .foregroundColor(.purple)
                .background(.ultraThinMaterial, in: Circle()) // Difuminado
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    private var balanceCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [.purple, .indigo]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
            
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
    }
    
    private var rankingView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Ranking por Categoría")
                    .font(.headline)
                Spacer()
                Button("Añadir +") { showAddCategory = true }
                    .font(.caption).bold()
                    .foregroundColor(.purple)
            }
            
            // Gráfico de Barras usando Swift Charts
            Chart {
                BarMark(
                    x: .value("Monto", 120),
                    y: .value("Categoría", "Comida")
                )
                .foregroundStyle(Color.orange)
                
                BarMark(
                    x: .value("Monto", 85),
                    y: .value("Categoría", "Transporte")
                )
                .foregroundStyle(Color.blue)
            }
            .frame(height: 120)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
        .padding(.horizontal)
    }
    
    private var expensesList: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Historial")
                .font(.title3)
                .bold()
                .padding(.horizontal)
            
            // Gasto de Ejemplo (Deslizable para borrar)
            ExpenseCard(expense: Expense(id: UUID(), userId: UUID(), amount: Decimal(15), date: Date(), categoryId: nil, note: "Hamburguesa", origin: .manual, createdAt: Date()))
        }
    }
    
    private var quickEntryBar: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.purple)
            
            TextField("Gasto inteligente...", text: $chatText)
                .padding(10)
            
            Button(action: { chatText = "" }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(LinearGradient(gradient: Gradient(colors: [.purple, .indigo]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private func totalExpenses() -> Double { return 345.50 }
}
