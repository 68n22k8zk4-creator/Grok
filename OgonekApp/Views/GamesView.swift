import SwiftUI

struct GamesView: View {
    @EnvironmentObject var data: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedGame: GameType?
    
    enum GameType: String, CaseIterable, Identifiable {
        case ticTacToe = "Крестики-нолики"
        case memory = "Память"
        case guess = "Угадай число"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .ticTacToe: return "xmark.circle"
            case .memory: return "rectangle.grid.2x2"
            case .guess: return "questionmark.circle"
            }
        }
        
        var emoji: String {
            switch self {
            case .ticTacToe: return "❌"
            case .memory: return "🃏"
            case .guess: return "🔢"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Выбери игру с Огоньком")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textMuted)
                        .padding(.top, 8)
                    
                    ForEach(GameType.allCases) { game in
                        Button {
                            selectedGame = game
                        } label: {
                            HStack(spacing: 16) {
                                Text(game.emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 56, height: 56)
                                    .background(Circle().fill(Theme.primaryPurple.opacity(0.3)))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(game.rawValue)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Против Огонька")
                                        .font(.system(size: 13))
                                        .foregroundColor(Theme.textMuted)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Theme.textMuted)
                            }
                            .padding(16)
                            .cardStyle()
                        }
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Игры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .sheet(item: $selectedGame) { game in
                switch game {
                case .ticTacToe:
                    TicTacToeGame()
                case .memory:
                    MemoryGame()
                case .guess:
                    GuessNumberGame()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Tic Tac Toe
struct TicTacToeGame: View {
    @EnvironmentObject var data: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var board: [String?] = Array(repeating: nil, count: 9)
    @State private var isPlayerTurn = true
    @State private var winner: String? = nil
    @State private var status = "Твой ход (❌)"
    
    private let winPatterns = [
        [0,1,2], [3,4,5], [6,7,8],
        [0,3,6], [1,4,7], [2,5,8],
        [0,4,8], [2,4,6]
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(status)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                    ForEach(0..<9, id: \.self) { i in
                        Button {
                            playerMove(at: i)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.cardBackgroundSolid)
                                    .aspectRatio(1, contentMode: .fit)
                                
                                if let mark = board[i] {
                                    Text(mark)
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(mark == "❌" ? Theme.primaryOrange : Theme.primaryPurple)
                                }
                            }
                        }
                        .disabled(board[i] != nil || winner != nil || !isPlayerTurn)
                    }
                }
                .padding(.horizontal, 30)
                
                if winner != nil {
                    Button("Ещё раз") {
                        reset()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Theme.orangeGradient)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(.top, 20)
            .background(Theme.background)
            .navigationTitle("Крестики-нолики")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        if winner == "❌" {
                            data.playWithPet()
                        }
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func playerMove(at index: Int) {
        guard board[index] == nil, isPlayerTurn, winner == nil else { return }
        board[index] = "❌"
        isPlayerTurn = false
        checkWinner()
        if winner == nil {
            status = "Ход Огонька..."
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                botMove()
            }
        }
    }
    
    private func botMove() {
        // Simple AI: win if possible, block if needed, else random
        if let move = findBestMove(for: "⭕") ?? findBestMove(for: "❌") {
            board[move] = "⭕"
        } else if let random = board.indices.filter({ board[$0] == nil }).randomElement() {
            board[random] = "⭕"
        }
        isPlayerTurn = true
        checkWinner()
        if winner == nil {
            status = "Твой ход (❌)"
        }
    }
    
    private func findBestMove(for mark: String) -> Int? {
        for pattern in winPatterns {
            let values = pattern.map { board[$0] }
            if values.filter({ $0 == mark }).count == 2,
               let emptyIdx = pattern.first(where: { board[$0] == nil }) {
                return emptyIdx
            }
        }
        return nil
    }
    
    private func checkWinner() {
        for pattern in winPatterns {
            let values = pattern.map { board[$0] }
            if values[0] != nil && values[0] == values[1] && values[1] == values[2] {
                winner = values[0]
                status = winner == "❌" ? "Ты победил! 🎉" : "Огонёк победил 🔥"
                if winner == "❌" {
                    data.playWithPet()
                }
                return
            }
        }
        if board.allSatisfy({ $0 != nil }) {
            winner = "draw"
            status = "Ничья!"
        }
    }
    
    private func reset() {
        board = Array(repeating: nil, count: 9)
        isPlayerTurn = true
        winner = nil
        status = "Твой ход (❌)"
    }
}

// MARK: - Memory Game (simple)
struct MemoryGame: View {
    @EnvironmentObject var data: DataManager
    @Environment(\.dismiss) var dismiss
    
    private let emojis = ["🔥", "🦊", "⭐", "💜", "🌙", "✨"]
    @State private var cards: [String] = []
    @State private var flipped: Set<Int> = []
    @State private var matched: Set<Int> = []
    @State private var firstIndex: Int? = nil
    @State private var moves = 0
    @State private var isLocked = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Ходов: \(moves)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                    ForEach(0..<cards.count, id: \.self) { i in
                        Button {
                            flip(i)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(matched.contains(i) ? Theme.accentGreen.opacity(0.3) : Theme.cardBackgroundSolid)
                                    .aspectRatio(1, contentMode: .fit)
                                
                                if flipped.contains(i) || matched.contains(i) {
                                    Text(cards[i])
                                        .font(.system(size: 32))
                                } else {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(Theme.primaryPurple.opacity(0.5))
                                }
                            }
                        }
                        .disabled(matched.contains(i) || flipped.contains(i) || isLocked)
                    }
                }
                .padding()
                
                if matched.count == cards.count {
                    Text("Победа! 🎉")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.accentGreen)
                        .onAppear {
                            data.playWithPet()
                        }
                }
                
                Spacer()
            }
            .background(Theme.background)
            .navigationTitle("Память")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .onAppear {
                cards = (emojis + emojis).shuffled()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func flip(_ index: Int) {
        flipped.insert(index)
        moves += 1
        
        if let first = firstIndex {
            isLocked = true
            if cards[first] == cards[index] {
                matched.insert(first)
                matched.insert(index)
                flipped.removeAll()
                firstIndex = nil
                isLocked = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    flipped.removeAll()
                    firstIndex = nil
                    isLocked = false
                }
            }
        } else {
            firstIndex = index
        }
    }
}

// MARK: - Guess Number
struct GuessNumberGame: View {
    @EnvironmentObject var data: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var secret = Int.random(in: 1...50)
    @State private var guess = ""
    @State private var message = "Угадай число от 1 до 50"
    @State private var attempts = 0
    @State private var won = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🔥")
                    .font(.system(size: 60))
                
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Твой вариант", text: $guess)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
                    .multilineTextAlignment(.center)
                
                Button("Проверить") {
                    check()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Theme.orangeGradient)
                .cornerRadius(12)
                .disabled(won)
                
                if won {
                    Text("Попыток: \(attempts)")
                        .foregroundColor(Theme.accentGreen)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .background(Theme.background)
            .navigationTitle("Угадай число")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        if won { data.playWithPet() }
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func check() {
        guard let g = Int(guess) else { return }
        attempts += 1
        if g == secret {
            message = "Правильно! 🎉 Огонёк рад!"
            won = true
            data.playWithPet()
        } else if g < secret {
            message = "Больше! 🔥"
        } else {
            message = "Меньше! ❄️"
        }
        guess = ""
    }
}

#Preview {
    GamesView()
        .environmentObject(DataManager.shared)
}
