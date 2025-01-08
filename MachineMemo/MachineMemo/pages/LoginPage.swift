//
//  LoginPage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/6/25.
//

import SwiftUI

struct LoginPage: View {
    @State private var errorMessage: String = ""
    @State private var navScreen: Bool = false
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    isLoading = true
                    
                    // Call `loginWithGoogle`
                    MachineAPI.shared.loginWithGoogle()
                    
                    // Simulate success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isLoading = false
                        // Assume navigation on success
                        navScreen = true
                    }
                }) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Sign in with Google")
                    }
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .navigationDestination(isPresented: $navScreen) {
                Tabs()
            }
            .padding()
        }
    }
}

#Preview {
    LoginPage()
}
