//
//  MachineMemoApp.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//
import SwiftUI
@main
struct MachineMemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var isLoginSheetPresented = true  // Default to login screen

    var body: some Scene {
        WindowGroup {
            LoginPage()
        }
    }
}
