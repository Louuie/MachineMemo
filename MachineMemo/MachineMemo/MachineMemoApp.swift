//
//  MachineMemoApp.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//  Modified by Eric Hurtado.
//
import SwiftUI

extension Notification.Name {
    static let loginSuccess = Notification.Name("loginSuccess")
}

@main
struct MachineMemoApp: App {
    @AppStorage("authToken") private var authToken: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        await checkTokenOnLaunch()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    Task {
                        await checkTokenOnResume()
                    }
                }
        }
    }
    
    // Runs when the app launches
    private func checkTokenOnLaunch() async {
        print("Checking token on launch...")
        await validateToken()
    }
    
    // Runs when the app resumes from background
    private func checkTokenOnResume() async {
        print("Checking token on resume...")
        await validateToken()
    }

    // Validates the token
    private func validateToken() async {
        guard let url = URL(string: "https://machinememo-5791cb7039d5.herokuapp.com/auth/validate") else { return }
        guard !authToken.isEmpty else {
            print("No token found, forcing logout.")
            isLoggedIn = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    print("Token expired. Logging out...")
                    await MainActor.run {
                        authToken = ""
                        isLoggedIn = false
                    }
                } else {
                    print("Token is still valid.")
                }
            }
        } catch {
            print("Error validating token: \(error.localizedDescription)")
        }
    }
}


struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Checking session...")  // ⏳ Show loading while checking token
                    .onAppear {
                        Task {
                            await checkTokenStatus()
                        }
                    }
            } else if isLoggedIn {
                Tabs()
                    .transition(.identity)
            } else {
                LoginPage()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.45), value: isLoggedIn)
        .onReceive(NotificationCenter.default.publisher(for: .loginSuccess)) { _ in
            print("Login successful! Updating session state.")
            isLoggedIn = true
        }
    }

    private func checkTokenStatus() async {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            isLoggedIn = false
            isLoading = false
            return
        }

        do {
            let isValid = try await MachineAPI.shared.isTokenValid(token: token)
            if isValid {
                isLoggedIn = true
            } else {
                isLoggedIn = false
            }
        } catch {
            print("Token check failed: \(error.localizedDescription)")
            isLoggedIn = false
        }

        isLoading = false
    }
}





