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
    //@AppStorage("authToken") private var authToken: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var showAgreementDialog: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                VStack(spacing: 8) {
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
                
                // Google Login Button
                Button(action: {
                    showAgreementDialog = true // Show Agreement before signing in
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
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
                }
                .padding(.horizontal, 40)
                .disabled(isLoading)
                .opacity(isLoading ? 0.7 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isLoading)
                .alert("Terms of Use and Privacy Policy", isPresented: $showAgreementDialog) {
                    Button("Cancel", role: .cancel) { showAgreementDialog = false }
                    Button("Agree") {
                        isLoading = true
                        performLogin()
                    }
                } message: {
                    Text("I confirm that I have read, consent, and agree to MachineMemo's Terms of Use and Privacy Policy.")
                }
                
                // Error Message (if login fails)
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground)) // Ensures dark mode works properly
        }
    }

    // Perform Login using ASWebAuthenticationSession
    private func performLogin() {
        let authURL = URL(string: "http://192.168.1.29:5001/google/login")!
        let callbackScheme = "machinememo"

        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: callbackScheme
        ) { callbackURL, error in
            isLoading = false

            if let error = error as? ASWebAuthenticationSessionError {
                if error.code == .canceledLogin {
                    errorMessage = "Login was canceled. Please try again."
                } else {
                    errorMessage = "Login failed: \(error.localizedDescription)"
                }
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

    // Handle OAuth Callback
    private func handleDeepLink(_ url: URL) {
        print("Received URL:", url.absoluteString)

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let access_token = components.queryItems?.first(where: { $0.name == "access_token" })?.value,
           let refresh_token = components.queryItems?.first(where: { $0.name == "refresh_token" })?.value {
            
            print("Found Token:", access_token)
            
            //authToken = access_token
            UserDefaults.standard.set(access_token, forKey: "authToken")
            UserDefaults.standard.set(refresh_token, forKey: "refreshToken")
            UserDefaults.standard.synchronize()

            print("Stored Auth Token:", UserDefaults.standard.string(forKey: "authToken") ?? "None")
            print("Stored Refresh Token:", UserDefaults.standard.string(forKey: "refreshToken") ?? "None")

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
