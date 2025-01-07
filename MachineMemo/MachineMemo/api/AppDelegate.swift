//
//  AppDelegate.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/6/25.
//

import UIKit
import Supabase

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // Pass the URL to the Supabase Auth client for processing
        supabase.auth.handle(url)
        return true
    }
}

