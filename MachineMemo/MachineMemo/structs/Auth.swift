//
//  Auth.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 2/20/25.
//

struct RefreshReponse: Codable {
    let status: String
    let access_token: String
    let refresh_token: String
}

