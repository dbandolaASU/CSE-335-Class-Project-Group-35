//
//  dataModels.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/29/25.
//

import Foundation
import SwiftData

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
