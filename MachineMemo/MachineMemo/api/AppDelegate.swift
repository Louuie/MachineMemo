//
//  AppDelegate.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/6/25.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("✅ Deep link received in AppDelegate: \(url)")

        if url.absoluteString.contains("myapp://callback") {
            NotificationCenter.default.post(name: .loginSuccess, object: nil)
            return true
        }
        return false
    }
}


