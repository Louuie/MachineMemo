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
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "m.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("MachineMemo")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.top, 100)
                
                Spacer()
                
                // Login Button
                Button(action: {
                    isLoading = true
                    performLogin()
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                        
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign in with Google")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
                .padding(.horizontal, 40)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding()
        }
    }

    private func performLogin() {
        let url: String = "https://machinememo-5791cb7039d5.herokuapp.com/google/login"
        guard let url_other = URL(string: url) else {
            isLoading = false
            errorMessage = "Invalid login URL"
            return
        }
        loginURL = url_other
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
#Preview {
    LoginPage()
}
