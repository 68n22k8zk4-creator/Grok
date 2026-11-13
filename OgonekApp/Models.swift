import Foundation
import SwiftUI

// MARK: - Weather
struct WeatherData: Codable {
    var temperature: Double
    var feelsLike: Double
    var humidity: Int
    var windSpeed: Double
    var pressure: Int
    var weatherCode: Int
    var sunrise: String
    var sunset: String
    var city: String
    var country: String
    var daily: [DailyForecast]
    
    var clothingAdvice: String {
        if temperature < 5 { return "Одевайся тепло" }
        if temperature < 15 { return "Одевайся средне" }
        return "Одевайся легко"
    }
    
    var clothingIcon: String {
        if temperature < 5 { return "jacket.fill" }
        if temperature < 15 { return "tshirt.fill" }
        return "sun.max.fill"
    }
    
    var needUmbrella: Bool {
        [51, 53, 55, 61, 63, 65, 80, 81, 82, 95, 96, 99].contains(weatherCode)
    }
    
    var weatherIcon: String {
        switch weatherCode {
        case 0: return "sun.max.fill"
        case 1, 2: return "cloud.sun.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55: return "cloud.drizzle.fill"
        case 61, 63, 65, 80, 81, 82: return "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86: return "cloud.snow.fill"
        case 95, 96, 99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }
}

struct DailyForecast: Codable, Identifiable {
    var id: String { day }
    var day: String
    var weatherCode: Int
    var tempMin: Double
    var tempMax: Double
    
    var icon: String {
        switch weatherCode {
        case 0: return "sun.max.fill"
        case 1, 2: return "cloud.sun.fill"
        case 3: return "cloud.fill"
        case 51, 53, 55, 61, 63, 65: return "cloud.rain.fill"
        case 71, 73, 75: return "cloud.snow.fill"
        default: return "cloud.fill"
        }
    }
}

// MARK: - Pet
struct Pet: Codable {
    var name: String = "Огонёк"
    var level: Int = 1
    var experience: Int = 0
    var hunger: Double = 80
    var happiness: Double = 80
    var health: Double = 100
    var streakDays: Int = 0
    var lastFedDate: Date?
    var lastPlayedDate: Date?
    var totalFeedCount: Int = 0
    var totalPlayCount: Int = 0
    var feedHistory: [FeedRecord] = []
    var form: PetForm = .flame
    
    enum PetForm: String, Codable, CaseIterable {
        case flame = "flame"
        case fox = "fox"
        
        var displayName: String {
            switch self {
            case .flame: return "Огонёк"
            case .fox: return "Лисичка"
            }
        }
    }
    
    var needsCare: Bool {
        let calendar = Calendar.current
        if let last = lastFedDate, calendar.isDateInToday(last) { return false }
        if let last = lastPlayedDate, calendar.isDateInToday(last) { return false }
        return true
    }
    
    mutating func feed(with food: FoodItem) {
        hunger = min(100, hunger + food.nutritionValue)
        happiness = min(100, happiness + food.happinessBonus)
        if food.isHealthy {
            health = min(100, health + 5)
        } else {
            health = max(0, health - 3)
        }
        experience += food.xp
        totalFeedCount += 1
        lastFedDate = Date()
        feedHistory.insert(FeedRecord(food: food, date: Date()), at: 0)
        if feedHistory.count > 50 { feedHistory = Array(feedHistory.prefix(50)) }
        checkLevelUp()
        updateStreak()
    }
    
    mutating func play() {
        happiness = min(100, happiness + 15)
        hunger = max(0, hunger - 5)
        experience += 20
        totalPlayCount += 1
        lastPlayedDate = Date()
        checkLevelUp()
        updateStreak()
    }
    
    private mutating func checkLevelUp() {
        let needed = level * 100
        if experience >= needed {
            experience -= needed
            level += 1
        }
    }
    
    private mutating func updateStreak() {
        let calendar = Calendar.current
        if let last = lastFedDate ?? lastPlayedDate {
            if calendar.isDateInYesterday(last) || calendar.isDateInToday(last) {
                // keep or increment handled externally
            }
        }
    }
}

struct FoodItem: Codable, Identifiable, Hashable {
    var id: String { name }
    var name: String
    var emoji: String
    var nutritionValue: Double
    var happinessBonus: Double
    var isHealthy: Bool
    var xp: Int
    var category: FoodCategory
    
    enum FoodCategory: String, Codable, CaseIterable {
        case healthy = "healthy"
        case normal = "normal"
        case junk = "junk"
        
        var displayName: String {
            switch self {
            case .healthy: return "Полезная"
            case .normal: return "Обычная"
            case .junk: return "Фастфуд"
            }
        }
    }
}

struct FeedRecord: Codable, Identifiable {
    var id = UUID()
    var food: FoodItem
    var date: Date
}

// MARK: - Shifts
struct ShiftTemplate: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var type: ShiftType
    var startTime: Date?
    var endTime: Date?
    var breakDuration: Int = 0 // minutes
    var lunchDuration: Int = 0
    var color: String = "FF8C00"
    
    enum ShiftType: String, Codable, CaseIterable {
        case auto = "auto"
        case manual = "manual"
        
        var displayName: String {
            switch self {
            case .auto: return "Авто"
            case .manual: return "Ручная"
            }
        }
    }
}

