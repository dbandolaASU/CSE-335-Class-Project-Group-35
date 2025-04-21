//
//  CourseProjectApp.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/28/25.
//

import SwiftUI
import SwiftData

@main
struct CourseProjectApp: App {
    @State private var authState = AuthState()
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Meetup.self, UserProfile.self, CarCard.self)
        } catch {
            fatalError("Failed to create container")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if authState.isAuthenticated {
                    ContentView()
                } else {
                    LoginView()
                }
            }
            .environment(authState) // Inject AuthState
            .task {
                await initializeAuth()
            }
        }
        .modelContainer(container)
    }
    
    private func initializeAuth() async {
        // Initialize AuthState with context
        await MainActor.run {
            authState.setup(modelContext: container.mainContext)
        }
        
        // Insert dummy data if needed
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { $0.username == "test" }
        )
        
        if (try? container.mainContext.fetch(descriptor))?.isEmpty ?? true {
            container.mainContext.insert(UserProfile.dummy)
            print("Dummy user inserted")
        }
    }
}
