import Foundation
import SwiftUI
import WidgetKit

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var pet: Pet = Pet()
    @Published var shiftTemplates: [ShiftTemplate] = []
    @Published var workSessions: [WorkSession] = []
    @Published var activeSession: WorkSession?
    @Published var earningsRules: [EarningsRule] = []
    @Published var expenses: [Expense] = []
    @Published var selectedCity: String = "Прага"
    @Published var monthlyBudget: Double = 10000
    @Published var currency: String = "UAH"
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        loadAll()
        if shiftTemplates.isEmpty {
            setupDefaults()
        }
    }
    
    // MARK: - Persistence
    private func loadAll() {
        if let data = defaults.data(forKey: "pet"),
           let p = try? decoder.decode(Pet.self, from: data) {
            pet = p
        }
        if let data = defaults.data(forKey: "shiftTemplates"),
           let t = try? decoder.decode([ShiftTemplate].self, from: data) {
            shiftTemplates = t
        }
        if let data = defaults.data(forKey: "workSessions"),
           let s = try? decoder.decode([WorkSession].self, from: data) {
            workSessions = s
        }
        if let data = defaults.data(forKey: "earningsRules"),
           let e = try? decoder.decode([EarningsRule].self, from: data) {
            earningsRules = e
        }
        if let data = defaults.data(forKey: "expenses"),
           let e = try? decoder.decode([Expense].self, from: data) {
            expenses = e
        }
        selectedCity = defaults.string(forKey: "selectedCity") ?? "Прага"
        monthlyBudget = defaults.double(forKey: "monthlyBudget")
        if monthlyBudget == 0 { monthlyBudget = 10000 }
        currency = defaults.string(forKey: "currency") ?? "UAH"
        
        // Restore active session
        if let data = defaults.data(forKey: "activeSession"),
           let s = try? decoder.decode(WorkSession.self, from: data),
           s.isActive {
            activeSession = s
        }
    }
    
    func saveAll() {
        if let data = try? encoder.encode(pet) { defaults.set(data, forKey: "pet") }
        if let data = try? encoder.encode(shiftTemplates) { defaults.set(data, forKey: "shiftTemplates") }
        if let data = try? encoder.encode(workSessions) { defaults.set(data, forKey: "workSessions") }
        if let data = try? encoder.encode(earningsRules) { defaults.set(data, forKey: "earningsRules") }
        if let data = try? encoder.encode(expenses) { defaults.set(data, forKey: "expenses") }
        defaults.set(selectedCity, forKey: "selectedCity")
        defaults.set(monthlyBudget, forKey: "monthlyBudget")
        defaults.set(currency, forKey: "currency")
        if let s = activeSession, let data = try? encoder.encode(s) {
            defaults.set(data, forKey: "activeSession")
        } else {
            defaults.removeObject(forKey: "activeSession")
        }
        
        // Update widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func setupDefaults() {
        earningsRules = [
            EarningsRule(name: "Ставка", type: .hourly, amount: 180, isBonus: false),
            EarningsRule(name: "Бонус серии", type: .custom, amount: 0, isBonus: true, description: "+20% за серию")
        ]
        saveAll()
    }
    
    // MARK: - Pet Actions
    func feedPet(with food: FoodItem) {
        pet.feed(with: food)
        saveAll()
    }
    
    func playWithPet() {
        pet.play()
        saveAll()
    }
    
    // MARK: - Shifts
    func startManualShift(name: String = "Смена") {
        let session = WorkSession(name: name, startTime: Date(), isActive: true)
        activeSession = session
        saveAll()
    }
    
    func startBreak(type: BreakPeriod.BreakType) {
        guard var session = activeSession else { return }
        let br = BreakPeriod(start: Date(), type: type)
        session.breaks.append(br)
        activeSession = session
        saveAll()
    }
    
    func endBreak() {
        guard var session = activeSession,
              let idx = session.breaks.lastIndex(where: { $0.end == nil }) else { return }
        session.breaks[idx].end = Date()
        activeSession = session
        saveAll()
    }
    
    func endShift() {
        guard var session = activeSession else { return }
        session.endTime = Date()
        session.isActive = false
        // close any open break
        if let idx = session.breaks.lastIndex(where: { $0.end == nil }) {
            session.breaks[idx].end = Date()
        }
        workSessions.insert(session, at: 0)
        activeSession = nil
        // update streak
        pet.streakDays += 1
        saveAll()
    }
    
    func addWorkSession(_ session: WorkSession) {
        workSessions.insert(session, at: 0)
        saveAll()
    }
    
    // MARK: - Expenses
    func addExpense(_ expense: Expense) {
        expenses.insert(expense, at: 0)
        saveAll()
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveAll()
    }
    
    // MARK: - Computed
    var todayWorkedMinutes: Int {
        let calendar = Calendar.current
        let todaySessions = workSessions.filter { calendar.isDateInToday($0.startTime) }
        let fromFinished = todaySessions.reduce(0) { $0 + $1.totalWorkedMinutes }
        let fromActive = activeSession?.totalWorkedMinutes ?? 0
        return fromFinished + fromActive
    }
    
    var monthlyEarnings: Double {
        let calendar = Calendar.current
        let now = Date()
        let monthSessions = workSessions.filter {
            calendar.isDate($0.startTime, equalTo: now, toGranularity: .month)
        }
        let hours = Double(monthSessions.reduce(0) { $0 + $1.totalWorkedMinutes }) / 60.0
        let hourly = earningsRules.first(where: { $0.type == .hourly })?.amount ?? 180
        var total = hours * hourly
        // simple bonus
        if pet.streakDays >= 7 {
            total *= 1.2
        }
        return total
    }
    
    var monthlyExpenses: Double {
        let calendar = Calendar.current
        let now = Date()
        return expenses
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }
    
    var expensesProgress: Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(1.0, monthlyExpenses / monthlyBudget)
    }
}
