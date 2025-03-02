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
    private let baseURL = "https://machinememo.me"
    var session: URLSession
    
    
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
    
    func addMachine(machine: Machine, image: UIImage?) async throws -> AddMachine {
        guard let url = URL(string: "\(baseURL)/machines?name=\(machine.name)&type=User&brand=\(machine.brand)") else {
            throw URLError(.badURL)
        }
        let storedToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")

        var body = Data()

        // Add name field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(machine.name)\r\n".data(using: .utf8)!)

        // Add brand field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"brand\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(machine.brand)\r\n".data(using: .utf8)!)

        // Add image if available
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            let filename = "machine_\(UUID().uuidString).jpg"
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AddMachine.self, from: data)
    }

    
    func addSetting(setting: Setting) async throws -> AddSetting {
        guard let url = URL(string: "\(baseURL)/settings?machine_id=\(setting.machine_id)") else {
            throw URLError(.badURL)
        }
        let storedToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        let jsonData = try JSONEncoder().encode(setting)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")
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

        // Retrieve Token from UserDefaults (like `getUserMachines()`)
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
        let storedToken = UserDefaults.standard.string(forKey: "authToken") ?? ""
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("include", forHTTPHeaderField: "credentials")  // Ensure cookies are included
        request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")
        
        // Use the shared session
        let (data, response) = try await session.data(for: request)
        
        // Debug: Print Raw JSON
        print("Raw Response:", String(data: data, encoding: .utf8) ?? "Invalid Data")
        
        
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
        //request.setValue("include", forHTTPHeaderField: "credentials")  // Ensure cookies are included
        request.setValue("Bearer \(storedToken)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await session.data(for: request)
        
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
    func isTokenValid(token: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/auth/validate") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("🔹 HTTP Status Code: \(httpResponse.statusCode)")
            print("🔹 Response Headers: \(httpResponse.allHeaderFields)")

            let responseString = String(data: data, encoding: .utf8) ?? "❌ Could not decode response"
            print("🔹 Raw Response Body: \(responseString)")

            if httpResponse.statusCode == 200 {
                return true
            } else if httpResponse.statusCode == 401 {
                print("❌ Token expired")
                return false
            }
        }

        throw URLError(.cannotDecodeContentData)
    }


}

