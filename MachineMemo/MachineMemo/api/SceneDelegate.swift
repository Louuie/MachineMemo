//
//  SceneDelegate.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/7/25.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        let url = urlContext.url

        // Handle the URL scheme (e.g., myapp://callback?code=123)
        if url.scheme == "myapp", url.host == "callback" {
            NotificationCenter.default.post(name: .NSCalendarDayChanged, object: nil, userInfo: ["url": url])
        }
    }
}

