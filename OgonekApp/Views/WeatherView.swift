import SwiftUI

struct WeatherView: View {
    @EnvironmentObject var data: DataManager
    @StateObject private var weatherService = WeatherService.shared
    @State private var showCityPicker = false
    
    var body: some View {
        ZStack {
            // Prague night background
            Image("PragueBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(
                    // Soft bottom fade so content stays readable
                    LinearGradient(
                        colors: [.clear, Color(hex: "0D0221").opacity(0.75), Color(hex: "0D0221")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button {
                            showCityPicker = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(Theme.primaryPurple)
                                Text(data.selectedCity)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Theme.textMuted)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button {} label: {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.primaryOrange)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Theme.primaryPurple.opacity(0.4)))
                            }
                            Button {} label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Theme.primaryPurple.opacity(0.4)))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                if weatherService.isLoading {
                    ProgressView()
                        .tint(Theme.primaryOrange)
                        .padding(.top, 60)
                } else if let w = weatherService.weather {
                    // Main weather card
                    ZStack {
                        // Decorative background elements
                        Circle()
                            .fill(Theme.primaryPurple.opacity(0.15))
                            .frame(width: 200, height: 200)
                            .blur(radius: 40)
                            .offset(x: 80, y: -40)
                        
                        VStack(spacing: 8) {
                            HStack(alignment: .center, spacing: 8) {
                                // Custom flame character from assets
                                PetCharacterView(size: 130, style: .flame)
                                    .offset(y: 6)
                                
                                Spacer(minLength: 4)
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Image(systemName: w.weatherIcon)
                                        .font(.system(size: 42))
                                        .foregroundStyle(
                                            LinearGradient(colors: [Color(hex: "A78BFA"), Color(hex: "FBBF24")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .shadow(color: Color(hex: "A78BFA").opacity(0.6), radius: 12)
                                    
                                    Text("\(Int(w.temperature))°")
                                        .font(.system(size: 68, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("Ощущается как \(Int(w.feelsLike))°")
                                        .font(.system(size: 14))
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                            .padding(.horizontal, 4)
                            
                            // Advice buttons
                            HStack(spacing: 12) {
                                AdviceChip(icon: w.clothingIcon, text: w.clothingAdvice)
                                AdviceChip(icon: "umbrella.fill", text: w.needUmbrella ? "Возьми зонт" : "Зонт не нужен")
                            }
                        }
                        .padding(20)
                    }
                    .padding(.horizontal, 16)
                    
                    // Daily forecast
                    VStack(spacing: 0) {
                        ForEach(w.daily) { day in
                            HStack {
                                Text(day.day)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 90, alignment: .leading)
                                
                                Spacer()
                                
                                Image(systemName: day.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(Theme.primaryOrange)
                                    .frame(width: 30)
                                
                                Spacer()
                                
                                Text("\(Int(day.tempMin))°")
                                    .font(.system(size: 15))
                                    .foregroundColor(Theme.textMuted)
                                Text("\(Int(day.tempMax))°")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 36, alignment: .trailing)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            
                            if day.id != w.daily.last?.id {
                                Divider().background(Color.white.opacity(0.08))
                            }
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal, 16)
                    
                    // Details row
                    HStack(spacing: 0) {
                        WeatherDetailItem(icon: "drop.fill", value: "\(w.humidity)%", label: "Влажность")
                        Divider().frame(height: 40).background(Color.white.opacity(0.15))
                        WeatherDetailItem(icon: "wind", value: "\(Int(w.windSpeed)) км/ч", label: "Ветер")
                        Divider().frame(height: 40).background(Color.white.opacity(0.15))
                        WeatherDetailItem(icon: "barometer", value: "\(w.pressure) гПа", label: "Давление")
                        Divider().frame(height: 40).background(Color.white.opacity(0.15))
                        WeatherDetailItem(icon: "sunset.fill", value: w.sunset, label: "Закат")
                    }
                    .padding(.vertical, 14)
                    .cardStyle()
                    .padding(.horizontal, 16)
                    
                } else if let err = weatherService.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer(minLength: 100)
                }
            }
        }
        .task {
            await weatherService.fetchWeather(for: data.selectedCity)
        }
        .onChange(of: data.selectedCity) { newCity in
            Task { await weatherService.fetchWeather(for: newCity) }
        }
        .sheet(isPresented: $showCityPicker) {
            CityPickerView(selectedCity: $data.selectedCity, cities: weatherService.availableCities)
        }
    }
}

struct AdviceChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.primaryOrange)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            Image(systemName: "chevron.right")
                .font(.system(size: 10))
                .foregroundColor(Theme.textMuted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(hex: "2A1A5E").opacity(0.8))
        )
    }
}

struct WeatherDetailItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Theme.primaryPurple)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CityPickerView: View {
    @Binding var selectedCity: String
    let cities: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(cities, id: \.self) { city in
                Button {
                    selectedCity = city
                    DataManager.shared.saveAll()
                    dismiss()
                } label: {
                    HStack {
                        Text(city)
                            .foregroundColor(.white)
                        Spacer()
                        if city == selectedCity {
                            Image(systemName: "checkmark")
                                .foregroundColor(Theme.primaryOrange)
                        }
                    }
                }
                .listRowBackground(Theme.cardBackgroundSolid)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Выбери город")
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

struct PetCharacterView: View {
    var size: CGFloat = 100
    var style: PetStyle = .flame
    @EnvironmentObject var data: DataManager
    
    enum PetStyle {
        case flame, fox, foxCoin, flameHappy
    }
    
    var body: some View {
        ZStack {
            // Soft glow behind character
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.45), Color.orange.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 8,
                        endRadius: size * 0.75
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)
                .blur(radius: 4)
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .shadow(color: .orange.opacity(0.5), radius: 16, y: 4)
        }
        .frame(width: size, height: size)
    }
    
    private var imageName: String {
        switch style {
        case .flame: return "PetFlame"
        case .fox: return "PetFox"
        case .foxCoin: return "PetFoxCoin"
        case .flameHappy: return "FlameHappy"
        }
    }
}

#Preview {
    WeatherView()
        .environmentObject(DataManager.shared)
}
