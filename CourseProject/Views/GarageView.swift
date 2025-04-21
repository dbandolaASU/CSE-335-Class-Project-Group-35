//
//  GarageView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/30/25.
//

import SwiftUI
import SwiftData

struct GarageView: View {
    @Environment(AuthState.self) private var authState
    @Query private var users: [UserProfile]
    @State private var currentUser: UserProfile? = nil
    @State private var showingAddCarSheet = false
    @Query private var carCards: [CarCard]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // My Garage Header
                HStack {
                    Text("My Garage")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button(action: {
                        showingAddCarSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                    .sheet(isPresented: $showingAddCarSheet) {
                        AddCarSheet(currentUser: authState.currentUser)
                    }
                }
                .padding(.horizontal)

                // Garage Cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(garageCards, id: \.self) { car in
                        CarCardView(car: car, backgroundColor: .yellow)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Collection Header
                Text("My card collection")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)

                // Collected Cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(collectedCards, id: \.self) { car in
                        CarCardView(car: car, backgroundColor: .yellow)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .onAppear {
            currentUser = users.first(where: { $0.username == authState.currentUser?.username })
        }
        .background(
            LinearGradient(colors: [.gray.opacity(0.1), .gray.opacity(0.3)],
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private var garageCards: [CarCard] {
        carCards.filter { $0.owner.username == authState.currentUser?.username }
    }

    private var collectedCards: [CarCard] {
        authState.currentUser?.collectedCards ?? []
    }
}

struct CarCardView: View {
    var car: CarCard
    var backgroundColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(car.make)")
                .bold()
            Text("\(car.model)")
                .bold()
            Image(systemName: "car.fill")
                .resizable()
                .frame(width: 50, height: 40)
                .foregroundColor(.white)
                .padding(.top, 8)

            Text("Year: \(String(car.year))")
            
            if let hp = car.cylinders {
                Text("Cylinders: \(hp)")
            }
//            if let disp = car.displacement {
//                Text("Trans: \(disp)")
//            }
            if let drive = car.drive {
                Text("Drive: \(drive.uppercased())")
            }
//            if let trans = car.transmission {
//                Text("Trans: \(trans.uppercased())")
//            }
            if let fuel = car.fuelType {
                Text("Fuel: \(fuel.capitalized)")
            }
        }
        .font(.caption)
        .foregroundColor(.black)
        .padding()
        .frame(width: 115, height: 185)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

//Pop up to add a car to your garage
struct AddCarSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var currentUser: UserProfile?
    @StateObject private var carVM = CarJSONVM()

    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var cyl = ""
    @State private var disp = ""
    @State private var drive = ""
    @State private var trans = ""
    @State private var fuel = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Make", text: $make)
                TextField("Model", text: $model)
                TextField("Year", text: $year)
                
                Button("Search & Autofill") { //Make API call and autofill car specs
                    carVM.getCarData(make: make, model: model) { spec in
                    cyl = spec.cylinders?.description ?? ""
                    disp = spec.displacement?.description ?? ""
                    drive = spec.drive ?? ""
                    trans = spec.transmission ?? ""
                    fuel = spec.fuel_type ?? ""
                    }
                }
                TextField("Cylinders", text: $cyl)
                TextField("Displacement", text: $disp)
                TextField("Drive", text: $drive)
                TextField("Transmission", text: $trans)
                TextField("fuel", text: $fuel)
            }
            .navigationTitle("Add a Car")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add to Garage") { //Add the car you your garage
                        guard let user = currentUser,
                              let intYear = Int(year) else {
                            print("Missing required data. User: \(String(describing: currentUser)), Year: \(year)")
                            return
                        }

                        let car = CarCard(
                            make: make.capitalized,
                            model: model.capitalized,
                            year: intYear,
                            owner: user,
                            cylinders: Int(cyl),
                            drive: drive,
                            fuelType: fuel,
                            transmission: trans,
                            displacement: Double(disp)
                        )

                        print("Inserting new car: \(car.make) \(car.model) for \(user.username)")
                        
                        modelContext.insert(car)

                        do {
                            try modelContext.save()
                            print("Car saved to model context")
                        } catch {
                            print("Failed to save car: \(error.localizedDescription)")
                        }

                        dismiss()
                    }
                    .disabled(make.isEmpty || model.isEmpty || year.isEmpty)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, CarCard.self, configurations: config)
    let context = container.mainContext

    do {
        // Dummy user
        let user = UserProfile(username: "jake", password: "pass")
        context.insert(user)

        // Dummy cars
        context.insert(CarCard(
            make: "Ferrari",
            model: "488 GTB",
            year: 2016,
            owner: user,
            cylinders: 8,
            drive: "RWD",
            fuelType: "Gasoline",
            transmission: "Automatic",
            displacement: 3.9
        ))

        context.insert(CarCard(
            make: "Toyota",
            model: "Supra",
            year: 2020,
            owner: user,
            cylinders: 6,
            drive: "RWD",
            fuelType: "Gasoline",
            transmission: "Manual",
            displacement: 3.0
        ))
        
        context.insert(CarCard(
            make: "Jeep",
            model: "Wrangler",
            year: 2020,
            owner: user,
            cylinders: 6,
            drive: "RWD",
            fuelType: "Gasoline",
            transmission: "Manual",
            displacement: 3.0
        ))
        
        context.insert(CarCard(
            make: "Toyota",
            model: "Supra",
            year: 2020,
            owner: user,
            cylinders: 6,
            drive: "RWD",
            fuelType: "Gasoline",
            transmission: "Manual",
            displacement: 3.0
        ))

        let authState = AuthState()
        authState.setup(modelContext: context)
        authState.login(username: user.username, password: user.password)

        return GarageView()
            .environment(authState)
            .modelContainer(container)

    }
}


