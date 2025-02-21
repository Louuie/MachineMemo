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
    @AppStorage("refreshToken") private var refreshToken: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var isLoading = false

    var body: some Scene {
        WindowGroup {
            if isLoading {
                SpinnerView()
            } else {
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
    }
    
    // Runs when the app launches
    private func checkTokenOnLaunch() async {
        print("Checking token on launch...")
        await validateToken()
    }
    
    // Runs when the app resumes from background
    private func checkTokenOnResume() async {
        print("Checking token on resume...")
        await MainActor.run { isLoading = true }
        await validateToken()
    }

    // Validates the token
    private func validateToken() async {
        guard let url = URL(string: "https://machinememo.me/auth/validate") else { return }
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
                    print("Token expired. Checking if refresh_token is present to refresh the session")
                    // If the refresh_token is not present its impossible for us to refresh the session so force the user to log back in.
                    if refreshToken.isEmpty {
                        print("Refresh_Token is empty go make the user login")
                        await MainActor.run {
                            authToken = ""
                            isLoggedIn = false
                            isLoading = false
                        }
                    } else {
                        await refreshUserToken()
                    }
                } else {
                    print("Token is still valid.")
                    await MainActor.run { isLoading = false }
                }
            }
        } catch {
            print("Error validating token: \(error.localizedDescription)")
        }
    }
    private func refreshUserToken() async {
        guard let url = URL(string: "https://machinememo.me/auth/refresh") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    await MainActor.run {
                        authToken = ""
                        refreshToken = ""
                        isLoggedIn = false
                        isLoading = false
                    }
                }
            }
            // Parse the JSON to set the new access_token and refresh_token
            // Print the raw response for debugging
            print(String(data: data, encoding: .utf8) ?? "Invalid Data")
            
            // Decode the root response
            let json_response = try JSONDecoder().decode(RefreshReponse.self, from: data)
            await MainActor.run {
                authToken = json_response.access_token
                refreshToken = json_response.refresh_token
                isLoading = false
                isLoggedIn = true
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
                SpinnerView()
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





