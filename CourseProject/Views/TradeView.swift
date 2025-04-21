//
//  TradeView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/30/25.
//

import SwiftUI
import SwiftData

struct TradeView: View {
    @Environment(AuthState.self) private var authState
    @Query private var allUsers: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    
    @State private var friendCodeInput = ""
    
    @State private var showTradeSheet = false
    @State private var selectedFriend: UserProfile?
    
    @State private var enteredTradeCode = ""
    @Query private var tradeSessions: [TradeSession]
    @State private var tradeErrorMessage: String? = nil
    @State private var showSuccessAlert = false

    
    var body: some View {
        NavigationView {
            VStack {
                // Add Friend Section
                HStack {
                    TextField("Enter Friend Code", text: $friendCodeInput)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Add Friend") {
                        addFriend()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                // Friends List
                List {
                    Section(header: Text("My Friends")) {
                        ForEach(authState.currentUser?.friends ?? [], id: \.self) { friend in
                            HStack {
                                Text(friend.username)
                                Spacer()
                                Button("Trade") {
                                    selectedFriend = friend
                                    showTradeSheet = true
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                Divider()

                VStack(spacing: 12) {
                    Text("Enter Trade Code")
                        .font(.subheadline)
                        .bold()
                    
                    //Trading code to accept a code
                    HStack {
                        TextField("6-character code", text: $enteredTradeCode)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.characters)

                        Button("Submit") {
                            redeemTradeCode()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                    if let error = tradeErrorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Social")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    let code = authState.currentUser?.friendCode
                    Text("My Friend Code: \(code ?? "")") //Display your friend code
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .sheet(item: $selectedFriend) { friend in
                TradeInitiateView(recipient: friend) //Pulls up trading interface
            }
            .alert("Trade Successful!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("The car has been added to your collection.")
            }
        }
    }
    
    //Function to add a friend to your friends list
    func addFriend() {
        guard let me = authState.currentUser else {
            print("No current user found")
            return
        }
        
        let cleaned = friendCodeInput.uppercased().trimmingCharacters(in: .whitespaces)
        
        if let newFriend = allUsers.first(where: { $0.friendCode == cleaned && $0 != me }) {
            print("Match found, User: \(newFriend.username)")
            
            if !me.friends.contains(newFriend) { //Make sure you aren't already friends
                me.friends.append(newFriend)
                newFriend.friends.append(me)
                try? modelContext.save()
                print("\(newFriend.username) added as friend!")
                friendCodeInput = ""
            } else {
                print("\(newFriend.username) is already a friend")
            }
        } else {
            print("No user found with code \(cleaned)")
        }
    }
    
    //Enter your trade code that will be linked to a trade session and the card is added to your collection
    func redeemTradeCode() {
        guard let me = authState.currentUser else {
            print("No logged-in user.")
            tradeErrorMessage = "Not logged in."
            return
        }

        let cleanedCode = enteredTradeCode.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)

//        // List available sessions
//        print("📦 Trade sessions: \(tradeSessions.map { "\($0.code) from \($0.sender.username)" })")

        // Find matching session where sender is not the current user
        if let session = tradeSessions.first(where: {
            $0.code == cleanedCode && $0.sender.username != me.username
        }) {
            print("Valid session found for code \(session.code) from \(session.sender.username)")

            // No duplicate cards
            if !me.collectedCards.contains(session.card) {
                me.collectedCards.append(session.card)
                try? modelContext.save()
                print("Card added to \(me.username) collection")
                tradeErrorMessage = nil
                showSuccessAlert = true
            } else {
                //print("Card already in collection")
                tradeErrorMessage = "You already have this card."
            }

            enteredTradeCode = ""
        } else {
            tradeErrorMessage = "Invalid or expired trade code."

            //auto-clear error after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                tradeErrorMessage = nil
            }
        }
    }
}

//View to make a trade with the selected freind
struct TradeInitiateView: View {
    @Environment(AuthState.self) private var authState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCard: CarCard?
    @State private var tradeCode: String?

    var recipient: UserProfile

    @Query private var carCards: [CarCard]

    var garageCards: [CarCard] {
        carCards.filter { $0.owner.username == authState.currentUser?.username }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Trading with \(recipient.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if tradeCode == nil {
                    Text("Select a Car to Trade")
                        .font(.headline)
                    
                    //List all the cards in your garage to select from
                    List(garageCards, id: \.self) { car in
                        Button {
                            generateTradeCode(for: car)
                        } label: {
                            VStack(alignment: .leading) {
                                Text("\(car.make) \(car.model)")
                                    .bold()
                                Text("Year: \(car.year)").font(.caption)
                            }
                        }
                    }
                } else { //Code to give to your frind that you want to trade with
                    Text("Your Trade Code")
                        .font(.headline)

                    Text(tradeCode ?? "")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .padding()

                    Spacer()

                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Trade")
        }
    }

    //Generate a random code to make a trade with and make a Trade Session instance
    func generateTradeCode(for car: CarCard) {
        let trade = TradeSession(
            code: UUID().uuidString.prefix(6).uppercased(),
            card: car,
            sender: authState.currentUser!
        )

        modelContext.insert(trade) //Add trade instance to swift Data
        try? modelContext.save()

        tradeCode = trade.code
    }
}
