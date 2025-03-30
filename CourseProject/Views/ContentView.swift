//
//  ContentView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/28/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    
    init() {
            let appearance = UITabBarAppearance()
            
            // Background
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color(hex: "#1f1c18"))
            
            // Selected item
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "#7da5a5"))
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color(hex: "#7da5a5"))
            ]
            
            // Unselected items
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(hex: "#ffeff0")).withAlphaComponent(0.6)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(Color(hex: "#ffeff0")).withAlphaComponent(0.6)
            ]
            
            // Apply to all styles
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
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
                
                // Home View
                HomeView()
                    .tabItem {
                        Label(AppTab.home.rawValue, systemImage: AppTab.home.icon)
                    }
                    .tag(AppTab.home)
                
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
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserProfile.self)
}
