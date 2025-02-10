//
//  SceneDelegate.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/7/25.
//
import UIKit
import Foundation

extension Notification.Name {
    static let loginSuccess = Notification.Name("loginSuccess")
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("Scene?")
        guard let url = URLContexts.first?.url else { return }

        if url.absoluteString.contains("callback") {
            print("✅ Deep link detected: \(url)")

            // Notify app that login was successful
            NotificationCenter.default.post(name: .loginSuccess, object: nil)
        }
    }
}


