import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject var data: DataManager
    @State private var showAdd = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "wallet.pass.fill")
                            .foregroundColor(Theme.primaryPurple)
                            .font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Траты")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("Контролируй свои расходы 💜")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                    Spacer()
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Theme.primaryPurple))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Monthly summary card
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.cardBackground)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(Theme.primaryPurple)
                                Text("В этом месяце")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.textMuted)
                            }
                            
                            Text("\(Int(data.monthlyExpenses)) \(data.currency)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            // Progress
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.1))
                                    Capsule()
                                        .fill(Theme.orangeGradient)
                                        .frame(width: geo.size.width * data.expensesProgress)
                                }
                            }
                            .frame(height: 6)
                            
                            Text("Лимит: \(Int(data.monthlyBudget)) \(data.currency)")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textMuted)
                        }
                        
                        Spacer()
                        
                        // Fox with coin (custom asset)
                        VStack(spacing: 4) {
                            PetCharacterView(size: 90, style: .foxCoin)
                            Text("\(String(format: "%.1f", data.expensesProgress * 100))%")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.primaryOrange)
                        }
                    }
                    .padding(20)
                }
                .padding(.horizontal, 16)
                
                // Quick stats
                HStack(spacing: 10) {
                    MiniStat(icon: "chart.bar.fill", value: "\(Int(data.monthlyExpenses)) \(data.currency)", label: "Расходов", color: Theme.primaryPurple)
                    MiniStat(icon: "tag.fill", value: "\(monthExpensesCount)", label: "Покупок", color: Theme.primaryOrange)
                    MiniStat(icon: "creditcard.fill", value: "\(avgCheck) \(data.currency)", label: "Средний чек", color: Theme.accentBlue)
                }
                .padding(.horizontal, 16)
                
                // History
                HStack {
                    Text("История")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {} label: {
                        Text("Все операции ›")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.primaryPurple)
                    }
                }
                .padding(.horizontal, 20)
                
                if data.expenses.isEmpty {
                    VStack(spacing: 12) {
                        Text("🛍️")
                            .font(.system(size: 40))
                        Text("Пока нет трат")
                            .foregroundColor(Theme.textMuted)
                        Text("Нажми + чтобы добавить")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(data.expenses.prefix(10)) { expense in
                        ExpenseRow(expense: expense)
                            .padding(.horizontal, 16)
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .sheet(isPresented: $showAdd) {
            AddExpenseView()
        }
    }
    
    private var monthExpensesCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return data.expenses.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }.count
    }
    
    private var avgCheck: Int {
        let count = monthExpensesCount
        guard count > 0 else { return 0 }
        return Int(data.monthlyExpenses) / count
    }
}

struct MiniStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16))
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .cardStyle()
    }
}

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: expense.category.icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(Circle().fill(expense.category.color.opacity(0.8)))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                Text("\(formattedDate) • \(expense.category.rawValue)")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textMuted)
            }
            
            Spacer()
            
            Text("\(Int(expense.amount)) \(DataManager.shared.currency)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Theme.textMuted)
        }
        .padding(14)
        .cardStyle()
    }
    
    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: expense.date)
    }
}

struct AddExpenseView: View {
    @EnvironmentObject var data: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var amount = ""
    @State private var category: Expense.ExpenseCategory = .shopping
    @State private var note = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Основное") {
                    TextField("Название", text: $title)
                    TextField("Сумма", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section("Категория") {
                    Picker("Категория", selection: $category) {
                        ForEach(Expense.ExpenseCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section("Заметка") {
                    TextField("Опционально", text: $note)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Новая трата")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        guard let amt = Double(amount.replacingOccurrences(of: ",", with: ".")),
                              !title.isEmpty else { return }
                        let expense = Expense(title: title, amount: amt, category: category, date: Date(), note: note)
                        data.addExpense(expense)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ExpensesView()
        .environmentObject(DataManager.shared)
}
