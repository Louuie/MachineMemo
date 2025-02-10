//
//  SafariView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 2/8/25.
//

import SwiftUI
import SafariServices

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    let onLoginSuccess: () -> Void

    func makeUIViewController(context: Context) -> SFSafariViewController {
        print("🟢 Opening SafariViewController with URL: \(url)")
        let safariVC = SFSafariViewController(url: url)

        NotificationCenter.default.addObserver(
            forName: .loginSuccess,
            object: nil,
            queue: .main
        ) { _ in
            print("✅ SafariView received loginSuccess event, dismissing!")
            safariVC.dismiss(animated: true)
            onLoginSuccess()
        }

        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

