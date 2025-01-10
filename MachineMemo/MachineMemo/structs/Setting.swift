//
//  Setting.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/9/25.
//

struct Setting: Codable {
    let machine_id: String
    let settings: [String: String]
}

struct AddSetting: Codable {
    let message: String
    let status: String
}
