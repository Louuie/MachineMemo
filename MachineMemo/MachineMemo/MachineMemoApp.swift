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

    var body: some View {
        Group {
            if isLoggedIn {
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
}





