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
    @State private var isAuthenticated = false
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: UserProfile.self, CarCard.self)
            insertDummyData()
        } catch {
            fatalError("Failed to create container")
        }
    }
    
    // go to login if not authenticated
    var body: some Scene {
        WindowGroup {
            if isAuthenticated{
                ContentView()
            }
            else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
        .modelContainer(for: [UserProfile.self])
    }
    
    private func insertDummyData() {
        Task { @MainActor in
            let context = container.mainContext
            // Check if dummy exists first
            let descriptor = FetchDescriptor<UserProfile>(predicate: #Predicate { $0.username == "test" })
            if (try? context.fetch(descriptor))?.isEmpty ?? true {
                context.insert(UserProfile.dummy)
                print("Dummy user inserted")
            }
        }
    }
}
