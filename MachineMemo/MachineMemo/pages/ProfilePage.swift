    //
//  ProfilePage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 2/7/25.
//

import SwiftUI

struct ProfilePage: View {
    @State var profile: Profile
    @State private var showConfirmDialog = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true  // Track login state

    var body: some View {
        NavigationView {
            VStack {
                // Profile Picture
                AsyncImage(url: URL(string: profile.profile_picture)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Text("No image available")
                    } else {
                        Image(systemName: "photo")
                    }
                }
                .frame(width: 250, height: 250)
                .border(Color.gray)

                // Profile Info
                Text("\(profile.name)")
                Text("\(profile.email)")

                // Logout Button
                Button(action: {
                    showConfirmDialog = true
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .imageScale(.large)
                    Text("Log out")
                        .font(.system(.title2))
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 4))
                .controlSize(.large)
                .tint(.red)
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
    }

    private func logout() async {
        do {
            let success = try await MachineAPI.shared.logout()
            if success {
                // Clear stored login data
                isLoggedIn = false
                UserDefaults.standard.removeObject(forKey: "isLoggedIn")
                UserDefaults.standard.synchronize()
            }
        } catch {
            print(error.localizedDescription)
        }
    }

}

