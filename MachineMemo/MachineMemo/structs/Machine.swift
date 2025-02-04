//
//  Machine.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//
import Foundation

struct MachineResponse: Codable {
    let data: [Machine]
    let status: String
}

struct Machine: Identifiable, Codable {
    let id: Int?
    let name: String
    let type: String
    let brand: String
}

struct AddMachine: Codable {
    let status: String
    let message: String
    let id: Int
}
