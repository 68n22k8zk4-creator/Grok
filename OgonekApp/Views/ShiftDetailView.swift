import SwiftUI

struct ShiftDetailView: View {
    @EnvironmentObject var data: DataManager
    let session: WorkSession
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Основное") {
                    LabeledContent("Название", value: session.name)
                    LabeledContent("Начало", value: format(session.startTime))
                    if let end = session.endTime {
                        LabeledContent("Конец", value: format(end))
                    }
                    LabeledContent("Отработано", value: session.formattedDuration)
                }
                
                if !session.breaks.isEmpty {
                    Section("Перерывы") {
                        ForEach(session.breaks) { br in
                            HStack {
                                Text(br.type.rawValue.capitalized)
                                Spacer()
                                Text("\(br.durationMinutes) мин")
                                    .foregroundColor(Theme.textMuted)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Смена")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func format(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMM, HH:mm"
        f.locale = Locale(identifier: "ru_RU")
        return f.string(from: date)
    }
}