struct WorkSession: Codable, Identifiable {
    var id = UUID()
    var templateId: UUID?
    var name: String
    var startTime: Date
    var endTime: Date?
    var breaks: [BreakPeriod] = []
    var isActive: Bool = false
    var notes: String = ""
    
    var totalWorkedMinutes: Int {
        guard let end = endTime else {
            let now = Date()
            let total = Int(now.timeIntervalSince(startTime) / 60)
            let breakMin = breaks.reduce(0) { $0 + $1.durationMinutes }
            return max(0, total - breakMin)
        }
        let total = Int(end.timeIntervalSince(startTime) / 60)
        let breakMin = breaks.reduce(0) { $0 + $1.durationMinutes }
        return max(0, total - breakMin)
    }
    
    var formattedDuration: String {
        let h = totalWorkedMinutes / 60
        let m = totalWorkedMinutes % 60
        return String(format: "%d:%02d", h, m)
    }
}

struct BreakPeriod: Codable, Identifiable {
    var id = UUID()
    var start: Date
    var end: Date?
    var type: BreakType
    
    enum BreakType: String, Codable {
        case short = "перерыв"
        case lunch = "обед"
    }
    
    var durationMinutes: Int {
        guard let end = end else { return 0 }
        return Int(end.timeIntervalSince(start) / 60)
    }
}

struct EarningsRule: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: EarningsType
    var amount: Double
    var isBonus: Bool = false
    var description: String = ""
    
    enum EarningsType: String, Codable, CaseIterable {
        case hourly = "в час"
        case perShift = "за смену"
        case perDay = "за день"
        case fixed = "фикс"
        case custom = "другое"
        
        var displayName: String { rawValue }
    }
}

// MARK: - Expenses
struct Expense: Codable, Identifiable {
    var id = UUID()
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var note: String = ""
    
    enum ExpenseCategory: String, Codable, CaseIterable {
        case food = "Еда"
        case transport = "Транспорт"
        case shopping = "Покупки"
        case entertainment = "Развлечения"
        case bills = "Счета"
        case health = "Здоровье"
        case other = "Другое"
        
        var icon: String {
            switch self {
            case .food: return "fork.knife"
            case .transport: return "car.fill"
            case .shopping: return "cart.fill"
            case .entertainment: return "gamecontroller.fill"
            case .bills: return "doc.text.fill"
            case .health: return "heart.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .food: return .orange
            case .transport: return .blue
            case .shopping: return .purple
            case .entertainment: return .pink
            case .bills: return .red
            case .health: return .green
            case .other: return .gray
            }
        }
    }
}

// MARK: - Food Database
struct FoodDatabase {
    static let all: [FoodItem] = [
        FoodItem(name: "Рыба", emoji: "🐟", nutritionValue: 25, happinessBonus: 15, isHealthy: true, xp: 15, category: .healthy),
        FoodItem(name: "Брокколи", emoji: "🥦", nutritionValue: 20, happinessBonus: 5, isHealthy: true, xp: 12, category: .healthy),
        FoodItem(name: "Морковь", emoji: "🥕", nutritionValue: 15, happinessBonus: 8, isHealthy: true, xp: 10, category: .healthy),
        FoodItem(name: "Яблоко", emoji: "🍎", nutritionValue: 18, happinessBonus: 10, isHealthy: true, xp: 10, category: .healthy),
        FoodItem(name: "Мясо", emoji: "🥩", nutritionValue: 30, happinessBonus: 12, isHealthy: true, xp: 18, category: .healthy),
        FoodItem(name: "Каша", emoji: "🥣", nutritionValue: 22, happinessBonus: 8, isHealthy: true, xp: 12, category: .healthy),
        FoodItem(name: "Хлеб", emoji: "🍞", nutritionValue: 15, happinessBonus: 5, isHealthy: false, xp: 8, category: .normal),
        FoodItem(name: "Сыр", emoji: "🧀", nutritionValue: 18, happinessBonus: 10, isHealthy: false, xp: 10, category: .normal),
        FoodItem(name: "Молоко", emoji: "🥛", nutritionValue: 12, happinessBonus: 8, isHealthy: true, xp: 8, category: .healthy),
        FoodItem(name: "Бургер", emoji: "🍔", nutritionValue: 35, happinessBonus: 20, isHealthy: false, xp: 5, category: .junk),
        FoodItem(name: "Пицца", emoji: "🍕", nutritionValue: 30, happinessBonus: 18, isHealthy: false, xp: 5, category: .junk),
        FoodItem(name: "Шоколад", emoji: "🍫", nutritionValue: 10, happinessBonus: 25, isHealthy: false, xp: 3, category: .junk),
        FoodItem(name: "Чипсы", emoji: "🥔", nutritionValue: 8, happinessBonus: 15, isHealthy: false, xp: 2, category: .junk),
        FoodItem(name: "Мороженое", emoji: "🍦", nutritionValue: 12, happinessBonus: 22, isHealthy: false, xp: 4, category: .junk),
    ]
    
    static func recommended(for pet: Pet) -> FoodItem {
        // Prefer healthy if health low or recent junk
        let recentJunk = pet.feedHistory.prefix(3).filter { !$0.food.isHealthy }.count
        if pet.health < 70 || recentJunk >= 2 {
            return all.filter { $0.isHealthy }.randomElement() ?? all[0]
        }
        return all.randomElement() ?? all[0]
    }
}
