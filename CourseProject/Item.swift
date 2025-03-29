//
//  Item.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/28/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
