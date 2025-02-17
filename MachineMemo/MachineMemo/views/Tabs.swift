//
//  Tabs.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//  Modified by Eric Hurtado.
//

import SwiftUI

struct Tabs: View {
    @State private var profile: Profile = Profile(name: "", email: "", profile_picture: "")
    @State private var appVersion: String = ""
    @State private var buildNumber: String = ""
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
            Tab("Calculator", systemImage: "dumbbell") {
                BarbellCalculatorView()
            }
            Tab("Profile", systemImage: "person") {
                ProfilePage(profile: profile, appVersion: appVersion, buildNumber: buildNumber)
            }

        }
        .task {
            await getUser()
        }
    }
    private func getUser() async {
        do {
            profile = try await MachineAPI.shared.loadUserProfile()
            appVersion = getAppVersion()
            buildNumber = getBuildNumber()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "Unknown"
    }
    
    private func getBuildNumber() -> String {
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return buildNumber
        }
        return "Unknown"
    }
}
