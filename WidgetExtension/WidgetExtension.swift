import WidgetKit
import SwiftUI

struct OgonekEntry: TimelineEntry {
    let date: Date
    let petLevel: Int
    let streak: Int
    let todayHours: String
    let monthlyEarnings: String
    let needsCare: Bool
}

struct OgonekProvider: TimelineProvider {
    func placeholder(in context: Context) -> OgonekEntry {
        OgonekEntry(date: Date(), petLevel: 1, streak: 3, todayHours: "2:30", monthlyEarnings: "1080", needsCare: true)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (OgonekEntry) -> Void) {
        completion(loadEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<OgonekEntry>) -> Void) {
        let entry = loadEntry()
        // Update every 15 minutes
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(next))
        completion(timeline)
    }
    
    private func loadEntry() -> OgonekEntry {
        let defaults = UserDefaults(suiteName: "group.com.ogonek.app") ?? .standard
        // For simplicity use standard; in production use App Group
        let level = 1
        let streak = 0
        return OgonekEntry(
            date: Date(),
            petLevel: level,
            streak: streak,
            todayHours: "0:00",
            monthlyEarnings: "0",
            needsCare: true
        )
    }
}

struct OgonekWidgetView: View {
    var entry: OgonekEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .systemLarge:
            largeView
        default:
            smallView
        }
    }
    
    private var smallView: some View {
        ZStack {
            Color(red: 0.05, green: 0.01, blue: 0.13)
            VStack(spacing: 6) {
                Text("🔥")
                    .font(.system(size: 36))
                Text("Ур. \(entry.petLevel)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                if entry.needsCare {
                    Text("Покорми!")
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                } else {
                    Text("\(entry.streak) дн.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    private var mediumView: some View {
        ZStack {
            Color(red: 0.05, green: 0.01, blue: 0.13)
            HStack(spacing: 16) {
                VStack {
                    Text("🔥")
                        .font(.system(size: 40))
                    Text("Ур. \(entry.petLevel)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Label("\(entry.todayHours)", systemImage: "clock")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Label("\(entry.monthlyEarnings) UAH", systemImage: "banknote")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                    if entry.needsCare {
                        Text("Огонёк ждёт заботы")
                            .font(.caption2)
                            .foregroundColor(.pink)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
    
    private var largeView: some View {
        ZStack {
            Color(red: 0.05, green: 0.01, blue: 0.13)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("🔥 Огонёк")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("Ур. \(entry.petLevel)")
                        .foregroundColor(.orange)
                }
                
                Divider().background(Color.white.opacity(0.2))
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Сегодня")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(entry.todayHours)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("За месяц")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(entry.monthlyEarnings)")
                            .font(.title2.bold())
                            .foregroundColor(.orange)
                    }
                }
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Серия: \(entry.streak) дней")
                        .foregroundColor(.white)
                }
                
                if entry.needsCare {
                    Text("Не забудь покормить Огонька сегодня!")
                        .font(.caption)
                        .foregroundColor(.pink)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

@main
struct OgonekWidgetBundle: WidgetBundle {
    var body: some Widget {
        OgonekWidget()
    }
}

struct OgonekWidget: Widget {
    let kind: String = "OgonekWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: OgonekProvider()) { entry in
            OgonekWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.05, green: 0.01, blue: 0.13)
                }
        }
        .configurationDisplayName("Огонёк")
        .description("Питомец, смены и заработок")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
