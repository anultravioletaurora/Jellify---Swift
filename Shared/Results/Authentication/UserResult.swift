//
//  UserResult.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation

struct UserResult: Codable {
    let name, serverID, id: String
    let hasPassword, hasConfiguredPassword, hasConfiguredEasyPassword, enableAutoLogin: Bool
    let lastLoginDate, lastActivityDate: String
//    let configuration: Configuration
//    let policy: Policy

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case serverID = "ServerId"
        case id = "Id"
        case hasPassword = "HasPassword"
        case hasConfiguredPassword = "HasConfiguredPassword"
        case hasConfiguredEasyPassword = "HasConfiguredEasyPassword"
        case enableAutoLogin = "EnableAutoLogin"
        case lastLoginDate = "LastLoginDate"
        case lastActivityDate = "LastActivityDate"
//        case configuration = "Configuration"
//        case policy = "Policy"
    }
}
