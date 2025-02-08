//
//  ProfilePage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 2/7/25.
//

import SwiftUI

struct ProfilePage: View {
    @State private var errorMessage: String = ""
    @State private var profile: Profile = Profile(name: "", email: "", profile_picture: "")
    var body: some View {
        VStack {
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
            Text("\(profile.name)")
            Text("\(profile.email)")
        }
        .task {
            await loadUserProfile()
        }
    }
    private func loadUserProfile() async {
        do {
            profile = try await MachineAPI.shared.loadUserProfile()
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }
}

#Preview {
    ProfilePage()
}
