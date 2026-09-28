// Tarjeta Individual de Gasto
struct ExpenseCard: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: "cart.fill")
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}
