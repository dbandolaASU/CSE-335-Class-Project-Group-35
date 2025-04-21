//
//  ProfileView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/30/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthState.self) private var authState
    @Environment(\.modelContext) private var modelContext
    
    
    var body: some View {
        ZStack{
            Color(hex: "#e3e4e5")
                .ignoresSafeArea()
            VStack{
                Text("Your Profile")
                    .foregroundStyle(Color(hex: "#0000000"))
                RoundedRectangle(cornerRadius: 8)
                    .overlay(
                        VStack{
                            HStack{
                                Text("Username: ")
                                    .foregroundStyle(Color(hex: "#1f1c18"))
                                Text(authState.currentUser?.username ?? "")
                                    .foregroundStyle(Color(hex: "#1f1c18"))
                            }
                            HStack{
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 0)
                            HStack{
                                Text("Date joined: ")
                                    .foregroundStyle(Color(hex: "#1f1c18"))
                                Text(authState.currentUser?.joinDate.formatted(.dateTime.month().day().year()) ?? "No join date")
                                    .foregroundStyle(Color(hex: "#1f1c18"))

                            }
                        }
                       
                )
                    .padding()
                    .frame(width: 400, height: 100)
                    .foregroundStyle(Color(hex: "#ffeff0").opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#ffeff0"), lineWidth: 1)
                            .padding()
                    )
        
                Button {
                    authState.currentUser = nil
                    authState.isAuthenticated = false
                    
                } label: {
                    Text("Log out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "7da5a5"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
            }
        }
    }
}
