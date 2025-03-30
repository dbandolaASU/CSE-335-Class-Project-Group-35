//
//  LoginView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/30/25.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    
    @Environment(\.modelContext) private var context
    @Binding var isAuthenticated: Bool
    @Query private var users: [UserProfile]
    
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack{
            // background color
            Color(hex: "#1f1c18")
                .ignoresSafeArea()
            
            // login content
            VStack (spacing: 15){
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
                
                VStack (spacing: 20){
                    // username field
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
                    // password field
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
                    // error msg
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    // login button
                    Button(action: login) {
                        Text("Log in")
                            .frame(maxWidth: .infinity, maxHeight: 5)
                            .padding()
                            .background(Color(hex: "7da5a5"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    // spacer
                    HStack{
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
                    // create account link
                    NavigationLink{
                        SignUpView()
                    } label: {
                        Text("Create new account")
                            .foregroundColor(Color(hex: "7da5a5"))
                            .contentShape(Rectangle())
                    }
                }
                .padding()
            }
            .padding()
        }
    }
    
    private func login() {
        // empty field
        guard !username.isEmpty, !password.isEmpty else{
            showError(message: "Please fill all fields")
            return
        }
        // user not found
        guard let user = users.first(where: { $0.username == username }) else {
            showError(message: "User not found")
            return
        }
        
        // attempt login
        if user.password == password {
            print("Loggin in as \(user.username)")
            isAuthenticated = true
        }
        // incorrect password
        else {
            showError(message: "Incorrect password")
        }
    }
    
    // error helper func
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false))
}
