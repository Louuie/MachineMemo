//
//  Tabs.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//

import SwiftUI

struct Tabs: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomePage()
            }
            Tab("Machines", systemImage: "figure.strengthtraining.traditional") {
                MachinePage()
            }
            Tab("Profile", systemImage: "person") {
                Text("Profile Page")
                ProfileView()
            }
        }
    }
}

#Preview {
    Tabs()
}
