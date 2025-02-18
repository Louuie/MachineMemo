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
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("authToken") private var authToken: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                
                VStack(spacing: 10) {
                    Image(colorScheme == .dark ? "AppImage_Light" : "AppImage_Dark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    Text("MachineMemo")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                }
                .padding(.top, 80)
                
                Spacer()
                
                Button(action: {
                    isLoading = true
                    performLogin()
                }) {
                    HStack {
                        Image("g_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign in with Google")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6)) // Lighter background for contrast
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
                }
                .padding(.horizontal, 40)
                .disabled(isLoading)
                .opacity(isLoading ? 0.7 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isLoading)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                Spacer()
                    .padding()
                    .background(Color(.systemBackground)) // Adapts to dark mode
            }
        }
    }

    // 🔹 Perform Login using ASWebAuthenticationSession
    private func performLogin() {
        let authURL = URL(string: "https://machinememo-5791cb7039d5.herokuapp.com/google/login")!
        let callbackScheme = "machinememo"

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

            handleDeepLink(callbackURL)
        }

        let coordinator = Coordinator()
        session.prefersEphemeralWebBrowserSession = false
        session.presentationContextProvider = coordinator
        session.start()
    }

    // 🔹 Handle OAuth Callback
    private func handleDeepLink(_ url: URL) {
        print("📱 Received URL:", url.absoluteString)

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let token = components.queryItems?.first(where: { $0.name == "access_token" })?.value {
            
            print("✅ Found Token:", token)
            
            authToken = token
            UserDefaults.standard.set(token, forKey: "authToken")
            UserDefaults.standard.synchronize()

            print("Stored Auth Token:", UserDefaults.standard.string(forKey: "authToken") ?? "None")

            isLoggedIn = true
            NotificationCenter.default.post(name: .loginSuccess, object: nil)
        } else {
            errorMessage = "Failed to retrieve token."
        }
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
