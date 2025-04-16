//
//  MapView.swift
//  CourseProject
//
//  Created by Daniel Bandola on 3/30/25.
//

import SwiftUI

struct MapView: View {
    @Environment(AuthState.self) private var authState
    
    var body: some View {
        Text("MAP")
    }
}

#Preview {
    MapView()
}
