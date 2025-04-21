//
//  MapView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/30/25.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    @Environment(AuthState.self) private var authState
    @Environment(\.modelContext) private var modelContext
    @Query private var meetups: [Meetup]
    @State private var location = Location()
    @State private var position: MapCameraPosition = .automatic
    @State private var showMeetupCreation = false
    @State var selectedMeetup: Meetup?
    @State var selectedMeetupString: String = ""
    
    var body: some View {
        ZStack {
            Color(hex: "#999999")
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                
                Map(position: $position) {
                    // user location
                    UserAnnotation()
                    
                    // display meetups on map
                    ForEach(meetups) { meetup in
                        Annotation(
                            meetup.title,
                            coordinate: meetup.coordinate,
                            anchor: .bottom
                        ) {
                            Button {
                                selectedMeetup = meetup
                            }
                            label: {
                                CarMapAnnotation(meetup: meetup)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .mapStyle(.standard(elevation: .realistic))
                .frame(width:350, height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                .shadow(radius: 5)
                .background(Color(hex: "#999999"))
                
                
                if selectedMeetup != nil {
                    VStack {
                        Text(selectedMeetup?.title ?? "")
                            .font(.system(size:16))
                            .foregroundStyle(Color(hex: "#1f1c18"))
                        Text(selectedMeetup?.meetupDescription ?? "")
                            .font(.system(size:12))
                            .foregroundStyle(Color(hex: "#1f1c18"))
                        Text(selectedMeetup?.address ?? "")
                            .font(.system(size:12))
                            .foregroundStyle(Color(hex: "#1f1c18"))
                        Text(selectedMeetup?.formattedDateTime() ?? "")
                            .font(.system(size:12))
                            .foregroundStyle(Color(hex: "#1f1c18"))

                        Button {
                            joinMeetup()
                        }
                        label: {
                            Text("Join Meetup")
                                .frame(maxWidth: 100)
                                .padding()
                                .background(Color(hex: "7da5a5"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 10)
                }
               
                
                // show all meetups
                VStack(alignment: .leading) {
                    Text("Upcoming Meetups:")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    if meetups.isEmpty {
                        Text("No meetups found. Try creating one!")
                            .foregroundColor(.white.opacity(0.7))
                            .italic()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(meetups) { meetup in
                                    MeetupCard(meetup: meetup)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
                
                // create a meetup view
                Button {
                    showMeetupCreation = true
                } label: {
                    Text("Create new meetup")
                        .frame(maxWidth: 200)
                        .padding()
                        .background(Color(hex: "7da5a5"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
            }
            .sheet(isPresented: $showMeetupCreation) {
                MeetupCreationView(showingCreateMeetup: $showMeetupCreation)
            }
            .onAppear {
                location.requestLocation()
                position = .region(location.region)
            }
            .toolbarBackground(Color(hex: "#1f1c18"), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
    
    func joinMeetup() {
        // 1. Safely unwrap both required optionals
        guard let meetup = selectedMeetup,
              let currentUser = authState.currentUser else {
            print("No meetup selected or user not logged in")
            return
        }
        
        // 2. Check if user is already attending
        let isAlreadyAttending = meetup.attendees.contains { $0.username == currentUser.username }
        
        // 3. Add user if not already attending
        if !isAlreadyAttending {
            meetup.attendees.append(currentUser)
            
            // Optional: Explicit save if not using autosave
            do {
                try modelContext.save()
                print("Successfully joined meetup")
            } catch {
                print("Failed to join meetup: \(error)")
            }
        } else {
            print("User is already attending this meetup")
        }
    }}

// meetup card struct
struct MeetupCard: View {
    let meetup: Meetup
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(meetup.title)
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
            
            Text(meetup.address)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(meetup.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(10)
        .background(Color(hex: "#ffeff0").opacity(0.3))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#ffeff0"), lineWidth: 1)
        )
    }
}

// view for meetup creation
struct MeetupCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthState.self) private var authState
    
    @State private var newMeetupTitle = ""
    @State private var newMeetupDescription = ""
    @State private var newMeetupDate = Date()
    @State private var newMeetupTime = Date()
    @State private var newAddress = ""
    @State private var errorMessage: String?
    @State private var isCreating = false
    
    @Binding var showingCreateMeetup: Bool
    
    private let geocoder = CLGeocoder()
    
    var body: some View {
        ZStack {
            Color(hex: "#1f1c18")
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Create Meetup")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                
                Text("Meetup Details")
                    .foregroundColor(.white)
                
                TextField("Title", text: $newMeetupTitle)
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
                
                TextField("Description", text: $newMeetupDescription)
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
                
                DatePicker("Date", selection: $newMeetupDate, displayedComponents: .date)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "7da5a5"), lineWidth: 6)
                    )
                    .background(Color.white)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .tint(Color(hex: "7da5a5"))

                DatePicker("Time", selection: $newMeetupTime, displayedComponents: .hourAndMinute)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "7da5a5"), lineWidth: 6)
                    )
                    .background(Color.white)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .tint(Color(hex: "7da5a5"))
                
                TextField("Address", text: $newAddress)
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
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    Task {
                        await createMeetup()
                    }
                }) {
                if isCreating {
                    ProgressView()
                    .tint(.white)
                } else {
                    Text("Create Meetup")
                    }
                }
                .disabled(isCreating)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "7da5a5"))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
    
    // get coordinates from an address string
    private func getCoord(_ address: String) async -> CLLocationCoordinate2D? {
        guard !address.isEmpty else {
            errorMessage = "Please enter an address"
            return nil
        }
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            guard let location = placemarks.first?.location else {
                errorMessage = "Address not found"
                return nil
            }
            errorMessage = nil
            return location.coordinate
        } catch {
            errorMessage = "Geocoding failed: \(error.localizedDescription)"
            return nil
        }
    }
    
    // create meetup and push to swiftdata
    private func createMeetup() async {
            isCreating = true
            errorMessage = nil
            
            let newCoordinate = await getCoord(newAddress) ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            
            // Validate required fields
            guard !newMeetupTitle.isEmpty else {
                errorMessage = "Please enter a title"
                isCreating = false
                return
            }
            
            guard !newAddress.isEmpty else {
                errorMessage = "Please enter an address"
                isCreating = false
                return
            }
            
            do {
                let meetup = Meetup(
                    title: newMeetupTitle,
                    meetupDescription: newMeetupDescription,
                    date: newMeetupDate,
                    time: newMeetupTime,
                    address: newAddress,
                    coordinate: newCoordinate,
                    host: authState.currentUser,
                    attendees: []
                )
                
                modelContext.insert(meetup)
                
                // Only dismiss if successful
                DispatchQueue.main.async {
                    showingCreateMeetup = false
                    resetForm()
                }
            }
            isCreating = false
        }
    
    // clear the field
    private func resetForm() {
        newMeetupTitle = ""
        newMeetupDescription = ""
        newMeetupDate = Date()
        newMeetupTime = Date()
        newAddress = ""
        showingCreateMeetup = false
    }
}


// meetup on map
struct CarMapAnnotation: View {
    let meetup: Meetup
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "car.fill")
                .font(.title)
                .foregroundColor(Color(hex: "7da5a5"))
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                )
                .overlay(
                    Circle()
                        .stroke(Color(hex: "1f1c18"), lineWidth: 2)
                )
            
            Text(meetup.title)
                .font(.caption)
                .foregroundColor(.white)
                .padding(4)
                .background(Color(hex: "1f1c18"))
                .cornerRadius(4)
                .offset(y: -4)
        }
    }
}
