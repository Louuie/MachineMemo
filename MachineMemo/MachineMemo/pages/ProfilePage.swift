    //
//  ProfilePage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 2/7/25.
//

import SwiftUI

struct ProfilePage: View {
    @State var profile: Profile
    @State var appVersion: String
    @State var buildNumber: String
    @State private var showSafari = false
    @State private var selectedURL: URL = URL(string: "https://www.example.com")!
    @State private var showConfirmDialog = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true

    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section(header: Text("Profile")) {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Email")
                            .lineLimit(1)
                        Spacer()
                        Text(profile.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Image("g_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(2)
                        Text("Google")
                            .lineLimit(1)
                        Spacer()
                        Text("Connected")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }

                // About Section
                Section(header: Text("About")) {
                    AboutRow(title: "Terms of Use", icon: "doc.text", url: "https://www.example.com/terms", showSafari: $showSafari, selectedURL: $selectedURL)
                    AboutRow(title: "Privacy Policy", icon: "hand.raised", url: "https://www.example.com/privacy", showSafari: $showSafari, selectedURL: $selectedURL)
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Check for updates")
                        Spacer()
                        Text("\(appVersion)(\(buildNumber))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                        Image(systemName: "chevron.right") // Mimic NavigationLink arrow
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle()) // Make the whole row tappable
                    .onTapGesture {
                        selectedURL = URL(string: "https://www.example.com/updates")!
                        showSafari = true
                    }
                }

                // Logout Section
                Section {
                    Button(role: .destructive, action: {
                        showConfirmDialog = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                    }
                    .alert("Confirm log out?", isPresented: $showConfirmDialog) {
                        Button("Cancel", role: .cancel) {
                            showConfirmDialog = false
                        }
                        Button("Log out", role: .destructive) {
                            Task {
                                await logout()
                            }
                        }
                    } message: {
                        Text("Logging out won't delete any data. You can sign back into this account anytime.")
                    }
                }
            }
            .sheet(isPresented: $showSafari) {
                SafariWebView(url: selectedURL)
            }
        }
    }
    private func logout() async {
        do {
            let success = try await MachineAPI.shared.logout()
            if success {
                isLoggedIn = false  // Clear local session
                UserDefaults.standard.removeObject(forKey: "isLoggedIn")
                UserDefaults.standard.synchronize()

                // Send logout event
            }
        } catch {
            print(error.localizedDescription)
        }
    }


}
// Struct used for the About section, mostly needed cause of the SafariWebView
struct AboutRow: View {
    let title: String
    let icon: String
    let url: String
    @Binding var showSafari: Bool
    @Binding var selectedURL: URL

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right") // Mimic NavigationLink arrow
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle()) // Make the whole row tappable
        .onTapGesture {
            selectedURL = URL(string: url)!
            showSafari = true
        }
    }
}



