//
//  MachineMemoApp.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//  Modified by Eric Hurtado.
//
import SwiftUI

@main
struct MachineMemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
                Tabs() // Main app
            } else {
                LoginPage()
            }
        }
        .onAppear {
            print("isLoggedIn at launch:", isLoggedIn)
        }
    }
}

