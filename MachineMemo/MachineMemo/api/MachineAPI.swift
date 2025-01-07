//
//  MachineAPI.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//
import Foundation

class MachineAPI {
    static let shared = MachineAPI()

    func fetchMachines() async throws -> [Machine] {
        guard let url = URL(string: "http://192.168.1.5:5001/machines?type=User") else {
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
        guard let userId = supabase.auth.currentSession?.user.id else {
            throw URLError(.badServerResponse) // Handle case where user is not logged in
        }
        print("\(userId)")

        guard let url = URL(string: "http://192.168.1.5:5001/machines?name=\(machine.name)&type=User&brand=\(machine.brand)&user_id=\(userId)") else {
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
}

