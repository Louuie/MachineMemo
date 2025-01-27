//
//  MachineAPI.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//
import Foundation
import SafariServices

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
    let baseURL = "http://192.168.1.109:5001"

    func fetchMachines() async throws -> [Machine] {
        guard let url = URL(string: "\(baseURL)/machines?type=User") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

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
        request.httpBody = jsonData
        
        // Send the request and get the actual response
        let (data, _) = try await URLSession.shared.data(for: request)
        
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
        request.httpBody = jsonData
        
        let (data, _) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "Invalid Data")
        let response = try JSONDecoder().decode(AddSetting.self, from: data)
        return response
    }
    func getSettings(machineID: String) async throws -> [Setting] {
        guard let url = URL(string: "\(baseURL)/settings?machine_id=\(machineID)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Debugging: Print raw JSON data
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
        guard let url = URL(string: "\(baseURL)/google/login") else { return }
        
        let safariVC =  SFSafariViewController(url: url)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(safariVC, animated: true, completion: nil)
            //rootVC.dismiss(animated: true)
        }
    }
    
    func updateSetting(settingId: Int, updatedSettings: [String: String], machine_id: Int) async throws -> Setting {
        let url = URL(string: "\(baseURL)/edit?setting_id=\(settingId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: updatedSettings)
        request.httpBody = jsonData
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<Setting>.self, from: data)
        
        if response.status == "success", let setting = response.data {
            return setting
        } else {
            throw APIError.serverError(message: response.message ?? "Unknown error")
        }
    }

}

