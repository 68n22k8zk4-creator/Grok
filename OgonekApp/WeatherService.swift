import Foundation

@MainActor
class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    @Published var weather: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // City coordinates (common cities)
    private let cities: [String: (lat: Double, lon: Double, name: String, country: String)] = [
        "Прага": (50.0755, 14.4378, "Прага", "Чехия"),
        "Киев": (50.4501, 30.5234, "Киев", "Украина"),
        "Москва": (55.7558, 37.6173, "Москва", "Россия"),
        "Варшава": (52.2297, 21.0122, "Варшава", "Польша"),
        "Берлин": (52.5200, 13.4050, "Берлин", "Германия"),
        "Лондон": (51.5074, -0.1278, "Лондон", "Великобритания"),
        "Париж": (48.8566, 2.3522, "Париж", "Франция"),
        "Нью-Йорк": (40.7128, -74.0060, "Нью-Йорк", "США"),
        "Токио": (35.6762, 139.6503, "Токио", "Япония"),
        "Стамбул": (41.0082, 28.9784, "Стамбул", "Турция"),
        "Вена": (48.2082, 16.3738, "Вена", "Австрия"),
        "Будапешт": (47.4979, 19.0402, "Будапешт", "Венгрия"),
        "Львов": (49.8397, 24.0297, "Львов", "Украина"),
        "Одесса": (46.4825, 30.7233, "Одесса", "Украина"),
        "Харьков": (49.9935, 36.2304, "Харьков", "Украина"),
    ]
    
    var availableCities: [String] {
        Array(cities.keys).sorted()
    }
    
    func fetchWeather(for city: String) async {
        isLoading = true
        errorMessage = nil
        
        guard let coords = cities[city] else {
            errorMessage = "Город не найден"
            isLoading = false
            return
        }
        
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(coords.lat)&longitude=\(coords.lon)&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,surface_pressure,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto&forecast_days=7"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Неверный URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            dayFormatter.locale = Locale(identifier: "en_US")
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            var daily: [DailyForecast] = []
            for i in 0..<min(5, response.daily.time.count) {
                let dateStr = response.daily.time[i]
                var dayName = dateStr
                if let date = ISO8601DateFormatter().date(from: dateStr + "T12:00:00Z") {
                    dayName = dayFormatter.string(from: date)
                } else if let date = DateFormatter.yyyyMMdd.date(from: dateStr) {
                    dayName = dayFormatter.string(from: date)
                }
                daily.append(DailyForecast(
                    day: dayName,
                    weatherCode: response.daily.weather_code[i],
                    tempMin: response.daily.temperature_2m_min[i],
                    tempMax: response.daily.temperature_2m_max[i]
                ))
            }
            
            let sunset = response.daily.sunset.first ?? "--:--"
            let sunsetTime = String(sunset.suffix(5))
            
            weather = WeatherData(
                temperature: response.current.temperature_2m,
                feelsLike: response.current.apparent_temperature,
                humidity: Int(response.current.relative_humidity_2m),
                windSpeed: response.current.wind_speed_10m,
                pressure: Int(response.current.surface_pressure),
                weatherCode: response.current.weather_code,
                sunrise: response.daily.sunrise.first.map { String($0.suffix(5)) } ?? "--:--",
                sunset: sunsetTime,
                city: coords.name,
                country: coords.country,
                daily: daily
            )
        } catch {
            errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Open-Meteo Response
struct OpenMeteoResponse: Codable {
    let current: CurrentWeather
    let daily: DailyWeather
}

struct CurrentWeather: Codable {
    let temperature_2m: Double
    let relative_humidity_2m: Double
    let apparent_temperature: Double
    let weather_code: Int
    let surface_pressure: Double
    let wind_speed_10m: Double
}

struct DailyWeather: Codable {
    let time: [String]
    let weather_code: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
    let sunrise: [String]
    let sunset: [String]
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
