//
//  LoginPage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/6/25.
//

import SwiftUI

struct LoginPage: View {
    @State private var isLoggedIn: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        Group {
            if isLoggedIn {
                Tabs() // Replace with your Tabs view
            } else {
                loginContent
            }
        }
        .animation(.easeInOut, value: isLoggedIn) // Smooth transition
    }

    private var loginContent: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    isLoading = true
                    performLogin()
                }) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Sign in with Google")
                    }
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
        }
    }

    private func performLogin() {
        MachineAPI.shared.loginWithGoogle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Assume success
            isLoading = false
            isLoggedIn = true
        }
    }
}
