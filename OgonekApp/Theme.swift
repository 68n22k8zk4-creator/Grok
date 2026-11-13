import SwiftUI

struct Theme {
    // Backgrounds
    static let background = LinearGradient(
        colors: [Color(hex: "0D0221"), Color(hex: "1A0A3E"), Color(hex: "0D0221")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardBackground = Color(hex: "1E1245").opacity(0.85)
    static let cardBackgroundSolid = Color(hex: "1E1245")
    
    // Accents
    static let primaryOrange = Color(hex: "FF8C00")
    static let primaryPurple = Color(hex: "8B5CF6")
    static let accentPink = Color(hex: "EC4899")
    static let accentBlue = Color(hex: "3B82F6")
    static let accentGreen = Color(hex: "10B981")
    
    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textMuted = Color.white.opacity(0.5)
    
    // Gradients
    static let orangeGradient = LinearGradient(
        colors: [Color(hex: "FF8C00"), Color(hex: "FF5E00")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let purpleGradient = LinearGradient(
        colors: [Color(hex: "8B5CF6"), Color(hex: "6D28D9")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let fireGradient = LinearGradient(
        colors: [Color(hex: "FFD700"), Color(hex: "FF8C00"), Color(hex: "FF4500")],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom Button Styles
struct GlowButtonStyle: ButtonStyle {
    var color: Color = Theme.primaryOrange
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.cardBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
