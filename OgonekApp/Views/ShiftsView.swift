import SwiftUI

struct ShiftsView: View {
    @EnvironmentObject var data: DataManager
    @State private var currentMonth = Date()
    @State private var showStartConfirm = false
    @State private var showEndConfirm = false
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Theme.primaryOrange)
                            .font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Смены")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("Твой график работы")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                    Spacer()
                    Button {} label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Theme.primaryPurple.opacity(0.4)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Month selector
                HStack {
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Theme.cardBackgroundSolid))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .foregroundColor(Theme.primaryPurple)
                        Text(monthYearString)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Theme.cardBackgroundSolid))
                    }
                }
                .padding(.horizontal, 20)
                
                // Stats cards + decorative flame (like screenshot)
                HStack(alignment: .bottom, spacing: 8) {
                    StatCard(
                        icon: "clock.fill",
                        value: formatMinutes(data.todayWorkedMinutes),
                        label: "Часов сегодня",
                        color: Theme.primaryPurple
                    )
                    StatCard(
                        icon: "bitcoinsign.circle.fill",
                        value: "\(Int(data.monthlyEarnings)) \(data.currency)",
                        label: "Заработок за месяц",
                        color: Theme.primaryOrange
                    )
                    
                    PetCharacterView(size: 88, style: .flameHappy)
                        .offset(y: 6)
                }
                .padding(.horizontal, 12)
                
                // Start / Active shift button
                if let session = data.activeSession {
                    ActiveShiftCard(session: session)
                } else {
                    Button {
                        data.startManualShift()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Начать смену")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.orangeGradient)
                        .cornerRadius(16)
                        .shadow(color: Theme.primaryOrange.opacity(0.4), radius: 12, y: 4)
                    }
                    .buttonStyle(GlowButtonStyle())
                    .padding(.horizontal, 16)
                }
                
                // Calendar
                VStack(spacing: 8) {
                    // Weekday headers
                    HStack {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textMuted)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Days grid
                    let days = daysInMonth()
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                            if let date = date {
                                DayCell(
                                    date: date,
                                    isToday: calendar.isDateInToday(date),
                                    hasShift: hasShift(on: date)
                                )
                            } else {
                                Color.clear.frame(height: 36)
                            }
                        }
                    }
                }
                .padding(16)
                .cardStyle()
                .padding(.horizontal, 16)
                
                // Streak card
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Серия дней")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textMuted)
                            Text("\(data.pet.streakDays) дней подряд")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Theme.primaryOrange)
                        Text("Бонус серии +20%")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.accentGreen)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textMuted)
                    }
                }
                .padding(16)
                .cardStyle()
                .padding(.horizontal, 16)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private var monthYearString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: currentMonth).capitalized
    }
    
    private func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        var firstWeekday = calendar.component(.weekday, from: firstDay) - 2 // Monday = 0
        if firstWeekday < 0 { firstWeekday += 7 }
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
    
    private func hasShift(on date: Date) -> Bool {
        data.workSessions.contains { calendar.isDate($0.startTime, inSameDayAs: date) }
    }
    
    private func formatMinutes(_ m: Int) -> String {
        String(format: "%d:%02d", m / 60, m % 60)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cardStyle()
    }
}

struct DayCell: View {
    let date: Date
    let isToday: Bool
    let hasShift: Bool
    
    private var dayNumber: String {
        "\(Calendar.current.component(.day, from: date))"
    }
    
    var body: some View {
        ZStack {
            if isToday {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.orangeGradient)
                    .frame(width: 36, height: 36)
                    .shadow(color: Theme.primaryOrange.opacity(0.5), radius: 6)
            }
            
            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.system(size: 14, weight: isToday ? .bold : .medium))
                    .foregroundColor(isToday ? .white : .white.opacity(0.85))
                
                if hasShift && !isToday {
                    Circle()
                        .fill(Theme.primaryOrange)
                        .frame(width: 4, height: 4)
                }
            }
        }
        .frame(height: 36)
    }
}

struct ActiveShiftCard: View {
    @EnvironmentObject var data: DataManager
    let session: WorkSession
    @State private var tick = Date()
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                    .shadow(color: .green, radius: 4)
                Text("Смена активна")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.green)
                Spacer()
                Text(liveDuration)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 10) {
                if session.breaks.last?.end == nil {
                    Button {
                        data.endBreak()
                    } label: {
                        Label("Продолжить", systemImage: "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.accentGreen)
                            .cornerRadius(12)
                    }
                } else {
                    Button {
                        data.startBreak(type: .short)
                    } label: {
                        Label("Перерыв", systemImage: "pause.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.primaryPurple)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        data.startBreak(type: .lunch)
                    } label: {
                        Label("Обед", systemImage: "fork.knife")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.primaryPurple)
                            .cornerRadius(12)
                    }
                }
                
                Button {
                    data.endShift()
                } label: {
                    Label("Закончить", systemImage: "stop.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.85))
                        .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .cardStyle()
        .padding(.horizontal, 16)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            tick = Date()
        }
    }
    
    private var liveDuration: String {
        let _ = tick
        return session.formattedDuration
    }
}

#Preview {
    ShiftsView()
        .environmentObject(DataManager.shared)
}
