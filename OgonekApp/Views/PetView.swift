import SwiftUI

struct PetView: View {
    @EnvironmentObject var data: DataManager
    @State private var showFeedSheet = false
    @State private var showGames = false
    @State private var showDetail = false
    
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
                            Text("Огонёк")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("Твой верный питомец ❤️")
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
                
                // Pet display
                ZStack {
                    // Glow platform
                    Ellipse()
                        .fill(
                            RadialGradient(colors: [Theme.primaryOrange.opacity(0.35), .clear], center: .center, startRadius: 20, endRadius: 120)
                        )
                        .frame(width: 240, height: 80)
                        .offset(y: 70)
                    
                    VStack(spacing: 12) {
                        // Character with floating hearts
                        ZStack {
                            ForEach(0..<5, id: \.self) { i in
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.accentPink.opacity(0.55))
                                    .offset(
                                        x: CGFloat([-55, -32, 42, 58, -12][i]),
                                        y: CGFloat([-48, 18, -35, 8, -65][i])
                                    )
                            }
                            
                            PetCharacterView(size: 160, style: .fox)
                        }
                        .frame(height: 170)
                        
                        // Level badge
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(Theme.primaryOrange)
                                    Text("\(data.pet.level)")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                Text("пламя")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.textMuted)
                                if data.pet.needsCare {
                                    Text("Покорми или поиграй сегодня")
                                        .font(.system(size: 11))
                                        .foregroundColor(Theme.primaryOrange)
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Theme.cardBackgroundSolid)
                            )
                            .padding(.trailing, 20)
                        }
                    }
                }
                .padding(.vertical, 10)
                
                // Action buttons
                HStack(spacing: 12) {
                    Button {
                        showFeedSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "fork.knife")
                            Text("Покормить")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.orangeGradient)
                        .cornerRadius(14)
                        .shadow(color: Theme.primaryOrange.opacity(0.35), radius: 8, y: 3)
                    }
                    .buttonStyle(GlowButtonStyle())
                    
                    Button {
                        showGames = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "gamecontroller.fill")
                            Text("Играть")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.purpleGradient)
                        .cornerRadius(14)
                    }
                    .buttonStyle(GlowButtonStyle())
                }
                .padding(.horizontal, 16)
                
                // Best food now
                let recommended = FoodDatabase.recommended(for: data.pet)
                HStack {
                    Text(recommended.emoji)
                        .font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Лучшее сейчас")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textMuted)
                        Text(recommended.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        data.feedPet(with: recommended)
                    } label: {
                        Text("Дать ›")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Theme.primaryPurple))
                    }
                }
                .padding(16)
                .cardStyle()
                .padding(.horizontal, 16)
                
                // Yesterday history
                HStack {
                    Text("Вчера")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textMuted)
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(yesterdayFoods, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 20))
                        }
                        if yesterdayFoods.isEmpty {
                            Text("—")
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                }
                .padding(16)
                .cardStyle()
                .padding(.horizontal, 16)
                
                // Stats bars
                VStack(spacing: 12) {
                    StatBar(title: "Сытость", value: data.pet.hunger, color: .orange)
                    StatBar(title: "Счастье", value: data.pet.happiness, color: .pink)
                    StatBar(title: "Здоровье", value: data.pet.health, color: .green)
                }
                .padding(16)
                .cardStyle()
                .padding(.horizontal, 16)
                
                // All about pet
                Button {
                    showDetail = true
                } label: {
                    HStack {
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(Theme.primaryOrange)
                        Text("Всё о питомце")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Theme.textMuted)
                    }
                    .padding(16)
                    .background(
                        Capsule()
                            .fill(Theme.cardBackgroundSolid)
                            .overlay(Capsule().stroke(Theme.primaryOrange.opacity(0.3), lineWidth: 1))
                    )
                }
                .padding(.horizontal, 16)
                
                Spacer(minLength: 100)
            }
        }
        .sheet(isPresented: $showFeedSheet) {
            FeedSheet()
        }
        .sheet(isPresented: $showGames) {
            GamesView()
        }
        .sheet(isPresented: $showDetail) {
            PetDetailView()
        }
    }
    
    private var yesterdayFoods: [String] {
        let calendar = Calendar.current
        return data.pet.feedHistory
            .filter { calendar.isDateInYesterday($0.date) }
            .prefix(4)
            .map { $0.food.emoji }
    }
}

struct StatBar: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textMuted)
                Spacer()
                Text("\(Int(value))%")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * (value / 100))
                }
            }
            .frame(height: 8)
        }
    }
}

struct FeedSheet: View {
    @EnvironmentObject var data: DataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(FoodDatabase.all) { food in
                        Button {
                            data.feedPet(with: food)
                            dismiss()
                        } label: {
                            VStack(spacing: 8) {
                                Text(food.emoji)
                                    .font(.system(size: 36))
                                Text(food.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                Text(food.category.displayName)
                                    .font(.system(size: 11))
                                    .foregroundColor(food.isHealthy ? Theme.accentGreen : Theme.primaryOrange)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.cardBackgroundSolid)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Чем покормить?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    PetView()
        .environmentObject(DataManager.shared)
}
