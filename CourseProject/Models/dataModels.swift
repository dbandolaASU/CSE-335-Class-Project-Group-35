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
    var profileImage: Data?
    
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
    
    var locationName: String
    var latitude: Double
    var longitude: Double
    
    @Relationship(deleteRule: .nullify)
    var host: UserProfile?
        
    init(
        title: String,
        meetupDescription: String,
        date: Date,
        time: Date,
        locationName: String,
        coordinate: CLLocationCoordinate2D,
        host: UserProfile? = nil
    ){
        self.title = title
        self.meetupDescription = meetupDescription
        self.date = date
        self.time = time
        self.locationName = locationName
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.host = host
    }
}

enum AppTab: String, CaseIterable {
    case garage = "Garage"
    case trade = "Trade"
    case home = "Home"
    case map = "Map"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .garage: return "car.fill"
        case .trade: return "arrow.triangle.2.circlepath"
        case .home: return "house.fill"
        case .map: return "map.fill"
        case .profile: return "person.fill"
        }
    }
}
