import SwiftUI

struct PetDetailView: View {
    @EnvironmentObject var data: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Big character
                    Text(data.pet.form == .fox ? "🦊" : "🔥")
                        .font(.system(size: 80))
                        .padding(.top)
                    
                    Text(data.pet.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        DetailStat(title: "Уровень", value: "\(data.pet.level)", icon: "star.fill")
                        DetailStat(title: "Опыт", value: "\(data.pet.experience)", icon: "bolt.fill")
                        DetailStat(title: "Кормлений", value: "\(data.pet.totalFeedCount)", icon: "fork.knife")
                        DetailStat(title: "Игр", value: "\(data.pet.totalPlayCount)", icon: "gamecontroller.fill")
                        DetailStat(title: "Серия", value: "\(data.pet.streakDays) дн.", icon: "flame.fill")
                        DetailStat(title: "Здоровье", value: "\(Int(data.pet.health))%", icon: "heart.fill")
                    }
                    .padding(.horizontal)
                    
                    // Nutrition table
                    VStack(alignment: .leading, spacing: 12) {
                        Text("История питания")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if data.pet.feedHistory.isEmpty {
                            Text("Пока пусто")
                                .foregroundColor(Theme.textMuted)
                        } else {
                            ForEach(data.pet.feedHistory.prefix(15)) { record in
                                HStack {
                                    Text(record.food.emoji)
                                    Text(record.food.name)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(record.food.isHealthy ? "Полезно" : "Фастфуд")
                                        .font(.system(size: 12))
                                        .foregroundColor(record.food.isHealthy ? Theme.accentGreen : Theme.primaryOrange)
                                    Text(timeAgo(record.date))
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.textMuted)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                    .cardStyle()
                    .padding(.horizontal)
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Советы по питанию")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Text("• Не корми фастфудом чаще 1–2 раз в день")
                        Text("• Рыба, овощи и фрукты повышают здоровье")
                        Text("• Играй каждый день, чтобы поддерживать счастье")
                        Text("• Серия дней даёт бонус к заработку")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
                    .padding()
                    .cardStyle()
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .background(Theme.background)
            .navigationTitle("О питомце")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func timeAgo(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: Date())
    }
}

struct DetailStat: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryOrange)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .cardStyle()
    }
}

#Preview {
    PetDetailView()
        .environmentObject(DataManager.shared)
}
