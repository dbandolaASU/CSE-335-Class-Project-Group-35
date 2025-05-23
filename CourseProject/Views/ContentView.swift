//
//  ContentView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/28/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AuthState.self) private var authState
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .garage
    
    // setup app ui views
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color(hex: "#1f1c18"))
        
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "#7da5a5"))
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "#7da5a5")),
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ]
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(hex: "#ffeff0")).withAlphaComponent(0.6)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "#ffeff0")).withAlphaComponent(0.6),
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().isTranslucent = false

    }
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                // Garage View
                GarageView()
                    .tabItem {
                        Label(AppTab.garage.rawValue, systemImage: AppTab.garage.icon)
                    }
                    .tag(AppTab.garage)
                
                // Trade View
                TradeView()
                    .tabItem {
                        Label(AppTab.trade.rawValue, systemImage: AppTab.trade.icon)
                    }
                    .tag(AppTab.trade)
                
                // Map View
                MapView()
                    .tabItem {
                        Label(AppTab.map.rawValue, systemImage: AppTab.map.icon)
                    }
                    .tag(AppTab.map)
                
                
                ProfileView()
                    .tabItem {
                        Label(AppTab.profile.rawValue, systemImage: AppTab.profile.icon)
                    }
                    .tag(AppTab.profile)
            }
            .tint(Color(hex: "7da5a5"))
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let authState = AuthState()
    authState.setup(modelContext: container.mainContext)
    
    return ContentView()
        .environment(authState)
        .modelContainer(container)
}
