//
//  Profile.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 2/7/25.
//
struct ProfileResponse: Codable {
    let data: Profile
    let status: String
}

struct Profile: Codable {
    let name: String
    let email: String
    let profile_picture: String
}
