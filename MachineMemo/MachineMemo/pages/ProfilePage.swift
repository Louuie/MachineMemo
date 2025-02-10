    //
//  ProfilePage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 2/7/25.
//

import SwiftUI

struct ProfilePage: View {
    @State var profile: Profile
    @State private var isLoggedOut: Bool = false
    var body: some View {
        NavigationView {
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
                Button(action: {
                    Task {
                        await logout()
                    }
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
                 .fullScreenCover(isPresented: $isLoggedOut) {
                     LoginPage()
                 }
            }
        }
    }
    private func logout() async {
        do {
            isLoggedOut = try await MachineAPI.shared.logout()
            print(isLoggedOut)
        } catch {
            print(error.localizedDescription)
        }
    }
}
