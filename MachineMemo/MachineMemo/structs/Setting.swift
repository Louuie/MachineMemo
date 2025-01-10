//
//  Setting.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/9/25.
//

struct Setting: Identifiable, Codable {
    let id: String?
    let machine_id: Int
    let settings: [String: String]
}

struct AddSetting: Codable {
    let message: String
    let status: String
}
struct SettingResponse: Codable {
    let data: [Setting]
    let status: String
}
