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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

}

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var isLoading = true  // 🔹 Show loading spinner at start

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
            print("🔄 Login successful! Updating session state.")
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





