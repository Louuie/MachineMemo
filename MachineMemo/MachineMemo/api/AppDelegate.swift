//
//  AppDelegate.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/6/25.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Check if the URL matches your scheme and path
        if url.scheme == "myapp" || url.host == "callback" {
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems

            // Extract the token from the query parameters
            if let token = queryItems?.first(where: { $0.name == "token" })?.value {
                print("Access token: \(token)")
                // Handle the token (e.g., save it, make API requests, or update the UI)
            }
            return true
        }
        return false
    }
}

