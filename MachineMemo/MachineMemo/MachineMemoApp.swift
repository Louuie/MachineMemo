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
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        Group {
            if isLoggedIn {
                Tabs()
                    .transition(.identity) // No transition for main app
            } else {
                LoginPage()
                    .transition(.move(edge: .top).combined(with: .opacity)) // Slide-up effect for login
            }
        }
        .animation(.easeInOut(duration: 0.45), value: isLoggedIn) // Ensures smooth transition when toggling
    }
}



