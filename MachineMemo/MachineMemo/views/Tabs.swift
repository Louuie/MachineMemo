//
//  Tabs.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//

import SwiftUI

struct Tabs: View {
    @State private var profile: Profile = Profile(name: "", email: "", profile_picture: "")
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomePage()
            }
            Tab("Machines", systemImage: "figure.strengthtraining.traditional") {
                MachinePage()
            }
            Tab("Your Machines", systemImage: "list.star") {
                YourMachinesPage()
            }
            Tab("Calculator", systemImage: "dumbell") {
                BarbellCalculatorView()
            }
            Tab("Profile", systemImage: "person") {
                ProfilePage(profile: profile)
            }

        }
        .task {
            await getUser()
        }
    }
    private func getUser() async {
        do {
            profile = try await MachineAPI.shared.loadUserProfile()
        } catch {
            print(error.localizedDescription)
        }
    }
}
