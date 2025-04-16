//
//  LoginView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/30/25.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(AuthState.self) private var authState
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background color
            Color(hex: "#1f1c18")
                .ignoresSafeArea()
            
            // Login content
            VStack(spacing: 15) {
                Text("Car TCG")
                    .font(.system(size: 50).bold())
                    .foregroundColor(Color(hex: "#ffeff0"))
                
                Text("The car collector's trading card app")
                    .font(.system(size: 20).italic())
                    .foregroundColor(Color(hex: "7da5a5"))
                
                Image(systemName: "car.fill")
                    .font(.system(size: 200))
                    .foregroundColor(Color(hex: "#ffeff0"))
                    .padding(.bottom, 20)
                
                VStack(spacing: 20) {
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
                    
                    // Error message
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    // Login button
                    Button {
                        if authState.login(username: username, password: password) {
                            // Login successful - handled by AuthState
                        } else {
                            showError(message: "Invalid credentials")
                        }
                    } label: {
                        Text("Log in")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "7da5a5"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white)
                        Text("OR")
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white)
                    }
                    
                    // Create account link
                    NavigationLink {
                        SignUpView()
                    } label: {
                        Text("Create new account")
                            .foregroundColor(Color(hex: "7da5a5"))
                    }
                }
                .padding()
            }
            .padding()
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let authState = AuthState()
    authState.setup(modelContext: container.mainContext)
    
    return LoginView()
        .environment(authState)
        .modelContainer(container)
}
