//
//  Workout.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 3/15/25.
//

import Foundation

struct Workout: Identifiable, Codable {
    var id: Int
    var name: String
    var createdAt: String
    let exercises: [String: [String: [String: String]]]
}

struct Exercise: Identifiable, Codable {
    var id: Int
    var name: String
    var sets: [SetData]
}

struct SetData: Identifiable, Codable {
    var id: UUID = UUID()
    var reps: Int
    var weight: Double
}
