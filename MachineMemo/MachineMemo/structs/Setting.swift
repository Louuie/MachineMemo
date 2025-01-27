//
//  Setting.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/9/25.
//

struct Setting: Identifiable, Codable {
    let id: Int?
    let machine_id: Int
    let settings: [String: String]
    let user_id: String?
}

struct AddSetting: Codable {
    let message: String
    let status: String
}
struct SettingResponse: Codable {
    let data: [Setting]
    let status: String
}
