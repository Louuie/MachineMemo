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
    @State private var showSafariView: Bool = false
    @State private var loginURL: URL?

    var body: some View {
        Group {
            if isLoggedIn {
                Tabs() // Replace with your main app view
            } else {
                loginContent
            }
        }
        .animation(.easeInOut, value: isLoggedIn) // Smooth transition
        .onOpenURL { url in
            handleDeepLink(url)
        }
        .sheet(isPresented: $showSafariView) {
            if let url = loginURL {
                SafariView(url: url, onLoginSuccess: {
                    print("Safari Login Successful, Dismissing Sheet")
                    isLoggedIn = true
                    showSafariView = false
                })
            }
        }
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
        guard let url = URL(string: "http://192.168.1.30:5001/google/login") else {
            isLoading = false
            errorMessage = "Invalid login URL"
            return
        }
        loginURL = url
        showSafariView = true
    }

    private func handleDeepLink(_ url: URL) {
        print("Received deep link: \(url.absoluteString)")

        if url.absoluteString.starts(with: "myapp://callback") {
            print("Recognized login callback URL!")
            isLoggedIn = true
            showSafariView = false
            NotificationCenter.default.post(name: .loginSuccess, object: nil)
            print("Posted loginSuccess notification!")
        } else {
            print("Unrecognized deep link: \(url.absoluteString)")
        }
    }

}
