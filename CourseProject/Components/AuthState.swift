//
//  AuthState.swift
//  CourseProject
//
//  Created by Daniel Bandola on 4/16/25.
//

import SwiftUI
import SwiftData

@Observable
final class AuthState {
    var isAuthenticated = false
    var currentUser: UserProfile?
    private(set) var modelContext: ModelContext?
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func login(username: String, password: String) -> Bool {
        guard let context = modelContext else { return false }
        
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { $0.username == username && $0.password == password }
        )
        
        if let user = (try? context.fetch(descriptor))?.first {
            currentUser = user
            isAuthenticated = true
            return true
        }
        return false
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}
