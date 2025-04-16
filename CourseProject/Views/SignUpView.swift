//
//  SignInView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/30/25.
//

import SwiftUI
import SwiftData

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthState.self) private var authState
    @Environment(\.modelContext) private var modelContext
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack{
            Color(hex: "#1f1c18")
                .ignoresSafeArea()
            VStack(spacing: 15){
                Text("Create Account")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "#ffeff0"))
                                    
                Image(systemName: "car.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "7da5a5"))
                
                // Username field
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "7da5a5"), lineWidth: 3)
                    )
                    .keyboardType(.default)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.username)
                
                // Password field
                TextField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "7da5a5"), lineWidth: 3)
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.password)
                
                // Confirm Password field
                TextField("Confirm password", text: $confirmPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "7da5a5"), lineWidth: 3)
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.password)
                
                // Error message
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                // sign up button
                Button {
                    signUp()
                } label: {
                    Text("Sign up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "7da5a5"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // back to login
                Button {
                    dismiss()
                }
                label: {
                    Text("Already have an account? **Login**")
                        .foregroundColor(Color(hex: "7da5a5"))
                }
            }
            .padding()
        }
    }
    
    private func signUp() {
        // validate inputs
        guard !username.isEmpty else {
            showError(message: "Username cannot be empty")
            return
        }
        
        guard password == confirmPassword else {
            showError(message: "Passwords don't match")
            return
        }
        
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { $0.username == username }
        )
        
        if(try? modelContext.fetch(descriptor))?.isEmpty == false {
            showError(message: "Username already taken")
            return
        }
        
        // create new user
        let newUser = UserProfile(
            username: username,
            password: password,
            joinDate: .now
        )
        
        modelContext.insert(newUser)
        authState.currentUser = newUser
        authState.isAuthenticated = true
        dismiss()
            
    }
    
    private func showError(message: String){
        errorMessage = message
        showError = true
    }
}

#Preview {
    // 1. Set up in-memory container
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    
    // 2. Create mock AuthState
    let authState = AuthState()
    
    // 3. Return the view with dependencies
    return SignUpView()
        .environment(authState)
        .modelContainer(container)
}
