//
//  MachineAPI.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//  Modified by Eric Hurtado.
//
import SwiftUI
import Foundation
import SafariServices
import AuthenticationServices

enum APIError: Error {
    case serverError(message: String)
    case networkError(error: Error)
    // ... other error cases
}

struct APIResponse<T: Decodable>: Decodable {
    let status: String
    let message: String?
    let data: T?
}

struct Update: Decodable, Identifiable {
    let id: Int
    let name: String
    // ... other properties
}

class MachineAPI {
    static let shared = MachineAPI()
    private let baseURL = "http://192.168.1.5:5001"
    var session: URLSession
    
    @AppStorage("authToken") private var authToken: String?
    
    init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    func fetchMachines() async throws -> [Machine] {
        guard let url = URL(string: "\(baseURL)/machines?type=User") else {
            throw URLError(.badURL)
        }
        let storedToken = UserDefaults.standard.string(forKey: "authToken") ?? ""

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")
        
        
        let (data, _) = try await session.data(for: request)
        
        // Print the raw response for debugging
        print(String(data: data, encoding: .utf8) ?? "Invalid Data")
        
        // Decode the root response
        let response = try JSONDecoder().decode(MachineResponse.self, from: data)
        return response.data
    }
    
    func addMachine(machine: Machine) async throws -> AddMachine {
        guard let url = URL(string: "\(baseURL)/machines?name=\(machine.name)&type=User&brand=\(machine.brand)") else {
            throw URLError(.badURL)
        }
        
        // Encode the JSON Data
        let jsonData = try JSONEncoder().encode(machine)
        
        // Create the POST HTTP Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        // Send the request and get the actual response
        let (data, _) = try await session.data(for: request)
        
        // Print it
        print(String(data: data, encoding: .utf8) ?? "Invalid Data")
        
        // Decode the response and return it
        let response = try JSONDecoder().decode(AddMachine.self, from: data)
        return response
    }
    
    func addSetting(setting: Setting) async throws -> AddSetting {
        guard let url = URL(string: "\(baseURL)/settings?machine_id=\(setting.machine_id)") else {
            throw URLError(.badURL)
        }
        
        let jsonData = try JSONEncoder().encode(setting)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (data, _) = try await session.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "Invalid Data")
        let response = try JSONDecoder().decode(AddSetting.self, from: data)
        return response
    }
    func getSettings(machineID: String) async throws -> [Setting] {
        guard let url = URL(string: "\(baseURL)/settings?machine_id=\(machineID)") else {
            throw URLError(.badURL)
        }

        // 🔹 Retrieve Token from UserDefaults (like `getUserMachines()`)
        let storedToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        print("Stored Auth Token Before Request:", storedToken)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")
        
        print("📤 Sending Headers:", request.allHTTPHeaderFields ?? "No headers")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response Status:", httpResponse.statusCode)
        }
        
        print("Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid Data")
        
        // Decode the JSON response
        do {
            let response = try JSONDecoder().decode(SettingResponse.self, from: data)
            print("Decoded Response:", response)
            return response.data
        } catch {
            print("Decoding Error:", error.localizedDescription)
            throw error
        }
    }

    
    
    
    func loginWithGoogle() {
        // Your backend's Google OAuth endpoint
        let authURL = URL(string: "http://192.168.1.5:5001/google/login")!
        
        // Custom URL scheme for redirect (e.g., your-app://oauth-callback)
        let callbackScheme = "yourappscheme" // Match your app's URL scheme
        
        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: callbackScheme
        ) { callbackURL, error in
            guard error == nil, let _ = callbackURL else {
                print("Login failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Login succeeded! Cookies are already in Safari's shared storage.
            NotificationCenter.default.post(name: .loginSuccess, object: nil)
        }
        
        // Required for iOS 13+
        //session.presentationContextProvider = self
        session.start()
    }
    
    func updateSetting(settingId: Int, updatedSettings: [String: String], machine_id: Int) async throws -> Setting {
        let url = URL(string: "\(baseURL)/edit?setting_id=\(settingId)")!
        var request = URLRequest(url: url)
        let storedToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")
        
        let jsonData = try JSONSerialization.data(withJSONObject: updatedSettings)
        request.httpBody = jsonData
        
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<Setting>.self, from: data)
        
        if response.status == "success", let setting = response.data {
            return setting
        } else {
            throw APIError.serverError(message: response.message ?? "Unknown error")
        }
    }
    func loadUserProfile() async throws -> Profile {
        guard let url = URL(string: "\(baseURL)/user") else {
            throw URLError(.badURL)
        }
        
        let storedToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")
        
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("🔎 Response Status:", httpResponse.statusCode)
        }
        
        print("📝 Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid Data")
        
        do {
            let response = try JSONDecoder().decode(ProfileResponse.self, from: data)
            print("Decoded Response:", response)
            return response.data
        } catch {
            print("Decoding Error:", error.localizedDescription)
            throw error
        }
    }
    
    func isLoggedIn() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/user") else {
            throw URLError(.badURL)
        }
        print("Making sure we got the token in the machineAPI \(authToken ?? "")")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("include", forHTTPHeaderField: "credentials")  // Ensure cookies are included
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        // Use the shared session
        let (data, response) = try await session.data(for: request)
        
        // 🔹 Debug: Print Cookies
        if let httpResponse = response as? HTTPURLResponse {
            print("Response Status:", httpResponse.statusCode)
            if let cookies = session.configuration.httpCookieStorage?.cookies {
                for cookie in cookies {
                    print("🍪 Stored Cookie:", cookie)
                }
            }
        }
        
        // 🔹 Debug: Print Raw JSON
        print("Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid Data")
        let storedToken = UserDefaults.standard.string(forKey: "authToken")
        print("Using Auth Token:", storedToken ?? "None")
        
        
        // Decode JSON response
        do {
            let response = try JSONDecoder().decode(UserResponse.self, from: data)
            print("Decoded Response:", response)
            return response.status == "success"
        } catch {
            print("Decoding Error:", error.localizedDescription)
            throw error
        }
    }
    
    func logout() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/logout") else {
            throw URLError(.badURL)
        }
        let storedToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        print("Stored Auth Token Before Request:", storedToken)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("include", forHTTPHeaderField: "credentials")  // Ensure cookies are included
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        let (data, _) = try await session.data(from: url)
        
        // Debugging: Print raw JSON data
        print("Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid Data")
        
        // Decode the JSON response
        do {
            let response = try JSONDecoder().decode(UserResponse.self, from: data)
            print("Decoded Response:", response)
            if response.status == "success" {
                return true
            } else { return false }
        } catch {
            print("Decoding Error:", error.localizedDescription)
            throw error
        }
    }
    
    func getUserMachines() async throws -> [Machine] {
        guard let url = URL(string: "\(baseURL)/user/machines") else {
            throw URLError(.badURL)
        }
        
        let storedToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        print("Stored Auth Token Before Request:", storedToken)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")
        
        print("Sending Headers:", request.allHTTPHeaderFields ?? "No headers")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response Status:", httpResponse.statusCode)
        }
        
        print("Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid Data")
        
        do {
            let response = try JSONDecoder().decode(MachineResponse.self, from: data)
            print("Decoded Response:", response)
            return response.data
        } catch {
            print("Decoding Error:", error.localizedDescription)
            throw error
        }
    }
}

