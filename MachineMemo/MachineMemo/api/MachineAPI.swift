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
}

