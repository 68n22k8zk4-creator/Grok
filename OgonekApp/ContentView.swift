import SwiftUI

struct ContentView: View {
    @EnvironmentObject var data: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content
                TabView(selection: $selectedTab) {
                    WeatherView()
                        .tag(0)
                    ShiftsView()
                        .tag(1)
                    PetView()
                        .tag(2)
                    ExpensesView()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var data: DataManager
    
    private let tabs: [(icon: String, title: String)] = [
        ("cloud.sun.fill", "Погода"),
        ("calendar", "Смены"),
        ("flame.fill", "Огонёк"),
        ("creditcard.fill", "Траты")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if selectedTab == index {
                                Capsule()
                                    .fill(Theme.primaryPurple.opacity(0.3))
                                    .frame(width: 56, height: 36)
                            }
                            
                            Image(systemName: tabs[index].icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(selectedTab == index ? Theme.primaryOrange : Theme.textMuted)
                            
                            // Badge for pet if needs care
                            if index == 2 && data.pet.needsCare {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 12, y: -10)
                            }
                        }
                        
                        Text(tabs[index].title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(selectedTab == index ? Theme.primaryOrange : Theme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(GlowButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(hex: "150B2E").opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, 16)
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager.shared)
}
