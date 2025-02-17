//
//  LoginPage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/6/25.
//  Modified by Eric Hurtado.
//
import SwiftUI
import AuthenticationServices

struct LoginPage: View {
    @AppStorage("authToken") private var authToken: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "m.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("MachineMemo")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.top, 100)
                
                Spacer()
                
                // Login Button
                Button(action: {
                    isLoading = true
                    performLogin()
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                        
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign in with Google")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
                .padding(.horizontal, 40)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding()
        }
    }

    private func performLogin() {
        // Your backend's Google OAuth endpoint
        let authURL = URL(string: "https://machinememo-5791cb7039d5.herokuapp.com/google/login")!
        
        // Custom URL scheme for redirect (e.g., your-app://oauth-callback)
        let callbackScheme = "machinememo" // Match your app's URL scheme
        
        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: callbackScheme
        ) { callbackURL, error in
            isLoading = false
            
            if let error = error {
                errorMessage = "Login failed: \(error.localizedDescription)"
                return
            }
            
            guard let callbackURL = callbackURL else {
                errorMessage = "Invalid callback URL"
                return
            }
            
            // Handle the callback URL (e.g., verify login success)
            handleDeepLink(callbackURL)
        }
        
        // Use the coordinator to provide the presentation context
        let coordinator = Coordinator()
        session.prefersEphemeralWebBrowserSession = false
        session.presentationContextProvider = coordinator
        session.start()
    }

    private func handleDeepLink(_ url: URL) {
        print("📱 Received URL:", url.absoluteString)
        
        // Print all URL components for debugging
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            print("📍 URL Components:")
            print("- Query Items:", components.queryItems ?? "None")
            
            if let token = components.queryItems?.first(where: { $0.name == "access_token" })?.value {
                print("Found Token:", token)
                
                authToken = token  // Save to @AppStorage
                UserDefaults.standard.set(token, forKey: "authToken")  // Save persistently
                UserDefaults.standard.synchronize()  // Ensure it writes immediately

                // 🔍 Verify Token Storage
                let storedToken = UserDefaults.standard.string(forKey: "authToken")
                print("Stored Auth Token in UserDefaults:", storedToken ?? "None")
            }

        }
        
        // Rest of your existing code...
        isLoggedIn = true
        NotificationCenter.default.post(name: .loginSuccess, object: nil)
    }
}

// MARK: - Coordinator Class
class Coordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
