//
//  GarageView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/30/25.
//

import SwiftUI

struct GarageView: View {
    @Environment(AuthState.self) private var authState
    
    var body: some View {
        Text("GARAGE")
    }
}

#Preview {
    GarageView()
}
