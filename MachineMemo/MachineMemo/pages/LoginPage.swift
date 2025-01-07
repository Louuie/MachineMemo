//
//  LoginPage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/6/25.
//

import SwiftUI

struct LoginPage: View {
    @State private var errorMessage: String = ""
    @State private var navScreen: Bool = false
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    signInWithGoogle()
                    if errorMessage.isEmpty && !isLoading {
                        navScreen = true
                    }
                }) {
                    Text("Sign in with Google")
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .navigationDestination(isPresented: $navScreen) {
                MachinePage()
            }
            .padding()
        }
    }

    private func signInWithGoogle() {
        Task {
            do {
                isLoading = true
                try await supabase.auth.signInWithOAuth(
                    provider: .google,
                    redirectTo: URL(string: "io.supabase.user-management://login-callback")
                )
                isLoading = false
            } catch {
                errorMessage = "Failed to log in: \(error.localizedDescription)"
            }
        }
    }
}
