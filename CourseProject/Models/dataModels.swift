//
//  dataModels.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/29/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class UserProfile {
    var username: String
    var joinDate: Date
    var password: String
    
    // relationships
    @Relationship(deleteRule: .cascade)
    var collectedCards: [CarCard] = []
    
    @Relationship(deleteRule: .nullify)
    var friends: [UserProfile] = []
    
    // initializer
    init(username: String, password: String, joinDate: Date = .now){
        self.username = username
        self.password = password
        self.joinDate = joinDate
    }
    
    static var dummy: UserProfile {
        let user = UserProfile(username: "test", password: "test", joinDate: .now)
        return user
    }
}

@Model
final class CarCard {
    var make: String
    var model: String
    var year: Int
    
    var owner: UserProfile
    
    init(make: String, model: String, year: Int, owner: UserProfile) {
        self.make = make
        self.model = model
        self.year = year
        self.owner = owner
    }
}

@Model
final class Meetup {
    var title: String
    var meetupDescription: String
    var date: Date
    var time: Date
    var address: String
    var latitude: Double
    var longitude: Double
    var isActive: Bool = true
    
    @Relationship(deleteRule: .nullify)
    var host: UserProfile?
    
    @Relationship(deleteRule: .nullify)
    var attendees: [UserProfile] = []
    
    // Computed property for coordinate
    var coordinate: CLLocationCoordinate2D {
        get {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    init(
        title: String,
        meetupDescription: String,
        date: Date,
        time: Date,
        address: String,
        coordinate: CLLocationCoordinate2D,
        host: UserProfile? = nil,
        attendees: [UserProfile] = []
    ) {
        self.title = title
        self.meetupDescription = meetupDescription
        self.date = date
        self.time = time
        self.address = address
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.host = host
        self.attendees = attendees
    }
    
    func formattedDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: combinedDateTime())
    }
    
    private func combinedDateTime() -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        return calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: calendar.date(from: dateComponents) ?? Date()
        ) ?? Date()
    }
}

enum AppTab: String, CaseIterable {
    case garage = "Garage"
    case trade = "Social"
    case map = "Meetups"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .garage: return "car.fill"
        case .trade: return "arrow.triangle.2.circlepath"
        case .map: return "map.fill"
        case .profile: return "person.fill"
        }
    }
}

